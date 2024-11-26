#include "View/MainWindow.h"

#include <QApplication>
#include <QLocale>
#include <QTranslator>

int main(int argc, char *argv[])
{
    // First, we initialise the Haskell runtime.
    // TODO: we should somehow check
    // which arguments are meant for Haskell;
    // e.g. by using +RTS and -RTS.
    hs_init(&argc, &argv);

    QApplication a(argc, argv);

    QTranslator translator;
    const QStringList uiLanguages = QLocale::system().uiLanguages();
    for (const QString &locale : uiLanguages) {
        const QString baseName = "qt-test_" + QLocale(locale).name();
        if (translator.load(":/i18n/" + baseName)) {
            a.installTranslator(&translator);
            break;
        }
    }

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
