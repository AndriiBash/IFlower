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
    @Published var deviceInfos: [DeviceStruct] = []
    @Published var connectedDevices: [DeviceStruct] = [] {
        didSet {
            saveConnectedDevices()
        }
    }
    @Published var isScanning: Bool = false
    @Published var bluetoothEnabled: Bool = false
    @Published var isConnected: Bool = false
    @Published var receivedData: String = ""

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
        guard bluetoothEnabled else {
            print("Bluetooth is not enabled.")
            return
        }
        
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        isScanning = true
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
        isScanning = false
    }// func stopScanning()

    
    func disconnectFromPeripheral()
    {
        if let peripheral = connectedPeripheral
        {
            centralManager.cancelPeripheralConnection(peripheral)
            
            withAnimation(Animation.easeInOut(duration: 0.5))
            {
                isConnected = false
            }
            
            self.receivedData = ""
            
            print("Disconnected from \(peripheral.name ?? "Unknown")")
        }
    }// func disconnectFromPeripheral()

    
    func centralManagerDidUpdateState(_ central: CBCentralManager)
    {
        bluetoothEnabled = central.state == .poweredOn
        if central.state == .poweredOn
        {
            startScanning()
        }
        else
        {
            print("Bluetooth is not available.")
            isScanning = false
        }
    }// func centralManagerDidUpdateState(_ central: CBCentralManager)

    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
    {
        let name = peripheral.name ?? "Unknown"
        let macAddress = peripheral.identifier.uuidString
        let imageName = "camera.macro"
        
        discoveredDeviceSet.insert(macAddress)

        if !deviceInfos.contains(where: { $0.macAddress == macAddress }) 
        {
            let device = DeviceStruct(name: name, macAddress: macAddress, imageName: imageName)
            deviceInfos.append(device)
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
        
        withAnimation(Animation.easeInOut(duration: 0.5))
        {
            isConnected = true
        }
        
        let imageName = "camera.macro"
        let deviceInfo = DeviceStruct(name: peripheral.name ?? "Unknown", macAddress: peripheral.identifier.uuidString, imageName: imageName)

        if !connectedDevices.contains(where: { $0.macAddress == deviceInfo.macAddress }) 
        {
            connectedDevices.append(deviceInfo)
        }
        
        peripheral.discoverServices(nil)
        isScanning = false
    }// func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral)

    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?)
    {
        print("Failed to connect to \(peripheral.name ?? "Unknown"): \(error?.localizedDescription ?? "Unknown error")")
        isScanning = false
        
        withAnimation(Animation.easeInOut(duration: 0.5))
        {
            isConnected = false
        }
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
                if characteristic.properties.contains(.notify) 
                {
                    peripheral.setNotifyValue(true, for: characteristic)
                    print("Set notify for characteristic: \(characteristic.uuid)")
                }
                if characteristic.properties.contains(.write) || characteristic.properties.contains(.writeWithoutResponse)
                {
                    targetCharacteristic = characteristic
                    print("Found writable characteristic: \(characteristic.uuid)")
                }
            }
        }
    }// func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?)

    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) 
    {
        if let error = error
        {
            print("Error reading characteristic value: \(error.localizedDescription)")
            return
        }
        
        guard let characteristicValue = characteristic.value else 
        {
            print("Characteristic value is nil")
            return
        }
        
        if let receivedString = String(data: characteristicValue, encoding: .utf8) 
        {
            DispatchQueue.main.async
            {
                self.receivedData = receivedString
            }
            print("Received data: \(receivedString)")
        } 
        else
        {
            print("Failed to convert data to string")
        }
    }// func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?)

    
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
        let deviceDictArray = connectedDevices.map { ["id": $0.macAddress, "name": $0.name, "imageName": $0.imageName] }
        UserDefaults.standard.set(deviceDictArray, forKey: "connectedDevices")
    }// func saveConnectedDevices()

    
    func getConnectedDevices() -> [[String: String]]
    {
        return UserDefaults.standard.array(forKey: "connectedDevices") as? [[String: String]] ?? []
    }// func getConnectedDevices() -> [[String: String]]

    
    func loadConnectedDevices()
    {
        if let deviceDictArray = UserDefaults.standard.array(forKey: "connectedDevices") as? [[String: String]] 
        {
            connectedDevices = deviceDictArray.compactMap 
            {
                guard let id = $0["id"], let name = $0["name"], let imageName = $0["imageName"] else { return nil }
                return DeviceStruct(name: name, macAddress: id, imageName: imageName)
            }
        }
    }// func loadConnectedDevices()

    
    func removeConnectedDevice(at index: Int)
    {
        guard index >= 0 && index < connectedDevices.count else {
            return
        }
        
        let deviceToRemove = connectedDevices[index]
        
        if let peripheral = peripherals.first(where: { $0.identifier.uuidString == deviceToRemove.macAddress })
        {
            centralManager.cancelPeripheralConnection(peripheral)
        }
        connectedDevices.remove(at: index)
    }// func removeConnectedDevice(at index: Int)

    
    func updateDeviceList()
    {
        let currentConnectedDevices = Set(connectedDevices.map { $0.macAddress })
        let discoveredDevices = Set(deviceInfos.map { $0.macAddress })

        // Find devices that are no longer discovered
        let missingDevices = currentConnectedDevices.subtracting(discoveredDevices)

        // Remove missing devices from connectedDevices and deviceInfos
        if !missingDevices.isEmpty {
            deviceInfos.removeAll { missingDevices.contains($0.macAddress) }
            peripherals.removeAll { missingDevices.contains($0.identifier.uuidString) }
            print("Removed devices: \(missingDevices)")
        }

        discoveredDeviceSet.removeAll()
    }// func updateDeviceList()
    
    
    func saveDeviceSettings(for device: DeviceStruct, newName: String, imageName: String)
    {
        var deviceDictArray = getConnectedDevices()
        
        // search index device
        if let index = deviceDictArray.firstIndex(where: { $0["id"] == device.macAddress })
        {
            deviceDictArray[index]["name"] = newName
            deviceDictArray[index]["imageName"] = imageName
        }
        else
        {
            // if no device, return
            print("Device with this mac address was not found")
            return
        }
        
        // save to UserDefaults
        UserDefaults.standard.set(deviceDictArray, forKey: "connectedDevices")
        loadConnectedDevices()
    }

}// class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate
