//
//  iFlowerApp.swift
//  iFlower
//
//  Created by Андрiй on 25.06.2024.
//

import SwiftUI

@main
struct iFlowerApp: App 
{
    var body: some Scene
    {
        WindowGroup 
        {
            ContentView()
        }// main Window Group
        .windowStyle(DefaultWindowStyle())

        
        // maybe delete
        Window("Пошук Bluetooth пристроїв", id: "BluetoothWindow")
        {
            //BluetoothConnectView(bluetoothManager: bluetoothManager)
        }// window for search bluetooth device
    }// body
}
