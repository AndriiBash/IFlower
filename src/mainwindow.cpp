#include "mainwindow.h"
#include "ui_mainwindow.h"
#include <QListWidgetItem>
#include <QDebug>


#include <QPermissions>


MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);

}


MainWindow::~MainWindow()
{
    delete ui;
}


void MainWindow::deviceDiscovered(const QBluetoothDeviceInfo &device)
{
    QString dName = device.name();
    QString dAdress = device.address().toString();

    ui->deviceList->addItem(dName + dAdress);
}


void MainWindow::on_scanButton_clicked()
{
    QBluetoothDeviceDiscoveryAgent *discoveryAgent = new QBluetoothDeviceDiscoveryAgent(this);

    connect(discoveryAgent, SIGNAL(deviceDiscovered(QBluetoothDeviceInfo)), this, SLOT(deviceDiscovered(QBluetoothDeviceInfo)));

    discoveryAgent->start();


    QBluetoothPermission bluetoothPermission;

    if (bluetoothPermission.communicationModes() == QBluetoothPermission::Access)
    {
        qDebug() << "Access to other Bluetooth devices is allowed.";
    }
    else if (bluetoothPermission.communicationModes() == QBluetoothPermission::Advertise)
    {
        qDebug() << "Allow other Bluetooth devices to discover this device.";
    }
    else if (bluetoothPermission.communicationModes() == QBluetoothPermission::Default)
    {
        qDebug() << "This configuration is used by default.";
    }
    else
    {
        qDebug() << "Access to other Bluetooth devices is not allowed.";
    }



}

