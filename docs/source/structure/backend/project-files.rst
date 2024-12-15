.. _project-files:

*************
Project files
*************

Here, we discuss the project files needed
for Cabal, CMake and Agda.

Note that by default, we assume two targets:
a statically linked library
and a binary with the main function defined in Main.hs.
Feel free to remove the targets you do not need.

Cabal
-----

Cabal is one of the standard package managers for Haskell
(the other being Haskell).
It, however, is also a build system,
with various options:
``cabal install`` installs the project globally,
``cabal run`` builds it in place and runs the main function,
and ``cabal repl`` loads everything into a GHCi instance
so that you can debug live.
QuickCheck tests can be run
by calling ``cabal test``.

For more information on Cabal,
see `its documentation <https://cabal.readthedocs.io/en/3.4/index.html>`_.

An ASDK backend is also a Cabal project by its own right:
it can be compiled and installed like any ordinary Cabal project.
For this, we need a *project description* ``<project-name>.cabal``.

The syntax is detailed at the `corresponding part of the Cabal documentation <https://cabal.readthedocs.io/en/3.4/cabal-package.html#package-descriptions>`_. Here, we only cover ASDK-specific tweaks.

Cabal is tricked into compiling Agda files
by running a custom Setup.hs file,
which calls agda2hs on src/All.agda (see later).
This creates the Haskell files,
which are then imported as automatically generated modules.

Actually, you can handle the .cabal file
as a usual Cabal project description file.
However, as this is a less-than-usual use case for Cabal,
some ugly solutions have to be applied.

* extra-source-files must contain all the Agda files,
  and unfortunately, wildcards (*) do not cover subdirectories.
  Therefore, you have to include *every* subdirectory
  that contains Agda source code.
  For the pre-built tools, we have done this for you,
  but new subdirectories must be added manually.
* An even bigger problem is the listing of modules of the library,
  as both under autogen-modules and exposed-modules,
  you have to include *every single Agda module*.
  So make sure you do so every time you create a new file.

Please note that these problems are not originating from ASDK,
but from Cabal itself,
as it is low-level compared to other tools like Stack.
(In fact, the latter uses Cabal as a backend.)

Switching to Stack is already on the way.

CMake
-----

CMake is a project management system
which works platform-independently
with multiple build systems.
It is usually used for C and C++ projects.

With some tricks, however,
it can be used for our Agda backend,
which is going to be crucial for importing it
in the C++ frontend.

The cornerstone is the CMakeLists.txt file
in the backend directory.
This employs even more unorthodox solutions
in order to trick the system into running agda2hs and GHC
and then get them to create a C++-compatible binary object.
For more information, see the comments in the file itself.

What you might need to know:

* The backend project name is defined at the top.
  To change this, however,
  you also need to rename ``<ProjectName>ConfigVersion.cmake``
  and replace the name in ``Config.cmake.in``.
* The default configuration creates
  a static library ``lib<ProjectName>.a``
  and an executable ``<ProjectName>Shell``.
  You can rename these, if you want.
* Installation makes the library and the executable
  available globally on the machine.
* You do not need to add the Haskell or Agda files to the project itself,
  as they get reached via All.agda and Main.hs.
  Just make sure you do not change the names of these.
  However, you might need to edit the commands
  if you add a new C file
  (see how interruptEvaluation.c is referenced in CMakeLists.txt).

Agda
----

``<project-name>.agda-lib`` is, again, a file defining an Agda library.
It is useful if you also want to use the backend
as a library importable by other Agda projects.

You can change the name;
otherwise, there is not much to see here.
The only thing to note is that
the backend relies on the Agda library
included in agda2hs.
