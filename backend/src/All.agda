-- This imports all the modules.
-- When calling agda2hs on this file,
-- it compiles everything.
{-# OPTIONS --erasure --guardedness #-}

module All where

-- This command helped (ran in src):
-- find . -name '*.agda' | sed 's/\.\///g' | sed 's/\.agda//g' | sed 's/\//\./g' | sed 's/^/import /g'

import AppState
import Interaction
import Logic

import Tool.ErasureProduct
import Tool.Cheat
import Tool.PropositionalEquality
import Tool.Relation
import Tool.Future
-- this does not have a .agda file
-- import Platform
import Platform.Win32
import Platform.Posix
-- the tests;
-- they only get here to be checked by the typechecker,
-- but we do not want GHC to compile the empty files generated
import Test.Parity
import Test.Haskell.Parity

-- And now, we also copy them into the Haskell source;
-- this way, we can compile everything by compiling All.hs.
{-# FOREIGN AGDA2HS
{-# LANGUAGE CPP #-}
import AppState
import Interaction
import Logic

import Tool.ErasureProduct
import Tool.Future
-- import Tool.Cheat                    -- this would be empty
-- import Tool.PropositionalEquality    -- this would be empty
import Platform
-- This cannot be put here; CMake's GHC would search for QuickCheck.
-- import Test.Haskell.Parser
#-}
