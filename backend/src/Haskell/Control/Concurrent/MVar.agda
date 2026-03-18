-- Simulating MVars
-- with postulates.
-- See https://hackage.haskell.org/package/base-4.20.0.1/docs/Control-Concurrent-MVar.html.
{-# OPTIONS --erasure #-}
module Haskell.Control.Concurrent.MVar where

open import Haskell.Prelude

postulate
  MVar : Set → Set
  instance
    -- "Compares the underlying pointers."
    iEqMVar : Eq (MVar a)
  newEmptyMVar : IO (MVar a)
  newMVar : a → IO (MVar a)
  takeMVar readMVar : MVar a → IO a
  putMVar : MVar a → a → IO ⊤
  swapMVar : MVar a → a → IO a
  tryTakeMVar tryReadMVar : MVar a → IO (Maybe a)
  tryPutMVar : MVar a → a → IO Bool
  isEmptyMVar : MVar a → IO Bool
  withMVar withMVarMasked : MVar a → (a → IO b) → IO b
  modifyMVar_ modifyMVarMasked_ : MVar a → (a → IO a) → IO ⊤
  modifyMVar modifyMVarMasked : MVar a → (a → IO (a × b)) → IO b
  addMVarFinalizer : MVar a → IO ⊤ → IO ⊤
