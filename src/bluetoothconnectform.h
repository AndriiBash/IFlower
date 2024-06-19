#ifndef BLUETOOTHCONNECTFORM_H
#define BLUETOOTHCONNECTFORM_H

#include <QWidget>

#include <QtBluetooth>
#include <QBluetoothUuid>
#include <QBluetoothPermission>
#include <QLowEnergyService>
#include <QLowEnergyController>
#include <QBluetoothDeviceDiscoveryAgent>

#include <QSet>

#include <QListWidgetItem>


namespace Ui {
class BluetoothConnectForm;
}

class BluetoothConnectForm : public QWidget
{
    Q_OBJECT

public:
    explicit BluetoothConnectForm(QBluetoothDeviceDiscoveryAgent *discoveryAgent,
                                  QLowEnergyController **controller,
                                  QWidget *parent = nullptr);
    ~BluetoothConnectForm();


public slots:
    void deviceConnected();

    void deviceDisconnected();

    void errorReceived(QLowEnergyController::Error error);

private slots:
    void on_searchButton_clicked();

    void deviceDiscovered(const QBluetoothDeviceInfo &device);

    void on_deviceList_itemDoubleClicked(QListWidgetItem *item);

private:
    Ui::BluetoothConnectForm *ui;

    QBluetoothDeviceDiscoveryAgent *deviceDiscoveryAgent;
    QLowEnergyController **controller;

    QSet<QString> discoveredDevices;
    QMap<QString, QBluetoothDeviceInfo> deviceInfoMap;
};

#endif // BLUETOOTHCONNECTFORM_H
