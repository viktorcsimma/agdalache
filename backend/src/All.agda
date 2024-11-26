-- This imports all the modules.
-- When calling agda2hs on this file,
-- it compiles everything.
{-# OPTIONS --erasure --guardedness #-}

module All where

-- Import all modules you want to be typechecked
-- in Agda;
-- then import all modules you want to get compiled
-- in Haskell.

import AppState
import Interaction
import Logic

import Tool.ErasureProduct
import Tool.Cheat
import Tool.PropositionalEquality
import Tool.Relation
import Tool.Future

-- The tests;
-- they only get here to be checked by the typechecker,
-- but we do not want GHC to compile the empty files generated.
import Test.ExampleTest
import Test.Haskell.ExampleTest

import Platform.Win32
import Platform.Posix

-- And now, the modules for which there is a Haskell cognate
-- that we want to compile.
{-# FOREIGN AGDA2HS
{-# LANGUAGE CPP #-}
import AppState
import Interaction
import Logic

import Tool.ErasureProduct
import Tool.Future
-- import Tool.Cheat                    -- this is empty
-- import Tool.PropositionalEquality    -- this is empty
import Platform
-- This cannot be put here; CMake's GHC would search for QuickCheck.
-- import Test.Haskell.ExampleTest
#-}
