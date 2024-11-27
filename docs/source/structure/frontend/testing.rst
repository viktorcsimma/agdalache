*******
Testing
*******

Under `frontend/src/Test`, you can add any Catch2 tests.
Catch2 is a C++ testing framework
for writing runtime checks easily.

The custom main function of the testing executable
can also be found here;
it initialises the Haskell runtime before running the tests
and shuts it down afterwards.
However, the tests need not be added there
(as Catch2 will find them),
but to the local CMakeLists.txt file
as a dependency for the test target::

  target_sources(${PROJECT_NAME}Test PRIVATE main.cpp Test1.cpp Test2.cpp ...)

For details on how to write the tests themselves,
see the Catch2 documentation: https://github.com/catchorg/Catch2/tree/devel/docs.
