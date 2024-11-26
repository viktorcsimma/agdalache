-- Custom product types with various forms of erasure.
{-# OPTIONS --erasure #-}

module Tool.ErasureProduct where

open import Agda.Primitive

-- A sigma type (especially the existence quantifier)
-- with a non-erased value member and an erased proof member.
record Σ0 {i j} (a : Set i) (@0 b : a → Set j) : Set (i ⊔ j) where
  constructor _:&:_                      -- see https://stackoverflow.com/questions/10548170/what-characters-are-permitted-for-haskell-operators
  field
    proj₁ : a
    @0 proj₂ : b proj₁
-- And sorry, you'll have to use _:&:_ instead of _,_.
open Σ0 public
infixr 4 _:&:_
{-# COMPILE AGDA2HS Σ0 newtype #-}
{-# FOREIGN AGDA2HS
infixr 4 :&:
#-}

-- A record type which has both members compiled,
-- but the argument of the lambda is erased;
-- so that it won't be dependent-typed after compilation.
record Σ' {i j} (a : Set i) (b : @0 a → Set j) : Set (i ⊔ j) where
  constructor _:^:_                      -- see https://stackoverflow.com/questions/10548170/what-characters-are-permitted-for-haskell-operators
  field
    proj₁' : a
    proj₂' : b proj₁'
open Σ' public
infixr 4 _:^:_
{-# COMPILE AGDA2HS Σ' #-}
{-# FOREIGN AGDA2HS
infixr 4 :^:
#-}

-- agda2hs gets confused over this operator sometimes;
-- so we need a prefix version (simply using _:^:_ does not work there).
-- Maybe this should rather be a pattern synonym,
-- but I have not tested that with agda2hs yet.
prefixCon : ∀ {i} {j} {a : Set i} {b : @0 a → Set j} -> (x : a) -> b x -> Σ' a b
prefixCon = _:^:_
{-# COMPILE AGDA2HS prefixCon #-}
