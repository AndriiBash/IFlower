//
//  BluetoothManager.swift
//  BluetoothTestApp
//
//  Created by Андрiй on 25.06.2024.
//

import SwiftUI
import CoreBluetooth

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate 
{
    var centralManager: CBCentralManager!
    @Published var deviceInfos: [(String, String)] = []
    @Published var connectedDevices: [(String, String)] = [] {
        didSet {
            saveConnectedDevices()
        }
    }
    
    var peripherals: [CBPeripheral] = []
    var connectedPeripheral: CBPeripheral?
    var targetCharacteristic: CBCharacteristic?
    var scanTimer: Timer?
    var discoveredDeviceSet: Set<String> = []

    
    override init() 
    {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        loadConnectedDevices()
    }// override init()

    
    func startScanning() 
    {
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        scanTimer?.invalidate() // Invalidate old timer if exists
        scanTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) 
        { _ in
            self.centralManager.scanForPeripherals(withServices: nil, options: nil)
            self.updateDeviceList()
        }
    }// func startScanning()

    
    func stopScanning()
    {
        scanTimer?.invalidate()
        centralManager.stopScan()
    }// func stopScanning()
    

    func disconnectFromPeripheral() 
    {
        if let peripheral = connectedPeripheral 
        {
            centralManager.cancelPeripheralConnection(peripheral)
            print("Disconnected from \(peripheral.name ?? "Unknown")")
        }
    }// func disconnectFromPeripheral()

    
    func centralManagerDidUpdateState(_ central: CBCentralManager) 
    {
        if central.state == .poweredOn 
        {
            startScanning()
        }
        else
        {
            print("Bluetooth is not available.")
        }
    }// func centralManagerDidUpdateState(_ central: CBCentralManager)
    

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
    {
        let name = peripheral.name ?? "Unknown"
        let macAddress = peripheral.identifier.uuidString

        discoveredDeviceSet.insert(macAddress)

        if !deviceInfos.contains(where: { $0.0 == macAddress }) 
        {
            deviceInfos.append((macAddress, name))
            peripherals.append(peripheral)
            print("Discovered device: \(name) with MAC: \(macAddress)")
        }
    }// func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
    

    func connect(to peripheral: CBPeripheral)
    {
        centralManager.stopScan()
        disconnectFromPeripheral()
        
        peripheral.delegate = self
        centralManager.connect(peripheral, options: nil)
    }// func connect(to peripheral: CBPeripheral)

    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral)
    {
        print("Connected to \(peripheral.name ?? "Unknown")")
        connectedPeripheral = peripheral
        let deviceInfo = (peripheral.identifier.uuidString, peripheral.name ?? "Unknown")
        
        if !connectedDevices.contains(where: { $0.0 == deviceInfo.0 })
        {
            connectedDevices.append(deviceInfo)
        }
        peripheral.discoverServices(nil)
    }// func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral)

    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) 
    {
        print("Failed to connect to \(peripheral.name ?? "Unknown"): \(error?.localizedDescription ?? "Unknown error")")
    }// func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?)

    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?)
    {
        if let services = peripheral.services 
        {
            for service in services
            {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }// func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?)


    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?)
    {
        if let characteristics = service.characteristics 
        {
            for characteristic in characteristics 
            {
                if characteristic.properties.contains(.write) || characteristic.properties.contains(.writeWithoutResponse) 
                {
                    targetCharacteristic = characteristic
                    print("Found writable characteristic: \(characteristic.uuid)")
                }
            }
        }
    }// func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?)
    

    func sendData(_ data: String) 
    {
        if let characteristic = targetCharacteristic, let peripheral = connectedPeripheral 
        {
            let dataToSend = Data(data.utf8)
            peripheral.writeValue(dataToSend, for: characteristic, type: .withResponse)
        }
        else
        {
            print("No writable characteristic found or not connected to any peripheral.")
        }
    }// func sendData(_ data: String)
    

    func saveConnectedDevices() 
    {
        let deviceDictArray = connectedDevices.map { ["id": $0.0, "name": $0.1] }
        UserDefaults.standard.set(deviceDictArray, forKey: "connectedDevices")
    }// func saveConnectedDevices()

    
    func loadConnectedDevices()
    {
        if let deviceDictArray = UserDefaults.standard.array(forKey: "connectedDevices") as? [[String: String]]
        {
            connectedDevices = deviceDictArray.compactMap 
            {
                guard let id = $0["id"], let name = $0["name"] else { return nil }
                return (id, name)
            }
        }
    }// func loadConnectedDevices()

    
    func removeConnectedDevice(at index: Int) 
    {
        guard index >= 0 && index < connectedDevices.count else 
        {
            return
        }
        
        let deviceToRemove = connectedDevices[index]
        if let peripheral = peripherals.first(where: { $0.identifier.uuidString == deviceToRemove.0 }) 
        {
            centralManager.cancelPeripheralConnection(peripheral)
        }
        connectedDevices.remove(at: index)
    }// func removeConnectedDevice(at index: Int)
    

    func updateDeviceList() 
    {
        let currentConnectedDevices = Set(connectedDevices.map { $0.0 })
        let discoveredDevices = Set(deviceInfos.map { $0.0 })

        // Find devices that are no longer discovered
        let missingDevices = currentConnectedDevices.subtracting(discoveredDevices)

        // Remove missing devices from connectedDevices and deviceInfos
        if !missingDevices.isEmpty
        {
            //connectedDevices.removeAll { missingDevices.contains($0.0) }
            deviceInfos.removeAll { missingDevices.contains($0.0) }
            peripherals.removeAll { missingDevices.contains($0.identifier.uuidString) }
            print("Removed devices: \(missingDevices)")
        }

        discoveredDeviceSet.removeAll()
    }// func updateDeviceList()
}// class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate
