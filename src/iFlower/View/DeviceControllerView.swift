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
    
    @State private var isShowSetting:               Bool = false
    @State private var isShowDeviceSensor:          Bool = true
    @State private var isShowDeviceInfo:            Bool = true
    
    @State private var scrollViewSensorHeight:      CGFloat = 65
    @State private var scrollViewInfoHeight:        CGFloat = 120
    
    var body: some View
    {
        VStack 
        {
            if bluetoothManager.bluetoothEnabled
            {
                if bluetoothManager.isConnected
                {
                    ScrollView
                    {
                        HStack
                        {
                            Button
                            {
                                withAnimation(Animation.easeInOut(duration: 0.2))
                                {
                                    self.isShowDeviceInfo.toggle()
                                    scrollViewInfoHeight = isShowDeviceInfo ? 120 : 0
                                }
                            }
                            label:
                            {
                                Text("Про девайс")
                                    .foregroundColor(Color.primary)
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 15, height: 15, alignment: .center)
                                    .foregroundColor(Color.primary)
                                    .rotationEffect(.degrees(isShowDeviceInfo ? 90 : 0))
                                    .animation(.easeInOut(duration: 0.2), value: isShowDeviceInfo)
                            }// Button for show and hide info from sensor
                            .buttonStyle(PlainButtonStyle())
                            .padding(.top)
                            .padding(.leading)
                            
                            Spacer()
                        }//HStack with button for open or close scrollView with info about device
                        
                        ScrollView(.horizontal, showsIndicators: false)
                        {
                            LazyHGrid(rows: [GridItem(.adaptive(minimum: 90))], spacing: 20)
                            {
                                ZStack
                                {
                                    Color("MainBlurBGColor").opacity(0.25)
                                    
                                    HStack
                                    {
                                        Image(systemName: "info.circle")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(Color.blue)
                                        
                                        VStack(alignment: .leading)
                                        {
                                            Text(device.name)
                                                .font(.headline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color.primary)

                                            Text("Версія прошивки: " + bluetoothManager.iFlowerMainDevice.versionFirmware)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            
                                            Text("s/n. " + bluetoothManager.iFlowerMainDevice.serialNumber)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }// VStack with detail info
                                        .padding(.leading, 2)
                                    }// Main HStack
                                    .padding(10)
                                    .padding(.vertical, 40)
                                }// ZStack with info
                                .frame(maxHeight: 120)
                                .cornerRadius(20)
                                .shadow(radius: 5)
                            }// LazyHGrid
                            .padding()
                        }// ScrollView with the main information iFlower device
                        .frame(height: scrollViewInfoHeight)
                        
                        
                        HStack
                        {
                            Button
                            {
                                withAnimation(Animation.easeInOut(duration: 0.2))
                                {
                                    self.isShowDeviceSensor.toggle()
                                    scrollViewSensorHeight = isShowDeviceSensor ? 65 : 0
                                }
                            }
                            label:
                            {
                                Text("Сенсори біля рослини")
                                    .foregroundColor(Color.primary)
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 15, height: 15, alignment: .center)
                                    .foregroundColor(Color.primary)
                                    .rotationEffect(.degrees(isShowDeviceSensor ? 90 : 0))
                                    .animation(.easeInOut(duration: 0.2), value: isShowDeviceSensor)
                            }// Button for show and hide info from sensor
                            .buttonStyle(PlainButtonStyle())
                            .padding(.top)
                            .padding(.leading)
                            
                            Spacer()
                        }//HStack with button for open or close scrollView with info from sensor's
                        
                        ScrollView(.horizontal, showsIndicators: false)
                        {
                            LazyHGrid(rows: [GridItem(.adaptive(minimum: 90))], spacing: 20)
                            {
                                RowDeviceInfoViewModel(imageName: "drop.fill", mainText: "Вологість ґрунту", bodyText: String(bluetoothManager.iFlowerMainDevice.soilMoisture) + "%", colorImage: Color.blue)

                                RowDeviceInfoViewModel(imageName: "thermometer.medium", mainText: "Температура", bodyText: String(bluetoothManager.iFlowerMainDevice.airTemperature) + "°C", colorImage: Color.blue)
                                
                                RowDeviceInfoViewModel(imageName: "humidity", mainText: "Волога повітря", bodyText: String(bluetoothManager.iFlowerMainDevice.airHumidity) + "%", colorImage: Color.blue)
                                
                                RowDeviceInfoViewModel(imageName: "lightbulb", mainText: "Світловий поток", bodyText: String(bluetoothManager.iFlowerMainDevice.lightLevel) + " Люменів", colorImage: Color.blue)
                            }// LazyHGrid
                            .padding()
                        }// ScrollView with the main information iFlower device
                        .frame(height: scrollViewSensorHeight)
                        
                        Spacer()
                        
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
                    }// ScrollView with main info
                }// if process connecting
                else
                {
                    ZStack
                    {
                        Color("MainBlurBGColor").opacity(0.25)
                        
                        ProgressView("Під'єднання...")
                    }// ZStack with loading
                    .frame(width: 150, height: 150)
                    .cornerRadius(25)
                    .shadow(radius: 10)
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
                    .foregroundColor(Color.primary)
                    .frame(maxWidth: .infinity, alignment: .center)

                HStack(spacing: 4)
                {
                    Text("Скоріш за всього в налаштуваннях потрібно включити bluetooth, як це зробити")
                        .font(.callout)
                        .foregroundColor(Color.secondary)
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
