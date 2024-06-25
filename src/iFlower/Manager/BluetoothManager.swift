//
//  BluetoothManager.swift
//  BluetoothTestApp
//
//  Created by Андрiй on 25.06.2024.
//

import SwiftUI
import CoreBluetooth

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    @Published var deviceInfos: [(String, String)] = []
    var peripherals: [CBPeripheral] = []
    var connectedPeripheral: CBPeripheral?
    var targetCharacteristic: CBCharacteristic?

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        } else {
            print("Bluetooth is not available.")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let name = peripheral.name ?? "Unknown"
        let macAddress = peripheral.identifier.uuidString
        if !deviceInfos.contains(where: { $0.0 == macAddress }) {
            deviceInfos.append((macAddress, name))
            peripherals.append(peripheral)
            print("Discovered device: \(name) with MAC: \(macAddress)")
        }
    }

    func connect(to peripheral: CBPeripheral) {
        centralManager.stopScan()
        peripheral.delegate = self
        centralManager.connect(peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "Unknown")")
        connectedPeripheral = peripheral
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to \(peripheral.name ?? "Unknown"): \(error?.localizedDescription ?? "Unknown error")")
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.properties.contains(.write) || characteristic.properties.contains(.writeWithoutResponse) {
                    targetCharacteristic = characteristic
                    print("Found writable characteristic: \(characteristic.uuid)")
                    // Optionally write initial data
                    // sendData("Hello, device!")
                }
            }
        }
    }

    func sendData(_ data: String) {
        if let characteristic = targetCharacteristic, let peripheral = connectedPeripheral {
            let dataToSend = Data(data.utf8)
            peripheral.writeValue(dataToSend, for: characteristic, type: .withResponse)
        } else {
            print("No writable characteristic found or not connected to any peripheral.")
        }
    }
}
