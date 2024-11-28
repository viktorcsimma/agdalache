.. _appstate:

******************
Mutable app states
******************

In some cases, you simply need to write a single function in Agda,
prove its correctness and then call it from C or C++.
Often, however, there is a need to verify an entire backend.
Or you might simply find it easier and safer to work in a functional environment.

AppState
--------

In case your app has some kind of mutable state,
the AppState type will help you define the entire environment
with Agda (or Haskell) data structures
and then interact with it via the C API.
You can find it in backend/src/AppState.agda.

Actually, it is only a record containing some IORefs::

  record AppState (... : Set) : Set where
    constructor MkAppState
    field
      -- A mutable Integer.
      counterRef : IORef Integer

      -- An immutable value.
      id : Integer

      -- You can also use type variables:
      someRef : IORef a
  open AppState public
  {-# COMPILE AGDA2HS AppState #-}

So:

* For mutable values, use IORefs; most of the functions related to them are included in Haskell.Data.IORef. See the `documentation <https://hackage.haskell.org/package/base-4.20.0.1/docs/Data-IORef.html>`_ of the original Haskell module.
* For immutable values, you might simply add normal members.
* Type variables are allowed. Note, however, that you might need concrete instantiations for functions imposing type constraints later, in order to export them to C.

IORefs are needed because from the C side, it is easier to have an object reachable and easy to manipulate at all times than to construct immutable states over and over again. This way, communication with the backend is possible via a simple StablePtr.

StablePtrs
----------

A StablePtr is like a pointer that you can pass to a C function. Later, if the C function passes it back to another Haskell call, you can retrieve the original object there. (The same is not true for an ordinary Ptr, because there, the Haskell runtime might move the object anywhere in the memory at any time.) [#]

Therefore, creating a StablePtr for an AppState object and passing it to C is a nice way to keep a hold of the backend. You can then modify Agda/Haskell functions to accept StablePtrs instead of the AppStates themselves, enabling them to be exported to C. The tools ``stablePtrise``, ``stablePtrise2`` and ``stablePtrise3`` in Tool.Foreign can make this easier.

Just don't forget to free the StablePtr retrieved! You can, however, use the ``hs_free_stable_ptr`` function family in TinyHsFFI.h without making a call to Haskell (which would be much more expensive).

For more details, see the `Haskell documentation <https://hackage.haskell.org/package/base-4.20.0.1/docs/Foreign-StablePtr.html>`_.

You can make interaction and cleanup much easier by creating a RAII class in C++ which wraps the StablePtr, creating and freeing it whenever needed. See :ref:`backend-interface` in the frontend for more information.

.. [#] Actually, StablePtrs are rather identifiers that the runtime stores in a table, looking them up whenever requested. They need not even be valid memory addresses (and they usually aren't, even though their type is ``void*`` in C). (Therefore, do not try to derefer them by hand in C; this will cause undefined behaviour.) However, it is guaranteed that the referred object will not be moved or deleted by the runtime until the StablePtr is freed.
