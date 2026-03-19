.. _futures:

*******
Futures
*******

.. highlight:: agda

Agdalache contains a new implementation of futures,
which can be easily exported to C/C++
and can also be interrupted from there.

Futures are defined in the Haskell package ``cfuture``,
around which we provide some wrappers for use in Agda;
also, the C++ class Future serves as a convenient wrapper around them.

See the [documentation](https://hackage.haskell.org/package/cfuture-2.0/docs/Control-Concurrent-CFuture.html)
of the package for details.

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

More details are yet to come.
