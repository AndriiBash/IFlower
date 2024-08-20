//
//  ContentView.swift
//  iFlower
//
//  Created by Андрiй on 25.06.2024.
//

import SwiftUI

struct ContentView: View
{
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    @AppStorage("isFirstStart") private var isFirstStart: Bool = true

    @State private var selectedDeviceId: String?
    @State private var activeTab: String = ""
    @State private var columnVisibility = NavigationSplitViewVisibility.detailOnly
    @StateObject var bluetoothManager = BluetoothManager()
    
    var body: some View
    {
        NavigationSplitView(columnVisibility: $columnVisibility)
        {
            List(selection: $activeTab)
            {
                Section("Головне")
                {
                    NavigationLink(destination: EmptyView())
                    {
                        Label("Автоматизація", systemImage: "deskclock")
                    }
                    .tag("Автоматизація")

                    NavigationLink(destination: EmptyView())
                    {
                        Label("Дім", systemImage: "house")
                    }
                    .tag("Дім")

                    NavigationLink(destination: BluetoothConnectView(bluetoothManager: bluetoothManager, activeTab: $activeTab))
                    {
                        Label("Bluetooth сканер", systemImage: "antenna.radiowaves.left.and.right")
                    }
                    .tag("Bluetooth сканер")
                }// section main

                Section("Під'єднанні пристрої")
                {
                    ForEach(bluetoothManager.connectedDevices.indices, id: \.self)
                    { index in
                        let device = bluetoothManager.connectedDevices[index]
                        
                        NavigationLink(destination: DeviceControllerView(device: device, bluetoothManager: bluetoothManager))
                        {
                            Label(device.name, systemImage: "\(device.imageName)")
                        }
                        .tag(device.name)
                        .contextMenu
                        {                            
                            Button
                            {
                                bluetoothManager.removeConnectedDevice(at: index)
                                activeTab = "Bluetooth сканер"
                            }
                            label:
                            {
                                Text("Забути...")
                                Image(systemName: "antenna.radiowaves.left.and.right.slash")
                            }
                        }//.contextMenu
                    }// ForEach for connected device
                }// Section with connect device list
            }// main List
        }// NavigationSplitView
        detail:
        {
            VStack
            {
                Button("open start sheet")
                {
                    isFirstStart.toggle()
                }
            }
            .frame(width: 200, height: 450)
        }// detail
        .sheet(isPresented: $isFirstStart)
        {
            StartView()
        }
        .background(
            Image("mainBG_1")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .frame(width: NSScreen.main?.frame.width, height: NSScreen.main?.frame.height)
                .blur(radius: 15)
        )
    }
}
