-- Some tests with the QuickCheck Haskell library.
-- Here, you can finely integrate Agda code
-- with the functions and random generators of QuickCheck.

-- You can run these tests through `cabal test`.

{-# OPTIONS --erasure #-}
module Test.Haskell.ExampleTest where
{-# FOREIGN AGDA2HS {-# LANGUAGE StandaloneDeriving #-} #-}

open import Haskell.Prelude


open import Logic

{-# FOREIGN AGDA2HS
import Test.QuickCheck
#-}

-- We would need an Arbitrary instance for the naturals
-- if we wanted to do tests on them.
-- {-# FOREIGN AGDA2HS
-- instance Arbitrary Natural where
--   arbitrary = arbitrarySizedNatural
--   shrink = shrinkIntegral
-- #-}
-- See also QuickCheck's documentation
-- for defining generators.


-- Actually, we can write the functions themselves in Agda.

-- The format is like this
-- (for testing that the proposition holds
-- for any randomly generated Integer):
{-
prop_f : Integer -> Integer -> Bool
prop_f x y = ...
{-# COMPILE AGDA2HS prop_correctWithTwoEven #-}
-}

{-# FOREIGN AGDA2HS
-- This contains all the propositions we would like to test.
-- Actually, this will be called by main.
exampleTestAll :: IO Bool
exampleTestAll =
  and <$> mapM (isSuccess <$>)
  -- here you can list your tests
  -- see also QuickCheck's documentation
  [ -- quickCheckResult prop_f
  -- , ...
  ]
#-}

