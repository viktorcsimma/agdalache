-- Simulating the interface of the Storable type class.
-- Important for manipulating foreign pointers.
-- See https://hackage.haskell.org/package/base-4.16.1.0/docs/Foreign-Storable.html.
{-# OPTIONS --erasure #-}
module Haskell.Foreign.Storable where

open import Haskell.Prelude
open import Haskell.Foreign.Ptr
open import Haskell.Foreign.StablePtr

record Storable (a : Set) : Set₁ where
  field
    sizeOf : a -> Int      -- this does not really use the argument, but Haskell only likes it this way
    alignment : a -> Int   -- same here

    peek : Ptr a -> IO a
    peekElemOff : Ptr a -> Int -> IO a
    peekByteOff : {b : Set} -> Ptr b -> Int -> IO a

    poke : Ptr a -> a -> IO ⊤
    pokeElemOff : Ptr a -> Int -> a -> IO ⊤
    pokeByteOff : {b : Set} -> Ptr b -> Int -> a -> IO ⊤

    @0 constSize : ∀(x x' : a) → sizeOf x ≡ sizeOf x'
    @0 constAlignment : ∀(x x' : a) → alignment x ≡ alignment x'
{-
-- defaults, deriving from peek and poke:
record DefaultStorable (a : Set) : Set₁ where
  module M = Storable {a = a}
  field
    sizeOf : a -> Int
    alignment : a -> Int
    peek : Ptr a -> IO a
    poke : Ptr a -> a -> IO ⊤

    @0 constSize : ∀(x x' : a) → sizeOf x ≡ sizeOf x'
    @0 constAlignment : ∀(x x' : a) → alignment x ≡ alignment x'

  peekElemOff : Ptr a -> Int -> IO a
  peekElemOff = ?
  peekByteOff : {b : Set} -> Ptr b -> Int -> IO a
  peekByteOff addr off = peek (plusPtr addr off)
  pokeElemOff : Ptr a -> Int -> a -> IO ⊤
  pokeElemOff addr idx x = poke (plusPtr addr (idx * sizeOf x)) x
  pokeByteOff : {b : Set} -> Ptr b -> Int -> a -> IO ⊤
  pokeByteOff addr off x = poke (plusPtr addr off) x
-}
-- export
open Storable ⦃...⦄ public
{-# COMPILE AGDA2HS Storable existing-class #-}

{-
-- ** instances
private
  mkStorable : DefaultStorable a → Storable a
  mkStorable x = record {DefaultStorable x}
-}
instance
  postulate
    iStorableBool : Storable Bool
    iStorableChar : Storable Char
    iStorableDouble : Storable Double
    iStorableInt : Storable Int
    iStorableWord : Storable Word
    iStorableTop : Storable ⊤
    iStorableIntPtr : Storable IntPtr
    iStorableWordPtr : Storable WordPtr
    iStorableStablePtr : ∀{a : Set} → Storable (StablePtr a)
    iStorablePtr : ∀{a : Set} → Storable (Ptr a)
    iStorableFunPtr : ∀{a : Set} → Storable (FunPtr a)
