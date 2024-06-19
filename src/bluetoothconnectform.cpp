#include "bluetoothconnectform.h"
#include "ui_bluetoothconnectform.h"


BluetoothConnectForm::BluetoothConnectForm(QBluetoothDeviceDiscoveryAgent *discoveryAgent, QLowEnergyController **controller, QWidget *parent)
    : QWidget(parent)
    , ui(new Ui::BluetoothConnectForm)
    , deviceDiscoveryAgent(discoveryAgent)
    , controller(controller)
    //, lowEnergyController(controller)
{
    ui->setupUi(this);

    connect(deviceDiscoveryAgent, SIGNAL(deviceDiscovered(QBluetoothDeviceInfo)), this, SLOT(deviceDiscovered(QBluetoothDeviceInfo)));
}


BluetoothConnectForm::~BluetoothConnectForm()
{
    delete ui;
}


void BluetoothConnectForm::on_searchButton_clicked()
{
    deviceDiscoveryAgent->stop();

    discoveredDevices.clear();
    ui->deviceList->clear();

    deviceDiscoveryAgent->start(QBluetoothDeviceDiscoveryAgent::LowEnergyMethod);

}


void BluetoothConnectForm::deviceDiscovered(const QBluetoothDeviceInfo &device)
{
    QString dName = device.name();
    QString dUUID = device.deviceUuid().toString();

    // Checking the presence of a device name and uniqueness
    if (!dName.isEmpty() && !discoveredDevices.contains(dUUID))
    {
        discoveredDevices.insert(dUUID);
        deviceInfoMap.insert(dUUID, device);
        ui->deviceList->addItem(dName + " " + dUUID);
    }
}


void BluetoothConnectForm::on_deviceList_itemDoubleClicked(QListWidgetItem *item)
{
    QString deviceText = item->text();
    QString dUUID = deviceText.split(" ").last();

    if (deviceInfoMap.contains(dUUID))
    {
        QBluetoothDeviceInfo deviceInfo = deviceInfoMap.value(dUUID);

        // Check if a lowEnergyController is already instantiated and delete it
        if (*controller)
        {
            (*controller)->disconnectFromDevice();
            delete *controller;
        }

        // Instantiate lowEnergyController with the selected device info
        *controller = QLowEnergyController::createCentral(deviceInfo, this);

        connect(*controller, &QLowEnergyController::connected, this, &BluetoothConnectForm::deviceConnected);
        connect(*controller, &QLowEnergyController::disconnected, this, &BluetoothConnectForm::deviceDisconnected);
        connect(*controller, &QLowEnergyController::errorOccurred, this, &BluetoothConnectForm::errorReceived); // Corrected signal

        qDebug() << "Connecting to device" << deviceInfo.name();
        (*controller)->connectToDevice();
    }
}


void BluetoothConnectForm::deviceConnected()
{
    qDebug() << "Device connected!";
    // Do something when device is connected
}


void BluetoothConnectForm::deviceDisconnected()
{
    qDebug() << "Device disconnected!";
    // Do something when device is disconnected
}


void BluetoothConnectForm::errorReceived(QLowEnergyController::Error error)
{
    qDebug() << "Error: " << error;
    // Handle the error
}

