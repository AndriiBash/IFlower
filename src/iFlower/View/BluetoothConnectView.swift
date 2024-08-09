//
//  BluetoothConnectView.swift
//  iFlower
//
//  Created by Андрiй on 25.06.2024.
//

import SwiftUI

struct BluetoothConnectView: View
{
    @ObservedObject var bluetoothManager: BluetoothManager
    @Binding var activeTab: String
    @State private var buttonIsClicked: Bool = true
    
    var body: some View
    {
        VStack
        {
            if bluetoothManager.bluetoothEnabled
            {
                List(bluetoothManager.deviceInfos)
                { device in
                    VStack(alignment: .leading)
                    {
                        Text("Назва: \(device.name)")
                        Text("MAC Адреса: \(device.macAddress)")
                        
                        Button
                        {
                            if let index = bluetoothManager.deviceInfos.firstIndex(where: { $0.macAddress == device.macAddress })
                            {
                                let peripheral = bluetoothManager.peripherals[index]
                                bluetoothManager.connect(to: peripheral)
                                
                                activeTab = "\(device.name)"
                                print("\(activeTab)")
                            }
                        }
                        label:
                        {
                            Text("Додати")
                                .foregroundColor(.blue)
                        }
                    }// VStack with card device for connecting
                    .padding()
                }// List bluetooth device Infos

                VStack
                {
                    if buttonIsClicked
                    {
                        HStack(spacing: 4)
                        {
                            ProgressView()
                                .controlSize(.small)

                            Text("Триває пошук...")
                        }// HStack with ProgressView
                    }
                    
                    Button
                    {
                        withAnimation(Animation.easeIn(duration: 0.25))
                        {
                            buttonIsClicked.toggle()
                        }
                        
                        if buttonIsClicked
                        {
                            bluetoothManager.deviceInfos.removeAll()
                            
                            bluetoothManager.centralManagerDidUpdateState(bluetoothManager.centralManager)
                            bluetoothManager.startScanning()
                            Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true)
                            { _ in
                                bluetoothManager.updateDeviceList()
                            }
                        }
                        else
                        {
                            bluetoothManager.stopScanning()
                        }
                    }
                    label:
                    {
                        Text(buttonIsClicked ? "Закінчити" : "Почати пошук")
                    }
                    .padding(.vertical, 4)
                }// VStack with stop and start search bluetooth devices
                .padding(.vertical, 6)
            }
            else
            {
                Image(systemName: "antenna.radiowaves.left.and.right.slash")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color.red)
                
                Text("Bluetooth наразі недоступний")
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
        }
        .navigationTitle("Bluetooth пристрої")
        .background(bluetoothManager.bluetoothEnabled ? Color("SecondBGColor") : Color.clear)
    }
}
