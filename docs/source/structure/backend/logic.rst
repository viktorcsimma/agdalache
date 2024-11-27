******************************
Writing business logic in Agda
******************************

By default, you can write your business logic and the proofs belonging to it
into Logic.agda;
however, you are free to create any new Agda source files
and any kind of directory structure
for your backend.
Just make sure you add your new files to the appropriate places
at All.agda and the Cabal project file.

Adding a Haskell source file is also possible
(an example for that is Platform.hs).
As these are ignored by Git by default, however,
you will probably want to add these to
backend/src/.gitignore
as exceptions;
as well as to All.agda and .cabal.

In order to write agda2hs-compatible proofs,
it is essential to understand the concept
of erasure in Agda (https://agda.readthedocs.io/en/latest/language/runtime-irrelevance.html)
as well as the abilities of agda2hs itself (https://agda.github.io/agda2hs/).

Using Haskell functions
-----------------------

Sometimes, you might want to use a function or type
available in Haskell but not in Agda
(either because of some low-level manipulation needed
or in order to avoid having to reimplement
a complex pre-existing code).

Generally, it is a good idea to import `Haskell.Prelude` and `Haskell.Prim`,
as they include many of the tools you would expect
from an ordinary Haskell environment.
If this does not solve your problem,
you still have some options.

First, check whether it is already
in the agda2hs library
(e.g. under Haskell.Prim or Haskell.Data).
If yes, simply use that;
it will be ultimately compiled
to the Haskell correspondent.

Sometimes, only postulates are available there,
but as they get compiled directly to the appropriate Haskell identifier,
they will, at run-time, act exactly the same way.
However, not all related functions may be available;
and often, corresponding laws (to be used for proofs) are missing.
(In this case, if you have time, a PR is welcome!
Just make sure you make it against the `have-it-both-ways`
of `viktorcsimma/agda2hs`,
as this is the version of the compiler included.)

If there is no appropriate pre-made solution,
a more general option is
to make the definition an Agda postulate
and then include the real definition in a foreign pragma.

For example,
to use the type `Complex` and the function `realPart :: Complex a -> a`
from the Haskell module `Data.Complex`::

  {-# FOREIGN AGDA2HS
  import qualified Data.Complex
  #-}

  -- ...

  postulate
    Complex : Set -> Set
    realPart : {a : Set} -> Complex a -> a

  {-# FOREIGN AGDA2HS
  type Complex = Data.Complex.Complex
  realPart :: Complex a -> a
  realPart = Data.Complex.realPart
  #-}

Or, if you want to do some haskellish dark magic
(for example, with unboxed types)::

  {-# FOREIGN AGDA2HS
  -- Import everything special you need from Haskell.
  ...
  #-}

  postulate
    fancyFunction : SomeType -> SomeOtherType

  {-# FOREIGN AGDA2HS
  fancyFunction :: SomeType -> SomeOtherType
  fancyFunction = ...     -- imagine some dark magic here
  #-}

