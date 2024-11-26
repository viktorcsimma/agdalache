-- Some simple Agda tests for demonstration.

-- If added to All.agda,
-- the typechecker checks them at every compilation.
{-# OPTIONS --erasure #-}
module Test.ExampleTest where

open import Agda.Builtin.Equality
open import Agda.Builtin.Int
open import Haskell.Prim.Either

open import Haskell.Prelude

open import Logic

-- Here, you can include any kind of test,
-- using _≡_.
-- These will be validated compile-time
-- by the typechecker.
-- For example:
{-
@0 test1 : f 2 10 ≡ 8
test1 = refl
-}
