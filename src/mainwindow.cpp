#include "mainwindow.h"
#include "ui_mainwindow.h"

#include <QDebug>
#include <QPermissions>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
    , deviceDiscoveryAgent(new QBluetoothDeviceDiscoveryAgent())
    , lowEnergyController(nullptr)
    , bluetoothConnectForm(new BluetoothConnectForm(deviceDiscoveryAgent, &lowEnergyController))
    , lowEnergyService(nullptr)
{
    ui->setupUi(this);

    deviceDiscoveryAgent->setLowEnergyDiscoveryTimeout(25000);

    // need fix or delete
    connect(bluetoothConnectForm, &BluetoothConnectForm::deviceConnected, this, &MainWindow::deviceConnected);
    connect(bluetoothConnectForm, &BluetoothConnectForm::deviceDisconnected, this, &MainWindow::deviceDisconnected);
    connect(bluetoothConnectForm, &BluetoothConnectForm::errorReceived, this, &MainWindow::errorReceived);
}


MainWindow::~MainWindow()
{
    if (lowEnergyController)
    {
        lowEnergyController->disconnectFromDevice();
        delete lowEnergyController;
    }

    if (bluetoothConnectForm)
    {
        bluetoothConnectForm->close();
        delete bluetoothConnectForm;
    }

    delete ui;
}

void MainWindow::on_pushButton_clicked()
{
    bluetoothConnectForm->show();
    bluetoothConnectForm->setFocus();
}

void MainWindow::on_pushButton_2_clicked()
{
    if (lowEnergyController && lowEnergyController->state() == QLowEnergyController::ConnectedState)
    {
        qDebug() << "Controller is connected!";
    }
    else
    {
        qDebug() << "Controller is not connected!";
    }
}

void MainWindow::on_offLedButton_clicked()
{
    if (lowEnergyController && lowEnergyController->state() == QLowEnergyController::ConnectedState)
    {

        lowEnergyService = lowEnergyController->createServiceObject(QBluetoothUuid::BatteryService);

        if (lowEnergyService)
        {
            QBluetoothUuid characteristicUuid("0000ff01-0000-1000-8000-00805f9b34fb");
            QLowEnergyCharacteristic characteristic = lowEnergyService->characteristic(characteristicUuid);

            if (characteristic.isValid())
            {
                QByteArray data("0");
                lowEnergyService->writeCharacteristic(characteristic, data, QLowEnergyService::WriteWithResponse);
            }
            else
            {
                qDebug() << "Characteristic is not valid!";
            }
        }
        else
        {
            qDebug() << "Service is not available!";
        }
    }
    else
    {
        qDebug() << "Controller is not connected!";
    }
}

// need fix method off and on, not works
void MainWindow::on_onLedButton_clicked()
{
    if (lowEnergyController && lowEnergyController->state() == QLowEnergyController::ConnectedState)
    {
        if (lowEnergyService)
        {
            QBluetoothUuid characteristicUuid("0000ff01-0000-1000-8000-00805f9b34fb");
            QLowEnergyCharacteristic characteristic = lowEnergyService->characteristic(characteristicUuid);

            if (characteristic.isValid())
            {
                QByteArray data("1");
                lowEnergyService->writeCharacteristic(characteristic, data, QLowEnergyService::WriteWithResponse);
            }
            else
            {
                qDebug() << "Characteristic is not valid!";
            }
        }
        else
        {
            qDebug() << "Service is not available!";
        }
    }
    else
    {
        qDebug() << "Controller is not connected!";
    }
}

void MainWindow::deviceConnected()
{
    qDebug() << "Device connected (main window)!";
}


void MainWindow::deviceDisconnected()
{
    qDebug() << "Device disconnected!";

    if (lowEnergyService)
    {
        delete lowEnergyService;
        lowEnergyService = nullptr;
    }
}


void MainWindow::errorReceived(QLowEnergyController::Error error)
{
    qDebug() << "Error: " << error;
}


void MainWindow::serviceStateChanged(QLowEnergyService::ServiceState newState)
{
    qDebug() << "Service state changed:" << newState;
}


void MainWindow::updateCharacteristicValue(const QLowEnergyCharacteristic &characteristic, const QByteArray &newValue)
{
    qDebug() << "Characteristic value updated:" << characteristic.uuid().toString() << newValue;
}

