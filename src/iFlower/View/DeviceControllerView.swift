//
//  deviceController.swift
//  iFlower
//
//  Created by Андрiй on 11.07.2024.
//

import SwiftUI

struct DeviceControllerView: View 
{
    var device: DeviceStruct
    @ObservedObject var bluetoothManager: BluetoothManager
    
    @State private var isShowSetting: Bool = false
    
    
    var body: some View
    {
        VStack 
        {
            if bluetoothManager.bluetoothEnabled
            {
                if bluetoothManager.isConnected
                {
                    Text("Device Name: \(device.name)")
                    Text("Device Address: \(device.macAddress)")
                    
                    HStack
                    {
                        Text("Вологість ґрунту: ")
                        Text(bluetoothManager.receivedData)
                            .foregroundColor(.blue)
                        Text("%")
                    }// HStack Received
                    
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
                        if let index = bluetoothManager.deviceInfos.firstIndex(where: { $0.macAddress == device.macAddress })
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
            }
            else
            {
                Image(systemName: "antenna.radiowaves.left.and.right.slash")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color.red)
                
                Text("\(device.name) наразі недоступний бо відсутній Bluetooth")
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
        .navigationTitle(device.name)
        .toolbar
        {
            ToolbarItemGroup(placement: .destructiveAction)
            {
                Button
                {
                    isShowSetting.toggle()
                }
                label:
                {
                    Image(systemName: "gearshape")
                }
                .help("Відкрити налаштування")
            }
        }
        .sheet(isPresented: $isShowSetting)
        {
            SettingDeviceView(bluetoothManager: bluetoothManager, isShowWindow: $isShowSetting, device: device)
        }
        .onAppear
        {
            if bluetoothManager.bluetoothEnabled
            {
                if let index = bluetoothManager.deviceInfos.firstIndex(where: { $0.name == device.name })
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
