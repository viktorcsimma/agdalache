-- Fractions of semirings.
{-# OPTIONS --erasure #-}

module Implementation.Frac where

{-# FOREIGN AGDA2HS {-# LANGUAGE MultiParamTypeClasses #-}

import qualified Prelude
import Prelude (Integer, Bool, otherwise, fromIntegral, ($), (&&), (||))

import Algebra.Field
import Operator.Cast
import Implementation.Nat
import Implementation.Int
import Operator.Shift

#-}

open import Tool.Cheat

open import Agda.Builtin.Equality
open import Agda.Builtin.Nat using (Nat; zero; suc)
open import Agda.Builtin.Int using (Int; pos; negsuc)
open import Haskell.Prim using (⊥; id; if_then_else_)
open import Haskell.Prim.Bool
open import Haskell.Prim.Tuple
open import Haskell.Prim.Either

open import Tool.PropositionalEquality
import Implementation.Nat as Nat
open import Implementation.Int
open import Algebra.Setoid
open import Algebra.SemiRing
open import Algebra.Ring
open import Algebra.Field
open import Algebra.Order
open import Operator.Decidable
open import Operator.Abs
open import Operator.Cast
open import Operator.ShiftL
open import Operator.Shift
open import Operator.ExactShift
open import Operator.Pow

-- Since we don't use classes below SemiRing to maintain
-- Haskell compatibility (by avoiding to give operators as parameters);
-- the constraint here is SemiRing a.
record Frac (a : Set) {{semiRing : SemiRing a}} : Set where
  constructor MkFrac
  field
    num den : a
    @0 denNotNull : NonZero den
open Frac public
{-# COMPILE AGDA2HS Frac #-}

-- Now the instances.

instance
  -- But hey, how is this going to be compiled to Haskell?
  {-
  -- Of course, we can extract a Setoid instance from a SemiRing instance;
  -- we'll do this in defaultSetoidFrac.
  -- However, sometimes we need the Setoid instance extracted from another
  -- instance argument (e. g. strongSetoidFrac).
  -- Therefore, we define this separately.
  -- And here, the Setoid argument is made explicit.
  setoidFrac : ∀ {a : Set} {{semiRing : SemiRing a}} {setoid : Setoid} a -> Setoid (Frac a)
  Setoid._≃_ (setoidFrac setoid) x y = _≃_ {{setoid}} (num x * den y) (num y * den x)
  Setoid.≃-refl (setoidFrac setoid) {x} = ≃-refl {{setoid}} {x = num x * den x}
  Setoid.≃-sym (setoidFrac setoid) {x} {y} = {!≃-sym {{setoid}} {x = num x * den y} {y = num y * den x}!}
  Setoid.≃-trans (setoidFrac setoid) = {!!}
  -}

  setoidFrac : ∀ {a : Set} {{semiRing : SemiRing a}} -> Setoid (Frac a)
  Setoid._≃_ (setoidFrac {a}) x y = num x * den y ≃ num y * den x
  Setoid.≃-refl (setoidFrac {a}) {x} = ≃-refl {x = num x * den x}
  Setoid.≃-sym (setoidFrac {a}) {x} {y} = ≃-sym {x = num x * den y} {y = num y * den x}
  -- num x * den z = 
  Setoid.≃-trans (setoidFrac {a}) {x} {y} {z} x≃y y≃z = cheat
  {-# COMPILE AGDA2HS setoidFrac #-}

  decSetoidFrac : ∀ {a : Set} {{semiRing : SemiRing a}} {{decSetoid : DecSetoid a}}
                      -> DecSetoid (Frac a)
  DecSetoid.setoid decSetoidFrac = setoidFrac
  DecSetoid._≃#_ decSetoidFrac x y = num x * den y ≃# num y * den x
  DecSetoid.≃#-correct decSetoidFrac = cheat
  {-# COMPILE AGDA2HS decSetoidFrac #-}

  -- Here come the problems.
  -- It wants to use the _≃_ from the SemiRing instance,
  -- and I don't know how to convince it that it's equal
  -- to the one in the StrongSetoid instance.
  strongSetoidFrac : ∀ {a : Set} {{semiRing : SemiRing a}} {{strongSetoid : StrongSetoid a}}
                                     -> StrongSetoid (Frac a)
  StrongSetoid.super (strongSetoidFrac {{strongSetoid = strongSetoid}}) = setoidFrac
  StrongSetoid._><_ strongSetoidFrac x y = num x * den y >< num y * den x
  StrongSetoid.><-irrefl strongSetoidFrac = cheat
  StrongSetoid.><-sym strongSetoidFrac {x} {y} = ><-sym {x = num x * den y} {y = num y * den x}
  StrongSetoid.><-cotrans strongSetoidFrac = cheat
  StrongSetoid.><-tight-apart strongSetoidFrac = cheat
  {-# COMPILE AGDA2HS strongSetoidFrac #-}

  semiRingFrac : ∀ {a : Set} {{semiRing : SemiRing a}} -> SemiRing (Frac a)
  SemiRing.super semiRingFrac = setoidFrac
  SemiRing._+_ semiRingFrac x y = MkFrac (num x * den y + num y * den x) (den x * den y) cheat
  SemiRing._*_ semiRingFrac x y = MkFrac (num x * num y) (den x * den y) cheat
  SemiRing.+-proper semiRingFrac = cheat
  SemiRing.+-assoc semiRingFrac = cheat
  SemiRing.*-proper semiRingFrac = cheat
  SemiRing.*-assoc semiRingFrac = cheat
  SemiRing.null (semiRingFrac {a}) = MkFrac null one (NonZeroOne {a})
  SemiRing.one (semiRingFrac {a}) = MkFrac one one (NonZeroOne {a})
  SemiRing.NonZero (semiRingFrac {a}) x = NonZero (num x)
  SemiRing.NonZeroCorrect (semiRingFrac {a}) x = cheat
  SemiRing.NonZeroOne (semiRingFrac {a}) = NonZeroOne {a}
  SemiRing.+-identityˡ semiRingFrac x = cheat
  SemiRing.+-identityʳ semiRingFrac = cheat
  -- one * num x * den x ≃ num x * (one * den x)
  SemiRing.*-identityˡ semiRingFrac x = cheat
  SemiRing.*-identityʳ semiRingFrac = cheat
  SemiRing.+-comm semiRingFrac = cheat
  SemiRing.*-comm semiRingFrac = cheat
  SemiRing.*-nullˡ semiRingFrac = cheat
  SemiRing.*-nullʳ semiRingFrac = cheat
  SemiRing.*-distribˡ-+ semiRingFrac = cheat
  SemiRing.*-distribʳ-+ semiRingFrac = cheat
  {-# COMPILE AGDA2HS semiRingFrac #-}

  ringFrac : ∀ {a : Set} {{ring : Ring a}} -> Ring (Frac a)
  Ring.super ringFrac = semiRingFrac
  Ring.negate ringFrac x = MkFrac (negate (num x)) (den x) (denNotNull x)
  Ring.+-inverseˡ ringFrac x = cheat
  Ring.+-inverseʳ ringFrac = cheat
  {-# COMPILE AGDA2HS ringFrac #-}

  -- It's enough that a is a ring and a strong setoid; it need not be a field.
  fieldFrac : ∀ {a : Set} {{ring : Ring a}} {{strongSetoid : StrongSetoid a}}
                                              -> Field (Frac a)
  Field.ring fieldFrac = ringFrac
  Field.strongSetoid fieldFrac = strongSetoidFrac
  Field.+-strong-proper fieldFrac x y z w apart = cheat  -- can we use the former instance?
  Field.*-strong-proper fieldFrac x y z w apart = cheat
  Field.recip (fieldFrac {a}) x nApNull = MkFrac (den x) (num x) cheat -- {!fst (trivialApart (num x) null) nApNull!}
  Field.recip-proper fieldFrac xApNull yApNull = cheat
  Field.*-inverseˡ fieldFrac xApNull = cheat
  Field.*-inverseʳ fieldFrac xApNull = cheat
  {-# COMPILE AGDA2HS fieldFrac #-}

  -- Order instances
  -- The denominator might be negative; so we have to check that.
  leFrac : ∀ {a : Set} {{semiRing : SemiRing a}} {{le : Le a}} -> Le (Frac a)
  Le._≤_ leFrac x y = Either (null ≤ den x * den y × num x * den y ≤ num y * den x)
                             (den x * den y ≤ null × num y * den x ≤ num x * den y)
  {-# COMPILE AGDA2HS leFrac #-}

  decLeFrac : ∀ {a : Set} {{semiRing : SemiRing a}} {{decLe : DecLe a}} -> DecLe (Frac a)
  DecLe.le decLeFrac = leFrac
  DecLe._≤#_ decLeFrac x y = (null ≤# den x * den y && num x * den y ≤# num y * den x) ||
                             (den x * den y ≤# null && num y * den x ≤# num x * den y)
  DecLe.≤#-correct decLeFrac x y = cheat
  {-# COMPILE AGDA2HS decLeFrac #-}

  partialOrderFrac : ∀ {a : Set} {{semiRing : SemiRing a}} {{partialOrder : PartialOrder a}}
                            -> PartialOrder (Frac a)
  PartialOrder.le partialOrderFrac = leFrac
  PartialOrder.setoid partialOrderFrac = setoidFrac
  PartialOrder.≤-proper partialOrderFrac = cheat
  {-# COMPILE AGDA2HS partialOrderFrac #-}

  ltFrac : ∀ {a : Set} {{semiRing : SemiRing a}} {{lt : Lt a}} -> Lt (Frac a)
  Lt._<_ ltFrac x y = Either (null < den x * den y × num x * den y < num y * den x)
                             (den x * den y < null × num y * den x < num x * den y)
  {-# COMPILE AGDA2HS ltFrac #-}

  decLtFrac : ∀ {a : Set} {{semiRing : SemiRing a}} {{decLt : DecLt a}} -> DecLt (Frac a)
  DecLt.lt decLtFrac = ltFrac
  DecLt._<#_ decLtFrac x y = (null <# den x * den y && num x * den y <# num y * den x) ||
                             (den x * den y <# null && num y * den x <# num x * den y)
  DecLt.<#-correct decLtFrac x y = cheat
  {-# COMPILE AGDA2HS decLtFrac #-}

  strictOrderFrac : ∀ {a : Set} {{semiRing : SemiRing a}} {{strictOrder : StrictOrder a}}
                                      -> StrictOrder (Frac a)
  StrictOrder.lt strictOrderFrac = ltFrac
  StrictOrder.setoid strictOrderFrac = setoidFrac
  -- Even here, it would like to use the Setoid instance from semiRing, not from strictOrder.
  -- I don't yet understand why; <-irrefl should specifically work with the strictOrder instance.
  StrictOrder.<-irrefl strictOrderFrac {x} {y} x≃y = cheat
  StrictOrder.<-trans strictOrderFrac = cheat
  StrictOrder.<-proper strictOrderFrac = cheat
  {-# COMPILE AGDA2HS strictOrderFrac #-}

  pseudoOrderFrac : ∀ {a : Set} {{semiRing : SemiRing a}} {{pseudoOrder : PseudoOrder a}}
                                      -> PseudoOrder (Frac a)
  PseudoOrder.strongSetoid pseudoOrderFrac = strongSetoidFrac
  PseudoOrder.lt pseudoOrderFrac = ltFrac
  PseudoOrder.<-asym pseudoOrderFrac {x} {y} = cheat
  PseudoOrder.<-cotrans pseudoOrderFrac x<y z = cheat
  PseudoOrder.<-total pseudoOrderFrac = cheat
  {-# COMPILE AGDA2HS pseudoOrderFrac #-}

  -- Abs already implies Ring and Le..
  absFrac : ∀ {a : Set} {{absa : Abs a}} -> Abs (Frac a)
  Abs.ring (absFrac) = ringFrac
  Abs.le (absFrac) = leFrac
  Abs.abs absFrac (MkFrac numx denx denNotNullx) = MkFrac (abs numx) (abs denx) cheat
  Abs.absCorrect absFrac x = cheat
  {-# COMPILE AGDA2HS absFrac #-}

  castFrac : ∀ {a : Set} {{semiRing : SemiRing a}} -> Cast a (Frac a)
  Cast.cast (castFrac {a}) x = MkFrac x one (NonZeroOne {a})
  {-# COMPILE AGDA2HS castFrac #-}

  natPowFrac : ∀ {a : Set} {{semiRing : SemiRing a}} {{natPow : Pow a Nat}} -> Pow (Frac a) Nat
  (natPowFrac Pow.^ MkFrac numx denx denNotNullx) n = MkFrac (numx ^ n) (denx ^ n) cheat
  Pow.powProper natPowFrac = cheat
  Pow.powNull natPowFrac = cheat
  Pow.powSuc natPowFrac = cheat
  {-# COMPILE AGDA2HS natPowFrac #-}

  {-
  How can we assure that num x is not null?
  intPowFrac : ∀ {a : Set} {{semiRing : SemiRing a}} {{natPow : Pow a Nat}} -> Pow (Frac a) Int
  (intPowFrac Pow.^ x) (pos n) = MkFrac (num x ^ n) (den x ^ n) cheat
  (intPowFrac Pow.^ x) (negsuc n) = {!MkFrac (!}
  Pow.powProper intPowFrac = {!!}
  Pow.powNull intPowFrac = {!!}
  Pow.powSuc intPowFrac = {!!}
  {-# COMPILE AGDA2HS intPowFrac #-}
  -}

  shiftLFrac : ∀ {a : Set} {{shiftLa : ShiftL a}} -> ShiftL (Frac a)
  ShiftL.semiringa shiftLFrac = semiRingFrac
  ShiftL.shiftl shiftLFrac p n = MkFrac (shiftl (num p) n) (den p) (denNotNull p)
  ShiftL.shiftlProper shiftLFrac = cheat
  ShiftL.shiftlNull shiftLFrac = cheat
  ShiftL.shiftlSuc shiftLFrac = cheat
  {-# COMPILE AGDA2HS shiftLFrac #-}

  shiftFrac : ∀ {a : Set} {{shiftLa : ShiftL a}} -> Shift (Frac a)
  Shift.super shiftFrac = shiftLFrac
  Shift.shift shiftFrac p (pos n) = shiftl p n
  Shift.shift shiftFrac p (negsuc n) = MkFrac (num p) (shiftl (den p) (suc n)) cheat
  Shift.shiftProper shiftFrac = cheat
  Shift.shiftEquivalent shiftFrac p n = cheat
  Shift.shiftLeftThenRight shiftFrac = cheat
  {-# FOREIGN AGDA2HS
  instance ShiftL a => Shift (Frac a) where
    shift p x
      | 0  ≤# x       = shiftl p (fromIntegral x)
      | otherwise    = MkFrac (num p) (shiftl (den p) (Prelude.fromIntegral $ (-1) * x))
  #-}

  exactShiftFrac : ∀ {a : Set} {{shiftLa : ShiftL a}} -> ExactShift (Frac a)
  ExactShift.super exactShiftFrac = shiftFrac
  ExactShift.shiftRightThenLeft exactShiftFrac = cheat
  {-# COMPILE AGDA2HS exactShiftFrac #-}
