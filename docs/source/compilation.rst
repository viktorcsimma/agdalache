***********
Compilation
***********

Both Cabal and CMake can be used to compile the backend; the frontend only works with CMake (as Cabal is Haskell-specific).

Cabal
-----

After changing the working directory to the backend folder,
you can simply use the usual commands:
`cabal build` for building,
`cabal install` for installing
and `cabal run` for running the executable (if you have one).
QuickCheck tests can be run with `cabal test`.

See also the documentation of Cabal (https://www.haskell.org/cabal/) for details.

CMake
-----

Both the backend and the frontend folder, as well as the entire root folder
serve as valid CMake folders.
If you compile the frontend alone, it will search for a globally installed backend library
(which is useful if you only develop a frontend for a backend someone else has already written);
otherwise, it will use the one located next to it.

For the backend, agda2hs and GHC will copy intermediate files
into a folder called `build` under the backend directory
so that they do not get up mixed with real source files.
For C++ files, expect the usual structure.

If you want to install the backend library globally, this is also possible

For the frontend, you may want to run CMake from Qt Creator,
especially as CMake may not find your Qt installation by itself.
The same goes for the whole project
(just make sure you open the appropriate CMakeLists.txt file
in Creator).
