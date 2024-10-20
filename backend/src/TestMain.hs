-- A main program for running the Haskell QuickCheck tests.
-- Has to be written directly in Haskell;
-- otherwise, agda2hs and cabal do not really work together
-- to find the Main module.

module Main where

import System.Exit
import Test.QuickCheck

import Test.Haskell.Parity

-- All modules' testAll functions will be called here.
main :: IO ()
main = do
  success <- parityTestAll
  if success then exitSuccess else exitFailure
