#include "View/MainWindow.h"
#include "View/ui_MainWindow.h"

#include <QErrorMessage>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
    , viewModel(new MainViewModel())
{
    ui->setupUi(this);
}

MainWindow::~MainWindow()
{
    delete ui;
    delete viewModel;
}
