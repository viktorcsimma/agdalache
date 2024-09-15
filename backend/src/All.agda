-- This imports all the modules.
-- When calling agda2hs on this file,
-- it compiles everything.
{-# OPTIONS --erasure --guardedness #-}

module All where

-- This command helped (ran in src):
-- find . -name '*.agda' | sed 's/\.\///g' | sed 's/\.agda//g' | sed 's/\//\./g' | sed 's/^/import /g'

import Operator.ShiftL
import Operator.Cast
import Operator.Decidable
import Operator.Pow
import Operator.Abs
import Operator.ExactShift
import Operator.Shift
import Tool.Relation
import Tool.ErasureProduct
import Tool.Cheat
import Tool.Stream
import Tool.PropositionalEquality
import HaskellInstance.Show
-- these have to be explicitly removed for now,
-- as they confuse agda2hs
-- import HaskellInstance.Eq
-- import HaskellInstance.Number
-- import HaskellInstance.Num
-- import HaskellInstance.Fractional
-- import HaskellInstance.Floating
import HaskellInstance.NFData
import Algebra.Setoid
import Algebra.Order
import Algebra.SemiRing
import Algebra.Field
import Algebra.Ring
import RealTheory.AppRational
import RealTheory.Completion
import RealTheory.Instance.Cast
import RealTheory.Instance.Pow
import RealTheory.Continuity
import RealTheory.MetricSpace
import RealTheory.Real
import RealTheory.Interval
import Shell.Interaction
import Shell.Statement
import Shell.Exp
import Shell.Evaluation
import Shell.CalcState
import Shell.Parser
import Shell.Value
-- this does not have a .agda file
-- import Shell.Platform
import Shell.Platform.Win32
import Shell.Platform.Posix
import Implementation.Decimal
import Implementation.Int
import Implementation.Dyadic
import Implementation.Rational
import Implementation.Frac
import Implementation.Nat
import Function.SquareRoot
import Function.AlternatingSeries
import Function.Exp
import Function.Trigonometric
-- the tests;
-- they only get here to be checked by the typechecker,
-- but we do not want GHC to compile the empty files generated
import Test.Parser
import Test.Haskell.Parser

-- And now, we also copy them into the Haskell source;
-- this way, we can compile everything by compiling All.hs.
{-# FOREIGN AGDA2HS
{-# LANGUAGE CPP #-}
import Operator.ShiftL
import Operator.Cast
import Operator.Decidable
import Operator.Pow
import Operator.Abs
import Operator.ExactShift
import Operator.Shift
-- import Tool.Relation                 -- this would be empty
import Tool.ErasureProduct
-- import Tool.Cheat                    -- this would be empty
import Tool.Stream
-- import Tool.PropositionalEquality    -- this would be empty
import HaskellInstance.Show
-- these have to be explicitly removed for now,
-- as they confuse agda2hs
-- import HaskellInstance.Eq
-- import HaskellInstance.Number
-- import HaskellInstance.Num
-- import HaskellInstance.Fractional
-- import HaskellInstance.Floating
import HaskellInstance.NFData
import Algebra.Setoid
import Algebra.Order
import Algebra.SemiRing
import Algebra.Field
import Algebra.Ring
import RealTheory.AppRational
import RealTheory.Completion
import RealTheory.Instance.Cast
import RealTheory.Instance.Pow
import RealTheory.Continuity
import RealTheory.MetricSpace
import RealTheory.Real
-- import RealTheory.Interval           -- this would be empty
import Shell.Interaction
import Shell.Statement
import Shell.Exp
import Shell.Evaluation
import Shell.CalcState
import Shell.Parser
import Shell.Value
import Shell.Platform
import Implementation.Decimal
import Implementation.Int
import Implementation.Dyadic
import Implementation.Rational
import Implementation.Frac
import Implementation.Nat
import Function.SquareRoot
import Function.AlternatingSeries
import Function.Exp
import Function.Trigonometric
-- This cannot be put here; CMake's GHC would search for QuickCheck.
-- import Test.Haskell.Parser
#-}
