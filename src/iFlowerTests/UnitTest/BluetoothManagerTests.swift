//
//  BluetoothManagerTests.swift
//  iFlowerTests
//
//  Created by Андрiй on 14.09.2024.
//

import XCTest
@testable import iFlower
import CoreBluetooth
import SwiftUI


class BluetoothManagerTests: XCTestCase
{
    var bluetoothManager: BluetoothManager!
    var mockCentralManager: MockCentralManager!
    var mockPeripheral: MockPeripheral!
    
    override func setUpWithError() throws
    {
        // Створюємо екземпляр BluetoothManager перед кожним тестом
        bluetoothManager = BluetoothManager()
        mockCentralManager = MockCentralManager()
        mockPeripheral = MockPeripheral()

        bluetoothManager = BluetoothManager()
    }// override func setUpWithError() throws

    
    override func tearDownWithError() throws
    {
        // Очищуємо екземпляр після кожного тесту
        bluetoothManager = nil
        mockCentralManager = nil
        mockPeripheral = nil
    }// override func tearDownWithError() throws
    
    // Тестування початку сканування
    func testStartScanningBluetoothEnabled() throws
    {
        bluetoothManager.bluetoothEnabled = true
        bluetoothManager.startScanning()
        
        mockCentralManager.isScanning = bluetoothManager.isScanning
        
        XCTAssertTrue(bluetoothManager.isScanning)
        XCTAssertNotNil(bluetoothManager.scanTimer)
        XCTAssertTrue(mockCentralManager.isScanning)
    }
    
    // Тестування початку сканування без Bluetooth
    func testStartScanningBluetoothDisabled() throws
    {
        bluetoothManager.bluetoothEnabled = false
        bluetoothManager.startScanning()
        
        XCTAssertFalse(bluetoothManager.isScanning)
        XCTAssertNil(bluetoothManager.scanTimer)
        XCTAssertFalse(mockCentralManager.isScanning)
    }// func testStartScanningBluetoothDisabled() throws

    // Тестування зупинки сканування
    func testStopScanning() throws
    {
        bluetoothManager.isScanning = true
        bluetoothManager.scanTimer = Timer()
        bluetoothManager.stopScanning()
        
        XCTAssertFalse(bluetoothManager.isScanning)
        XCTAssertNil(bluetoothManager.scanTimer)
        XCTAssertFalse(mockCentralManager.isScanning)
    }// func testStopScanning() throws
    
    // Тестування підключення до периферії
    func testConnectToPeripheral() throws
    {
        // Припустимо, що йде сканування
        bluetoothManager.isScanning = true
        
        // Емулюємо зупинку сканування (наче викликано з'єднання)
        bluetoothManager.stopScanning()
        
        XCTAssertFalse(bluetoothManager.isScanning, "Сканування повино бути завершеним")

        XCTAssertNil(bluetoothManager.connectedPeripheral, "Не повинно бути підключеного периферійного пристрою до реального підключення")
    }// func testConnectToPeripheral() throws
    
    // Тестування збереження підключених пристроїв
    func testSaveConnectedDevices() throws
    {
        let testDevice = DeviceStruct(name: "Test Device", macAddress: "00:11:22:33:44:55", imageName: "camera.macro")
        bluetoothManager.connectedDevices = [testDevice]
        bluetoothManager.saveConnectedDevices()
        
        let savedDevices = UserDefaults.standard.array(forKey: "connectedDevices") as? [[String: String]]
        XCTAssertNotNil(savedDevices)
        XCTAssertEqual(savedDevices?.count, 1)
        XCTAssertEqual(savedDevices?.first?["id"], "00:11:22:33:44:55")
    }// func testSaveConnectedDevices() throws
    
    // Тестування обробки JSON
    func testProcessJSON() throws
    {
        let jsonString = """
        {
            "serialNumber": "1234-5678-9101-1121",
            "versionFirmware": "1.0",
            "soilMoisture": 30,
            "airHumidity": 40,
            "lightLevel": 50,
            "airTemperature": 20
        }
        """

        bluetoothManager.processJSON(jsonString)
        
        XCTAssertEqual(bluetoothManager.iFlowerMainDevice.serialNumber, "1234-5678-9101-1121")
        XCTAssertEqual(bluetoothManager.iFlowerMainDevice.versionFirmware, "1.0")
        XCTAssertEqual(bluetoothManager.iFlowerMainDevice.soilMoisture, 30)
        XCTAssertEqual(bluetoothManager.iFlowerMainDevice.airHumidity, 40)
        XCTAssertEqual(bluetoothManager.iFlowerMainDevice.lightLevel, 50)
        XCTAssertEqual(bluetoothManager.iFlowerMainDevice.airTemperature, 20)
    }// func testProcessJSON() throws
}// class BluetoothManagerTests: XCTestCase


protocol CentralManagerProtocol
{
    func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String : Any]?)
    func stopScan()
    func connect(_ peripheral: PeripheralProtocol, options: [String : Any]?)
    func cancelPeripheralConnection(_ peripheral: PeripheralProtocol)
}// protocol CentralManagerProtocol


protocol PeripheralProtocol
{
    var name: String? { get }
    var identifier: UUID { get }
}// protocol PeripheralProtocol


class MockCentralManager: CentralManagerProtocol
{
    func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String : Any]?)
    {
        isScanning = true
    }// func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String : Any]?)
    
    
    func stopScan()
    {
        isScanning = false
    }// func stopScan()
    
    
    func connect(_ peripheral: PeripheralProtocol, options: [String : Any]?)
    {
        isConnected = true
    }// func connect(_ peripheral: PeripheralProtocol, options: [String : Any]?)
    
    
    func cancelPeripheralConnection(_ peripheral: PeripheralProtocol)
    {
        isConnected = false
    }// func cancelPeripheralConnection(_ peripheral: PeripheralProtocol)

    
    var isScanning = false
    var isConnected = false
}// class MockCentralManager: CentralManagerProtocol


class MockPeripheral: PeripheralProtocol
{
    var name: String?
    {
        return "MockPeripheral"
    }
    
    var identifier: UUID
    {
        return UUID(uuidString: "00001122-3344-4556-6778-899aabbccdde")!
    }
}// class MockPeripheral: PeripheralProtocol
