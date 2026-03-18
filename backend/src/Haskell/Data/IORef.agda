-- Files with a Haskell prefix do not compile to Haskell code;
-- instead, the default paths will be used.
{-# OPTIONS --erasure #-}

module Haskell.Data.IORef where

open import Agda.Builtin.Unit
open import Haskell.Prim.IO
open import Haskell.Prim.Tuple

postulate
  IORef : ∀{i} -> Set i → Set i

  newIORef : ∀{i}{a : Set i} → a → IO (IORef a)
  readIORef : ∀{i}{a : Set i} → IORef a → IO a
  writeIORef : ∀{i}{a : Set i} → IORef a → a → IO ⊤
  modifyIORef modifyIORef' : ∀{i}{a : Set i} → IORef a → (a → a) → IO ⊤
  atomicModifyIORef atomicModifyIORef' : {a b : Set} → IORef a → (a → (a × b)) → IO b
  atomicWriteIORef : ∀{i}{a : Set i} → IORef a → a → IO ⊤
