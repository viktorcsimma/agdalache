*******
Testing
*******

Agda and Haskell have nice and unique tools for testing,
and the Agda SDK provides ways to take advantage of both.

**********
Agda tests
**********

An example test file can be found
under Test.ExampleTest,
but this is technically just like any other Agda source file.
The main difference is that it does not have any agda2hs pragmas;
therefore, no .hs file gets generated
(and so it should not be added to Haskell imports in All.agda).

Agda provides a tool that not many other languages do:
the use of propositional equality (`_≡_`)
enables the typechecker to check propositions
even before compilation.
For example::

  @0 test : f 2 10 ≡ 8
  test = refl

If Agda itself can calculate `f 2 10` and finds it to be equal to `8`,
then this compiles; otherwise, you get an error message.

The disadvantage of this approach is that you need very concrete values
in each test case,
such that Agda can deduce equality by itself.
Otherwise, you actually need to write proofs
rather than tests.

****************
QuickCheck tests
****************

The test files under Test.Haskell.*
utilise the QuickCheck testing framework,
which generates several random input values
and testing certain propositions on them.
Actually, those propositions can be written in Agda.

An example::

  prop_f : Integer -> Integer -> Bool
  prop_f x y = g x x y == y
  {-# COMPILE AGDA2HS prop_correctWithTwoEven #-}

For this, QuickCheck will generate random integers
and check whether the proposition returns True for all of them.

At the end of the file, we have to list all our propositions in a foreign pragma::

  {-# FOREIGN AGDA2HS
  -- This contains all the propositions we would like to test.
  -- Actually, this will be called by main.
  exampleTestAll :: IO Bool
  exampleTestAll =
    and <$> mapM (isSuccess <$>)
    [ quickCheckResult prop_f
    , quickCheckResult prop_whatever
    , quickCheckResult prop_whatever2
    -- ...
    ]
  #-}

In turn, `exampleTestAll` (or whatever we name it)
should be called by the main function in src/TestMain.hs::

  main :: IO ()
  main = do
    success <- and <$> mapM id
                 -- here come all the test modules
                 [ exampleTestAll
                 --, ...
                 ]
    if success then exitSuccess else exitFailure

If you need to generate random inputs of types
other than some basic Haskell types,
you might need to define an Arbitrary instance
for the given type.
See the documentation of QuickCheck for more details:
https://hackage.haskell.org/package/QuickCheck.
