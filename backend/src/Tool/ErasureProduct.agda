-- Custom product types with various forms of erasure.
{-# OPTIONS --erasure #-}

module Tool.ErasureProduct where

open import Agda.Primitive

-- A sigma type (especially the existence quantifier)
-- with a non-erased value member and an erased proof member.
-- ∃0 will often be used throughout the library as a shortening.
record S0 {i j} (a : Set i) (@0 b : a → Set j) : Set (i ⊔ j) where
  no-eta-equality
  constructor _:&:_                      -- see https://stackoverflow.com/questions/10548170/what-characters-are-permitted-for-haskell-operators
  no-eta-equality
  field
    proj₁ : a
    @0 proj₂ : b proj₁
-- And sorry, you'll have to use _:&:_ instead of _,_.
open S0 public
infixr 4 _:&:_
{-# COMPILE AGDA2HS S0 newtype #-}
{-# FOREIGN AGDA2HS
infixr 4 :&:
#-}

∃0 : ∀ {a b} {A : Set a} → @0 (A → Set b) → Set (a ⊔ b)
∃0 = S0 _            -- it makes strange things from this...

-- it's odd, but that is how it works
Tuple0 : ∀ {i j} (a : Set i) → (@0 b : Set j) → Set (i ⊔ j)
Tuple0 a b = S0 a (λ _ → b)
{-# COMPILE AGDA2HS Tuple0 #-}

-- A record type which has both members compiled,
-- but the argument of the lambda is erased;
-- so that it won't be dependent-typed after compilation.
-- Haskell doesn't allow multiple constructors or destructors with the same name; hence the ' after the names.
record S' {i j} (a : Set i) (b : @0 a → Set j) : Set (i ⊔ j) where
  no-eta-equality
  constructor _:^:_                      -- see https://stackoverflow.com/questions/10548170/what-characters-are-permitted-for-haskell-operators
  no-eta-equality
  field
    proj₁' : a
    proj₂' : b proj₁'
open S' public
infixr 4 _:^:_
{-# COMPILE AGDA2HS S' #-}
{-# FOREIGN AGDA2HS
infixr 4 :^:
#-}

-- agda2hs gets confused over this operator sometimes;
-- so we need a prefix version (simply using _:^:_ does not work there).
-- Maybe this should rather be a pattern synonym,
-- but I have not tested that with agda2hs yet.
prefixCon : ∀ {i} {j} {a : Set i} {b : @0 a → Set j} -> (x : a) -> b x -> S' a b
prefixCon = _:^:_
{-# COMPILE AGDA2HS prefixCon #-}
