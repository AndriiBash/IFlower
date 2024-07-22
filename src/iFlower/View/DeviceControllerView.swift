//
//  deviceController.swift
//  iFlower
//
//  Created by Андрiй on 11.07.2024.
//

import SwiftUI

struct DeviceControllerView: View 
{
    var device: (String, String)
    @ObservedObject var bluetoothManager: BluetoothManager
    @State private var dataToSend = ""
    @State private var isConnecting = false

    var body: some View
    {
        VStack 
        {
            if isConnecting 
            {
                Text("Device Name: \(device.1)")
                Text("Device Address: \(device.0)")
                
                VStack
                {
                    TextField("Data to send", text: $dataToSend)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button(action: {
                        bluetoothManager.sendData(dataToSend)
                    }) {
                        Text("Send Data")
                            .foregroundColor(.blue)
                    }
                    .padding()
                }// VStack with textField sender data
                
                Button
                {
                    if let index = bluetoothManager.deviceInfos.firstIndex(where: { $0.0 == device.0 })
                    {
                        let peripheral = bluetoothManager.peripherals[index]
                        bluetoothManager.connect(to: peripheral)
                    }
                }
                label:
                {
                    Text("Сonnect!")
                }

                
                Button
                {
                    bluetoothManager.disconnectFromPeripheral()
                }
                label:
                {
                    Text("DISCONNECT!")
                }
            }// if process connecting
            else
            {
                ProgressView("Connecting...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }
        }// main VStack
        .padding()
        .navigationTitle(device.1)
        .onAppear
        {            
            isConnecting = false
                        
            if let index = bluetoothManager.deviceInfos.firstIndex(where: { $0.0 == device.0 })
            {
                let peripheral = bluetoothManager.peripherals[index]
                bluetoothManager.connect(to: peripheral)
            }
            
            withAnimation(Animation.easeInOut(duration: 0.5))
            {
                isConnecting = true
            }
        } 
        .onDisappear
        {
            bluetoothManager.disconnectFromPeripheral()
        }
    }
}
