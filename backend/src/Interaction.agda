-- A file which contains
-- most of the interface of the application
-- to the C/C++ side.
{-# OPTIONS --erasure --guardedness #-}

module Interaction where

{-# FOREIGN AGDA2HS

{-# LANGUAGE ForeignFunctionInterface, ScopedTypeVariables #-}

#-}

open import Haskell.Prelude

open import Haskell.Data.IORef
open import Haskell.Foreign.StablePtr
open import Haskell.Foreign.Ptr
open import Haskell.Foreign.C.Types

open import AppState
open import Logic
open import Tool.Foreign
open import Tool.Future

-- Initialises the application state, with 0 as counter value.
-- Required type constraints have to be provided here, too.
initApp : {a : Set} {{num : Num a}} -> IO (StablePtr (AppState a))
initApp = newStablePtr =<< (MkAppState <$> newIORef 0)
{-# COMPILE AGDA2HS initApp #-}

-- Now, concrete instantiations
-- which can be exported.
initAppInteger : IO (StablePtr (AppState Integer))
initAppInteger = initApp
{-# COMPILE AGDA2HS initAppInteger #-}
-- And for example:
-- initAppDouble :: IO (StablePtr (AppState Double))
-- ...

-- Destruction of the StablePtr from the C side
-- is done by the hs_free_stable_ptr function.

{-# FOREIGN AGDA2HS
-- And the export clauses for each function you would like to use in C/C++.

foreign export ccall initAppInteger :: IO (StablePtr (AppState Integer))
#-}
