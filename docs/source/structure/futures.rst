.. _futures:

*******
Futures
*******

.. highlight:: agda

The Agda SDK contains a new, innovative way to run Agda/Haskell calculations in the background
and retrieve their results later:
it is based on the Future data structure and class,
named after the similar ``std::future`` of C++.

Futures are defined on the Agda side in Tool.Future,
the Future.h header contains their low-level C interface
and the C++ class Future serves as a convenient wrapper around them.

Why do I need this?
-------------------

Unfortunately, by themselves,
longer backend calls cannot send you a notification
when their results are ready,
which would be useful e.g.
for emitting Qt signals.
To imitate such behaviour,
the simplest solution is
to spawn a new ``std::thread``,
run the foreign call on it synchronously,
and perform the action when it has returned.

However, this approach still does not enable us
to interrupt calculations,
as there is no way through which
a backend call can be safely cancelled
without leaving the Haskell runtime in a potentially unusable state.
The only way to cancel a calculation
is to cancel it from the runtime itself.

Our previous approach was to trigger
a Unix semaphore/Win32 event
which awakes a "watcher thread" inside a runtime
that then kills the calculation thread
by raising an exception in it.
The bottleneck of this solution
is how to name the semaphore
to be unique for the given calculation --
if you can have only one calculation in your app at a time,
it is fine to choose a fixed name for it;
otherwise, you will have to choose one run-time.
You can experiment with this approach
under the ``Platform`` directory,
but note that it is deprecated
and not guaranteed to work.

The idea behind Futures is that
by waking up the watcher thread
via Haskell-native MVars,
not only the platform dependency can be eliminated,
but also the interruption mechanism can be easily tied
to specific calculations:
the interruption MVar can simply be attached
to another MVar expecting the result.

Concept
-------

Let's take a look at the Agda definition::

  -- In practice, "a" is almost always an Either String a.
  record Future (a : Set) : Set where
    constructor MkFuture
    field
      interruptionMVar : MVar ⊤
      resultMVar : MVar a
  open Future public
  {-# COMPILE AGDA2HS Future #-}

Esentially, a Future is a pair of two MVars
(Haskell's ``mutable variables``).
The underlying calculation thread writes its result
into the second one
(usually wrapped into a ``Right``).
However, if someone else puts a ``tt`` into the first MVar,
that triggers a watcher thread
which aborts the calculation
and writes some default value
(usually an error message wrapped into a ``Left``)
into the second one.

This mechanism is provided by the ``runAsync`` function::

  runAsync : IO a → IO (Future (Either String a))

This starts any calculation on a new thread behind a Future,
as described above.
(For exact implementation details,
see the definition in Future.agda.)

High-level functions
--------------------

However, you usually need not care about the implementation,
as Future.agda provides functions
for high-level handling of Futures.

Inside Agda, you can use
``runAsync``, ``getFromFuture`` and ``interruptFuture``.
These are quite straightforward;
see the comments above their code
for details.

Exporting Futures to C
----------------------

The basic function for exporting Futures to C
is ``writeFutureC``::

  writeFutureC : Ptr (StablePtr PrimMVar) → Future a → IO ⊤

Since the C side will need two StablePtrs to be able to directly interact with both of them,
``writeFutureC`` writes two StablePtrs
into an array provided by the C caller.
Note that it remains the responsibility of the caller
to free the StablePtrs
(though the RAII wrapper makes this easy -- see later).

This then gives way to run any C-exportable function in the background
while passing the Future to the C side:
``runAsyncC`` (and its variants ``runAsyncC1``, ``runAsyncC2`` and ``runAsyncC3`` for parametered calculations)
does exactly this.

Let's say you want to export a "futurised" version of the following function::

  addValue : AppState Integer -> Int -> IO Integer

First, let us "futurise" it. As it has two parameters, we use ``runAsyncC2``. That is, ``runAsyncC2 addValue`` will have the type ::

  AppState Integer -> Int -> Ptr (StablePtr PrimMVar) -> IO ⊤

And by applying ``stablePtrise3`` to it, we get ::

  StablePtr (AppState Integer) -> Int -> Ptr (StablePtr PrimMVar) -> IO ⊤

So you can give a name to ``stablePtrise3 (runAsyncC2 addValue)``, export it, and you are ready to go: the exported function will have the type signature ::

  void addValueAsyncC(HsStablePtr appStatePtr, int value, HsStablePtr* futurePtr)

Handling futures from C
-----------------------

The low-level interface for getting values from futures can be found in Future.h::

  extern int getCIntFromFutureC(HsPtr a1);
  extern void waitForVoidFutureC(HsPtr a1);
  extern HsPtr getPtrFromFutureC(HsPtr a1);

In Future.agda, there is a general function called ``getFromFutureC`` which retrieves an ``a`` from a ``Future a``; however, as we cannot use a type variable as a return value in a C export, we need instantiations. Those listed are for ``int``, ``void`` and ``HsPtr`` (that is, ``void*``); if you need more, please add it to Future.agda and export it.

Note that these functions do *not* free the StablePtrs. Also, they return an undefined value if the calculation is interrupted; so you have to keep track of this fact by yourself.

Interruption works by calling ``hs_try_putmvar`` on the StablePtr to the first MVar; this also frees that StablePtr (the other one still needs to be freed manually).

The Future class for C++
------------------------

Fortunately, there is a more convenient way to handle futures:
a pre-written, RAII-style wrapper class
(in ``include/Future.hpp`` and ``src/Future.cpp``).
It can be constructed from an ``std::function<void(HsPtr)>``,
into which we should wrap the C exports of the backend.

Let us take the previous example::

  void addValueAsyncC(HsStablePtr appStatePtr, int value, HsStablePtr* futurePtr)

From this, we can construct a Future object like this::

  Future<int> newValueFuture(
      [=](HsPtr futurePtr){addValueAsyncC(..., ..., futurePtr);}
  );

where we must provide the additional parameters ``appStatePtr`` and ``value``
(either by a literal or through a capture).

Afterwards, however, handling the object is pretty straightforward.
There are 3 boolean flags showing the current status:

* ``valid()`` is true whenever there really is an asynchronous calculation or its result behind the Future instance. It is only false if the Future has been moved (via the move constructor or the move assignment operator), or if it has been interrupted.
* ``queried()`` returns whether the result has already been successfully queried (via ``get()``) at least once. If yes, the StablePtrs have been freed and the result is actually cached inside the C++ object.
* ``interrupted()`` indicates what its name tells: whether ``interrupt()`` has been called on the Future. This automatically implies that ``valid()`` is false, and also that the StablePtrs have been freed.

``get()`` throws an ``InterruptedFutureException`` if ``interrupt()`` is called while waiting.

Make sure that before destruction, the Future has either been queried or interrupted. Otherwise, in order to avoid leaks and zombie threads, an error message is shown and ``std::terminate()`` is called, similarly to how ``std::thread`` instances have to be either detached or joined before destruction.

For the time being, the only instantiation of the template is for `int`; if you need more, please add a new getter to Future.agda, export it and define a new instantiation of ``haskellGet()`` which calls on it.

Triggering actions on results
-----------------------------

The method to be described here is that
we store both an ``std::thread`` and the ``Future<int>`` itself
in an object,
and inside the thread, we wait for the result and execute the triggers on it.
The advantage of this approach is that
we immediately get a notification on completion
(and can run triggers on it, e.g. emit a Qt signal)
while still being able to interrupt the calculation from outside.

The idea is embedded in a class
called ``TriggerFuture``.
This cannot be awaited by itself,
but can be given a vector of functions
to be called as triggers on completion.

Chaining futures
(i.e. spawning a new one on completion of a previous one)
has not yet been solved in general.
Note that this might be problematic to solve with triggers,
as when deleting the previous future,
the very function object being executed
would be deleted as well.
For now, the simplest option may be
running normal futures from an ``std::thread``
within a for-loop;
see the `MainViewModel class <https://github.com/viktorcsimma/skeleton/blob/even-counter/frontend/src/ViewModel/MainViewModel.cpp>`_ from the example project
for an example.
