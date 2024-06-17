#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>

#include <QtBluetooth>

#include <QLowEnergyService>
#include <QLowEnergyController>
#include <QBluetoothDeviceDiscoveryAgent>


#include <QBluetoothUuid>
#include <QBluetoothPermission>


#include <QListWidget>

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
    ~MainWindow();


private slots:
    void on_scanButton_clicked();

    void deviceDiscovered(const QBluetoothDeviceInfo &device);

private:
    Ui::MainWindow *ui;

    //QBluetoothServiceDiscoveryAgent *discoveryAgent;

    //QLowEnergyController *controller;
};
#endif // MAINWINDOW_H
