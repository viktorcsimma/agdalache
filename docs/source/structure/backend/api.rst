.. _api:

***********
Backend API
***********

.. highlight:: agda

Unless you only need a console application with no C++ frontend whatsoever,
you will have to write a public interface
through which the frontend can use the backend --
basically, an API.
This is possible via Haskell's foreign exports.

Exporting from Agda
-------------------

You are free to export a function from any Agda (or Haskell) file;
the skeleton project uses Interaction.agda for this.
For example, take a look at the function
initialising the AppState object::

  initApp : {a : Set} {{num : Num a}} -> IO (StablePtr (AppState a))
  initApp = newStablePtr =<< (MkAppState <$> newIORef 0)
  {-# COMPILE AGDA2HS initApp #-}

  -- Since ``a`` has a type constraint,
  -- we cannot simply export initApp
  -- without defining a concrete instance.
  initAppInteger : IO (StablePtr (AppState Integer))
  initAppInteger = initApp
  {-# COMPILE AGDA2HS initAppInteger #-}

  ...

  -- And the export statement:
  {-# FOREIGN AGDA2HS
  foreign export ccall initAppInteger :: IO (StablePtr (AppState Integer))
  #-}

In essence, the same rules have to be followed as with the Haskell FFI;
see the `GHC User's Guide <https://ghc.gitlab.haskell.org/ghc/doc/users_guide/exts/ffi.html>`_
for details.

In case you need the C foreign types such as CInt or CChar,
you can find them under Haskell.Foreign.C.Types in the agda2hs library.
Also, the skeleton project includes a module called Tool.Foreign;
this provides some simple conversion functions from and to CInt.
Feel free to expand these with foreign types of your choice.

When using an application with a mutable state,
you will probably use StablePtrs extensively.
See the :ref:`appstate` chapter for more information,
as well as the documentation of the `Foreign.StablePtr <https://hackage.haskell.org/package/base-4.20.0.1/docs/Foreign-StablePtr.html>`_ module.

C headers
---------

In order to *really* be able to use these functions from C/C++,
you need headers.

Fortunately, GHC can generate these for you:
after running a build through CMake,
you find all the stubs under ``backend/build/stub``.
However, for these to work,
you need to copy them into backend/include
and **add** ``#include TinyHsFFI.h``.
The reason for this is that
this header contains the type synonyms
that Haskell uses.

Take ``Future.h`` as an example::

  #ifndef FUTURE_H_
  #define FUTURE_H_

  /* ... */
  
  #include "TinyHsFFI.h"

  #if defined(__cplusplus)
  extern "C" {
  #endif

  extern int getCIntFromFutureC(HsPtr a1);
  extern void waitForVoidFutureC(HsPtr a1);
  extern HsPtr getPtrFromFutureC(HsPtr a1);
  
  #if defined(__cplusplus)
  }
  #endif

  #endif

You are free to write the headers by yourself
if you wish.
However, they should be in this format
and the type signatures ought to be correct.
