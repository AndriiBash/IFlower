#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>

#include <QtBluetooth>

#include <QLowEnergyService>
#include <QLowEnergyController>
#include <QLowEnergyService>
#include <QLowEnergyServiceData>
#include <QLowEnergyController>
#include <QBluetoothDeviceDiscoveryAgent>
#include <QBluetoothUuid>
#include <QBluetoothPermission>


#include <QListWidget>

#include "bluetoothconnectform.h"

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
    // button
    void on_pushButton_clicked();
    void on_pushButton_2_clicked();
    void on_offLedButton_clicked();
    void on_onLedButton_clicked();

    // bluetooth
    void deviceConnected();
    void deviceDisconnected();
    void errorReceived(QLowEnergyController::Error error);
    void serviceStateChanged(QLowEnergyService::ServiceState newState);
    void updateCharacteristicValue(const QLowEnergyCharacteristic &characteristic, const QByteArray &newValue);


private:
    Ui::MainWindow *ui;

    // Bluetooth
    QBluetoothDeviceDiscoveryAgent *deviceDiscoveryAgent;
    QLowEnergyController *lowEnergyController;
    QLowEnergyService *lowEnergyService;

    BluetoothConnectForm *bluetoothConnectForm;
    //QLowEnergyController *controller;
};
#endif // MAINWINDOW_H
