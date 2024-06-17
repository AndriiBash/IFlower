#include "mainwindow.h"

#include <QApplication>


int main(int argc, char *argv[])
{
    QApplication app(argc, argv);


    app.requestPermission(QBluetoothPermission(), [](const QPermission &permission)
    {
        ///test;
    });

    MainWindow w;
    w.show();
    return app.exec();
}
