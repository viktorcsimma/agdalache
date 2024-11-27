*************
Main function
*************

The main function of the application is
in `frontend/src/Main/main.cpp`.
It is an ordinary Qt main function,
but it also initialises the Haskell runtime
by calling `hs_init`
and shutting it down gracefully via `hs_exit`.

Also, the objects containing Haskell references
should be constructed in a new block
before the `hs_exit` call.
This is because at that point,
every Haskell object should be
properly de-initialised;
otherwise, bad things could happen.

An example::

  int main(int argc, char *argv[])
  {
      // First, we initialise the Haskell runtime.
      // TODO: we should somehow check
      // which arguments are meant for Haskell;
      // e.g. by using +RTS and -RTS.
      hs_init(&argc, &argv);

      QApplication a(argc, argv);

      int exitCode;
      {
          // We put this into a separate block so that
          // every Haskell object gets properly destructed
          // before the hs_exit call.

          // By constructing the main window,
          // the MainViewModel and HsCalcStateWrapper instances
          // (and this way, the Haskell CalcState object)
          // are also created.
          MainWindow w;
          w.show();

          exitCode = a.exec();
      }

      // We finally shut down the Haskell runtime.
      hs_exit();
      return exitCode;
  }

Again, feel free to modify this file
if you are familiar with Qt.
