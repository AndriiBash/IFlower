//
//  iFlowerDeviceStruct.swift
//  iFlower
//
//  Created by Андрiй on 09.08.2024.
//

import Foundation

struct iFlowerDevice
{
    var versionFirmware: String     // Device firmware version
    var serialNumber: String        // Serial number of the device
    
    var soilMoisture: Int           // Soil moisture in percent
    var airTemperature: Int         // Air temperature around the plant in degrees
    var airHumidity: Int            // Air humidity in percent
    var lightLevel: Int             // Illumination level in lumens
    
    var isWatering: Bool            // Are plants watered
    var isEditSoilMisture: Bool     // Are edit values Minimum and Maximum soil moisture level
    var maxSoilMoisture: Int        // Maximum soil moisture level in percent
    var minSoilMoisture: Int        // Minimum soil moisture level in percent

    var temperatureArray: [Int]     // Array of temperatures for the last few hours
    var yesterdayTempArray: [Int]   // Array of temperatures for the last few hours

    mutating func clearDeviceData()
    {
        self.versionFirmware = "0.0"
        self.serialNumber = "0000-0000-0000-0000"
        
        self.soilMoisture = 0
        self.airTemperature = 0
        self.airHumidity = 0
        self.lightLevel = 0
        
        self.isWatering = false
        self.isEditSoilMisture = false
        self.maxSoilMoisture = 0
        self.minSoilMoisture = 0
        
        self.temperatureArray = []
        self.yesterdayTempArray = []
    }// mutating func resetSensorValues()
}
