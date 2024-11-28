.. _frontend-cmake:

***********************
The CMake project files
***********************

The frontend/CMakeLists.txt file
--------------------------------

CMakeLists.txt under the frontend directory
contains the CMake operations necessary
to compile the frontend together with the backend.

The name of the frontend project as well as that of the imported backend project
can be changed at the top of the file.

If you run CMake directly for the frontend CMakeLists
(i.e. NOT_TOP_LEVEL is not defined),
it will look for a globally installed backend library;
use this if you want to write a frontend for an existing backend.
If run for the project root, however,
it looks for a target of the project,
which is defined in the neighbouring backend directory.

CMakeLists.txt also imports Qt and Catch2;
feel free to remove these if you don't want to use them.

By default, there are two targets: an executable (called SkeletonGUI in the skeleton project) and a Catch2-based test executable. You are free to change these; just beware to keep the Haskell-specific import tricks intact unless you know what you are doing.

Subdirectory files
------------------

The approach used in the skeleton project
is to include a CMakeLists.txt file in each subdirectory,
with a content similar to this::

  # a further subdirectory
  add_subdirectory(my_subdirectory)

  # a file to be included
  target_sources(
      ${PROJECT_NAME}   # or ${PROJECT_NAME}Test for the test executable
      PRIVATE my_file.h
  )

And in the end, we add the uppermost subdirectories to the frontend CMakeLists.txt with `add_subdirectory` commands. In the skeleton project::

  add_subdirectory(src)
  add_subdirectory(include)

But feel free to use any CMake technique and style you want. If working with Qt Creator, you can also let it manage source files for you automatically (just make sure they get into the frontend CMakeLists and not the one above).
