#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>

#include "ViewModel/MainViewModel.hpp"

QT_BEGIN_NAMESPACE
namespace Ui {
class MainWindow;
}
QT_END_NAMESPACE

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    // This does _not_ destruct the view model; that is the task of the main function.
    ~MainWindow();

private:
    Ui::MainWindow *ui;

    // The view model behind the window.
    // This refers to the same object throughout the entire existence of the window;
    // mode changes are achieved by changing the HsCalcStateWrapper instance under the view model.
    MainViewModel *viewModel;
};
#endif // MAINWINDOW_H
