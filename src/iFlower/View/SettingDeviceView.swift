//
//  SettingDeviceView.swift
//  iFlower
//
//  Created by Андрiй on 07.08.2024.
//

import SwiftUI

struct SettingDeviceView: View 
{
    @State private var dataToSend = ""
    @State private var editedNameDevice = ""
    @State private var selectedIcon = 0

    @ObservedObject var bluetoothManager: BluetoothManager
    @Binding var isShowWindow: Bool

    var device: DeviceStruct

    let wallpapers = ["camera.macro", "tree", "drop.degreesign", "apple.logo", "fan", "sprinkler.and.droplets", "carbon.dioxide.cloud", "tornado", "carrot", "leaf"]

    
    var body: some View
    {
        NavigationView
        {
            VStack
            {
                HStack
                {
                    Spacer()
                    
                    Button
                    {
                        bluetoothManager.saveDeviceSettings(for: device, newName: editedNameDevice, imageName: wallpapers[selectedIcon])
                        
                        isShowWindow.toggle()
                        // do something
                    }
                    label:
                    {
                        Text("Готово")
                            .fontWeight(.bold)
                            .foregroundColor(Color.accentColor)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)
                }// HStack title
                .padding(.top, 16)
                
                Form
                {
                    Section(header: Text("Головне"))
                    {
                        TextField("Назва пристрою", text: $editedNameDevice)
                            .overlay(
                                HStack
                                {
                                    Spacer()
                                    
                                    if editedNameDevice.isEmpty
                                    {
                                        Text("Назва вашого пристрою")
                                            .foregroundColor(Color.gray)
                                            .padding(.horizontal, 12)
                                    }
                                })// textField for name device
                    }// Main Section
                    
                    
                    Section(header: Text("Значок в сайд-барі"))
                    {
                        ScrollView(.horizontal, showsIndicators: true)
                        {
                            HStack
                            {
                                ForEach(0..<wallpapers.count, id: \.self)
                                { index in
                                    VStack
                                    {
                                        Image(systemName: wallpapers[index])
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 45, height: 45)
                                            .padding()
                                            .onTapGesture
                                            {
                                                selectedIcon = index
                                            }
                                    }// VStack with change image
                                    .background(index == selectedIcon ? Color.accentColor : Color.black.opacity(0.15))
                                    .cornerRadius(8)
                                }
                            }
                            .padding(.bottom, 14)
                        }// ScrollView for change image device in sidebar
                    }// Section for change image device in sidebar
                }// Section with textField
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.clear)
                .formStyle(.grouped)
            }// Main VStack
            .frame(width: 400, height: 600)
        }// NavigationView
        .frame(width: 400, height: 600)
        .onAppear
        {
            editedNameDevice = device.name
            if let index = wallpapers.firstIndex(of: device.imageName)
            {
                selectedIcon = index
            }
        }
        .background(BlurBehindWindow())
    }
}

