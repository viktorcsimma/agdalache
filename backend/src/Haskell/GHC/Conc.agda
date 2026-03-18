-- It's only for PrimMVar now.

{-# OPTIONS --erasure #-}
module Haskell.GHC.Conc where
open import Haskell.Foreign.StablePtr
open import Haskell.Control.Concurrent.MVar
open import Haskell.Prelude

postulate
  PrimMVar : Set
  newStablePtrPrimMVar : {a : Set} -> MVar a → IO (StablePtr PrimMVar)
