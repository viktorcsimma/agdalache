-- Simulating the interface of Ptrs, ForeignPtrs and IntPtrs
-- with postulates.
-- See https://hackage.haskell.org/package/base-4.20.0.1/docs/Foreign-Ptr.html.
{-# OPTIONS --erasure #-}
module Haskell.Foreign.Ptr where

open import Agda.Builtin.Unit
open import Haskell.Prim.Int
open import Haskell.Prim.IO

postulate
  Ptr : ∀{i} → Set i → Set i

  nullPtr : ∀{i}{a : Set i} → Ptr a
  castPtr : ∀{i j}{a : Set i}{b : Set j} → Ptr a → Ptr b
  plusPtr : ∀{i j}{a : Set i}{b : Set j} → Ptr a → Int → Ptr b
  alignPtr : ∀{i}{a : Set i} → Ptr a → Int → Ptr a
  minusPtr : ∀{i j}{a : Set i}{b : Set j} → Ptr a → Ptr b → Int

  FunPtr : ∀{i} → Set i → Set i
  nullFunPtr : ∀{i}{a : Set i} → FunPtr a
  castFunPtr : ∀{i j}{a : Set i}{b : Set j} → FunPtr a → FunPtr b
  castFunPtrToPtr : ∀{i j}{a : Set i}{b : Set j} → FunPtr a → Ptr b
  castPtrToFunPtr : ∀{i j}{a : Set i}{b : Set j} → Ptr a → FunPtr b
  freeHaskellFunPtr : ∀{i}{a : Set i} → FunPtr a → IO ⊤

  IntPtr WordPtr : Set
  ptrToIntPtr : ∀{i}{a : Set i} → Ptr a → IntPtr
  intPtrToPtr : ∀{i}{a : Set i} → IntPtr → Ptr a
  ptrToWordPtr : ∀{i}{a : Set i} → Ptr a → WordPtr
  wordPtrToPtr : ∀{i}{a : Set i} → WordPtr → Ptr a
