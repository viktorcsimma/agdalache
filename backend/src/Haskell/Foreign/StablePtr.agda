-- Mimicking the functionality of a StablePtr
-- with postulates.
-- Needed for foreign interfaces to C and C++ frontends.
{-# OPTIONS --erasure #-}

module Haskell.Foreign.StablePtr where

open import Agda.Builtin.Unit
open import Haskell.Prim.IO
open import Haskell.Prim.Monad
open import Haskell.Prim using (_≡_)

postulate
  StablePtr : ∀{i} → Set i → Set i

  newStablePtr : ∀{i}{a : Set i} → a → IO (StablePtr a)
  deRefStablePtr : ∀{i}{a : Set i} → StablePtr a → IO a
  freeStablePtr : ∀{i}{a : Set i} → StablePtr a → IO ⊤

  -- As StablePtrs cannot be reset to something else:
  @0 deRefNewStablePtrIsId : ∀{a : Set} (x : a) -> deRefStablePtr =<< (newStablePtr x) ≡ return x
