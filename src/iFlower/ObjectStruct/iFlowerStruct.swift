//
//  iFlowerDeviceStruct.swift
//  iFlower
//
//  Created by Андрiй on 09.08.2024.
//

import Foundation

struct iFlowerDevice
{
    var versionFirmware: String // Версія прошивки девайса
    var serialNumber: String    // Серійний номер пристрою
    
    var soilMoisture: Int       // Волога ґрунту у відцотках
    var airTemperature: Int     // Температура повітря навколо рослини в градусах
    var airHumidity: Int        // Вологість повітря у відсотках
    var lightLevel: Int         // Рівень освітлення у люменах
    
    mutating func clearDeviceData() 
    {
        self.versionFirmware = "0.0"
        self.serialNumber = "0000-0000-0000-0000"
        
        self.soilMoisture = 0
        self.airTemperature = 0
        self.airHumidity = 0
        self.lightLevel = 0
    }// mutating func resetSensorValues()

}
