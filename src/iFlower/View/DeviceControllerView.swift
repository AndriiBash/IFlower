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
    @State private var isShowActions:               Bool = true
    @State private var isShowCharts:                Bool = true

    @State private var scrollViewSensorHeight:      CGFloat = 55
    @State private var scrollViewActionsHeight:     CGFloat = 65
    @State private var scrollViewInfoHeight:        CGFloat = 120
    @State private var scrollViewChartHeight:       CGFloat = 190

    
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
                                            .foregroundColor(Color.accentColor)
                                        
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
                                .frame(maxHeight: scrollViewInfoHeight)
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
                                    scrollViewSensorHeight = isShowDeviceSensor ? 55 : 0
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
                                RowDeviceInfoViewModel(imageName: "drop.fill", mainText: "Вологість ґрунту", bodyText: String(bluetoothManager.iFlowerMainDevice.soilMoisture) + "%", colorImage: Color.accentColor, maxHeight: scrollViewSensorHeight)

                                RowDeviceInfoViewModel(imageName: "thermometer.medium", mainText: "Температура", bodyText: String(bluetoothManager.iFlowerMainDevice.airTemperature) + "°C", colorImage: Color.accentColor, maxHeight: scrollViewSensorHeight)
                                
                                RowDeviceInfoViewModel(imageName: "humidity", mainText: "Волога повітря", bodyText: String(bluetoothManager.iFlowerMainDevice.airHumidity) + "%", colorImage: Color.accentColor, maxHeight: scrollViewSensorHeight)
                                
                                RowDeviceInfoViewModel(imageName: "lightbulb", mainText: "Рівень освітлення", bodyText: String(bluetoothManager.iFlowerMainDevice.lightLevel) + " Люменів", colorImage: Color.accentColor, maxHeight: scrollViewSensorHeight)
                            }// LazyHGrid
                            .padding(.horizontal)
                        }// ScrollView with the main information from sensor's
                        .frame(height: scrollViewSensorHeight)
                        
                        HStack
                        {
                            Button
                            {
                                withAnimation(Animation.easeInOut(duration: 0.2))
                                {
                                    self.isShowActions.toggle()
                                    scrollViewActionsHeight = isShowActions ? 65 : 0
                                }
                            }
                            label:
                            {
                                Text("Дії над рослиною")
                                    .foregroundColor(Color.primary)
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 15, height: 15, alignment: .center)
                                    .foregroundColor(Color.primary)
                                    .rotationEffect(.degrees(isShowActions ? 90 : 0))
                                    .animation(.easeInOut(duration: 0.2), value: isShowActions)
                            }// Button for show and hide info from sensor
                            .buttonStyle(PlainButtonStyle())
                            .padding(.top)
                            .padding(.leading)
                            
                            Spacer()
                        }//HStack with button for open or close scrollView with action's
                        
                        ScrollView(.horizontal, showsIndicators: false)
                        {
                            LazyHGrid(rows: [GridItem(.adaptive(minimum: 90))], spacing: 20)
                            {
                                Button
                                {
                                    // добавить проверку на влажность почвы, и в случае большой влаге выдавать ошибку пользователю и не возможностью включить полив, использовать алерт
                                    withAnimation(Animation.easeInOut(duration: 0.25))
                                    {
                                        self.bluetoothManager.iFlowerMainDevice.isWatering.toggle()
                                    }
                                    
                                    if self.bluetoothManager.iFlowerMainDevice.isWatering
                                    {
                                        self.bluetoothManager.sendData("turnOnWatering\n")
                                    }
                                    else
                                    {
                                        self.bluetoothManager.sendData("turnOffWatering\n")
                                    }
                                }
                                label:
                                {
                                    ZStack
                                    {
                                        Color(self.bluetoothManager.iFlowerMainDevice.isWatering ? "MainBGUsedColor" : "MainBlurBGColor").opacity(0.25)

                                        HStack
                                        {
                                            Image(systemName: self.bluetoothManager.iFlowerMainDevice.isWatering ? "drop.degreesign" : "drop")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 20, height: 20)
                                                .foregroundColor(bluetoothManager.iFlowerMainDevice.isWatering ? Color.accentColor : Color.gray)
                                            
                                            VStack(alignment: .leading)
                                            {
                                                Text(self.bluetoothManager.iFlowerMainDevice.isWatering ? "Виключити полив рослини" : "Включити полив рослини")
                                                    .font(.headline)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(Color.primary)
                                                    .padding(.vertical)
                                            }// VStack with detail info
                                            .padding(.leading, 2)
                                        }// Main HStack
                                        .padding(10)
                                    }// ZStack with info
                                    .frame(maxHeight: scrollViewActionsHeight)
                                    .cornerRadius(20)
                                    .shadow(radius: 5)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }// LazyHGrid
                            .padding()
                        }// ScrollView with the main information iFlower device
                        .frame(height: scrollViewActionsHeight)
                        
                        
                        HStack
                        {
                            Button
                            {
                                withAnimation(Animation.easeInOut(duration: 0.2))
                                {
                                    self.isShowCharts.toggle()
                                    scrollViewChartHeight = isShowCharts ? 190 : 0
                                }
                            }
                            label:
                            {
                                Text("Графіки")
                                    .foregroundColor(Color.primary)
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 15, height: 15, alignment: .center)
                                    .foregroundColor(Color.primary)
                                    .rotationEffect(.degrees(isShowCharts ? 90 : 0))
                                    .animation(.easeInOut(duration: 0.2), value: isShowCharts)
                            }// Button for show and hide info from sensor
                            .buttonStyle(PlainButtonStyle())
                            .padding(.top)
                            .padding(.leading)
                            
                            Spacer()
                        }//HStack with button for open or close scrollView graph with action's

                        ScrollView(.horizontal, showsIndicators: false)
                        {
                            LazyHGrid(rows: [GridItem(.adaptive(minimum: 200))], spacing: 20)
                            {
                                // uvaga! Used fake data

                                ChartMarkGradientViewModel(nameChart: "Температура", colorChart: Color.accentColor, data: [20, 22, 17, 12, 15, 24, 19, 14, 15, 17, 12, 23, 20, 22, 17, 12, 15, 24, 19, 14, 15, 17, 12, 23],
                                    yesterdayData: [26, 23, 23, 21, 23, 25, 24, 17, 18, 19, 13, 20, 23, 25, 12, 12, 19, 20, 23, 20, 21, 22, 23, 24], maxHeight: scrollViewChartHeight)
                            }// LazyHGrid
                            .padding(.horizontal)
                        }// ScrollView with the graph build on sensor's
                        .frame(height: scrollViewChartHeight)
                        
                        Spacer()
                        
                        //Text("Device Name: \(device.name)")
                        //Text("Device Address: \(device.macAddress)")
                        
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
                            .foregroundColor(Color.accentColor)
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
