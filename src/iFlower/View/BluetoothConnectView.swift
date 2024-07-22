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
            List(bluetoothManager.deviceInfos, id: \.0)
            { device in
                VStack(alignment: .leading)
                {
                    Text("Name: \(device.1)")
                    Text("MAC Address: \(device.0)")
                    
                    Button
                    {
                        if let index = bluetoothManager.deviceInfos.firstIndex(where: { $0.0 == device.0 })
                        {
                            let peripheral = bluetoothManager.peripherals[index]
                            bluetoothManager.connect(to: peripheral)
                            
                            activeTab = "\(device.1)"
                            print("\(activeTab)")
                        }
                    }
                    label:
                    {
                        Text("Додати")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
            }
            
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
                        bluetoothManager.deviceInfos.removeAll()//{ bluetoothManager.missingDevices.contains($0.0) }
                        
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
        .navigationTitle("Bluetooth девайси")
    }
}
