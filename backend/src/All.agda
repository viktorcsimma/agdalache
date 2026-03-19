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
-- this does not have a .agda file
-- import Platform
import Platform.Win32
import Platform.Posix

-- And now, the modules for which there is a Haskell cognate
-- that we want to compile.
{-# FOREIGN AGDA2HS
{-# LANGUAGE CPP #-}
import AppState
import Interaction

import Tool.ErasureProduct
-- import Tool.Cheat                    -- this would be empty
-- import Tool.PropositionalEquality    -- this would be empty
import Platform
-- This cannot be put here; CMake's GHC would search for QuickCheck.
-- import Test.Haskell.ExampleTest
#-}
