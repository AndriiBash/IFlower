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

    var body: some View
    {
        VStack 
        {
            if bluetoothManager.bluetoothEnabled
            {
                if bluetoothManager.isConnected
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
                    
                    
                    if bluetoothManager.isConnected
                    {
                        Text("connect")
                            .foregroundColor(Color.green)
                    }
                    else
                    {
                        Text("NOT connect")
                            .foregroundColor(Color.red)
                    }
                    
                    
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
                        .onAppear
                        {
                            if bluetoothManager.bluetoothEnabled
                            {
                                if let index = bluetoothManager.deviceInfos.firstIndex(where: { $0.0 == device.0 })
                                {
                                    let peripheral = bluetoothManager.peripherals[index]
                                    bluetoothManager.connect(to: peripheral)
                                }
                            }
                        }
                        .onDisappear
                        {
                            bluetoothManager.disconnectFromPeripheral()
                        }
                }
            }
            else
            {
                Image(systemName: "antenna.radiowaves.left.and.right.slash")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color.red)
                
                Text("\(device.1) наразі недоступний бо відсутній Bluetooth")
                    .font(.body.bold())
                    .frame(maxWidth: .infinity, alignment: .center)

                HStack(spacing: 4)
                {
                    Text("Скоріш за всього в налаштуваннях потрібно включити bluetooth, як це зробити")
                        .font(.callout)
                        .foregroundColor(Color.gray)
                        .frame(alignment: .center)
                    
                    Button
                    {
                        if let url = URL(string: "https://support.apple.com/guide/mac-help/blth1004/mac")
                        {
                            NSWorkspace.shared.open(url)
                        }
                    }
                    label:
                    {
                        Text("[Тиць]")
                            .font(.callout)
                            .foregroundColor(Color.blue)
                            .frame(alignment: .center)
                    }
                    .buttonStyle(PlainButtonStyle())
                }// HStack with text for open bluetooth help
            }
        }// main VStack
        .padding()
        .navigationTitle(device.1)
    }
}
