-- A data type which will contain
-- the variables of the application
-- in a mutable form.
-- A StablePtr to it will be passed to C++.
{-# OPTIONS --erasure --guardedness #-}

module AppState where

open import Haskell.Prelude
open import Haskell.Data.IORef

-- The AppState must be mutable (via IORefs)
-- because the C++ side will have a StablePtr
-- to the same instance
-- all the time.
-- That's why we cannot comfortably use
-- the State monad.

-- Here, add every variable you would like to persist
-- throughout the lifetime of your application,
-- within an IORef.
-- You can also add type variables,
-- like in this example.
record AppState (a : Set) : Set where
  constructor MkAppState
  field
    -- Here, you should include your variables
    -- (feel free to delete this one).
    counterRef   : IORef a
open AppState public
{-# COMPILE AGDA2HS AppState #-}

-- An AppState initialised with a given number.
-- Feel free to delete this example.
initAppState : {a : Set} {{num : Num a}} -> a -> IO (AppState a)
initAppState a = MkAppState <$> newIORef a
{-# COMPILE AGDA2HS initAppState #-}

