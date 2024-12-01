.. _all-agda:

*****************
The All.agda file
*****************

.. highlight:: agda

The All.agda file
(located in backend/src)
contains the Agda and Haskell modules
to be imported.

It is a key element of the framework,
as both build systems work
by calling agda2hs on All.agda
and then running GHC on the resulting All.hs.
This also explains its structure:
it contains several Agda imports
followed by several Haskell imports
(in a foreign pragma).

The All.agda file in the skeleton
looks like this::

  {-# OPTIONS --erasure --guardedness #-}

  module All where

  import AppState
  import Interaction
  import Logic

  import Tool.ErasureProduct
  import Tool.Cheat
  import Tool.PropositionalEquality
  import Tool.Relation
  import Tool.Future

  import Test.ExampleTest
  import Test.Haskell.ExampleTest

  import Platform.Win32
  import Platform.Posix

  -- And now, we also copy them into the Haskell source;
  -- this way, we can compile everything by compiling All.hs.
  {-# FOREIGN AGDA2HS
  {-# LANGUAGE CPP #-}
  import AppState
  import Interaction
  import Logic

  import Tool.ErasureProduct
  import Tool.Future
  import Platform
  #-}

Where to include what?

* Add an Agda import for a module
  which is written in Agda (of course)
  and you want to get checked
  by the Agda typechecker.
  Pretty much, this means every Agda file you add.
  Only modules that are already written in ``.hs`` files
  should be excluded
  (like ``Platform`` in the skeleton).
* Add a Haskell import for modules
  you want to run GHC on.
  This means you should omit Agda modules
  that contain no agda2hs pragmas:
  agda2hs does not generate a Haskell file for them
  (as it would be empty anyway)
  and GHC would fail if it were to look for them.
  This includes, for example, the equality tools
  under the Tool directory.
  However, you *should* add modules
  pre-written in Haskell
  (like ``Platform.hs``).

Actually, if an Agda import contains further Agda imports,
you need not include them in All.agda;
similarly, if a Haskell module imports something by itself,
you can omit it here.
