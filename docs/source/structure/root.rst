.. _root:

************
Project root
************

The project root actually contains few things you need to care about.
It hosts an umbrella CMake project
through which you can handle the frontend and the backend
together as a simple project.

If you develop the backend and the frontend together,
it is more convenient to handle them via the root project
(and e.g. opening that one in Qt Creator).
However, if you do not plan to write a GUI,
the backend project is probably enough for you.
Similarly, if you only plan to write a frontend
to an existing compatible backend,
you might want to install the backend globally
and then working only with the frontend project.

In CMakeLists.txt,
you can set the version numbers and the name of the global project.
Otherwise, it is an ordinary CMake project file.

The <project-name>.agda-lib file
serves for initialising the backend
as an Agda library.
This contains the name Agda is going to see
if you plan to import the library to other Agda projects
(which you probably do not).

You also find the installation scripts (install.sh and install.ps1) here,
as well as the documentation source (docs) --
and, of course, the backend and the frontend.
