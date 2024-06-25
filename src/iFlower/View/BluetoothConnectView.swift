//
//  BluetoothConnectView.swift
//  iFlower
//
//  Created by Андрiй on 25.06.2024.
//

import SwiftUI

struct BluetoothConnectView: View {
    @StateObject var bluetoothManager = BluetoothManager()
    @State private var dataToSend = ""

    var body: some View {
        VStack {
            Text("Bluetooth Devices")
                .font(.largeTitle)
                .padding()

            List(bluetoothManager.deviceInfos, id: \.0) { device in
                VStack(alignment: .leading) {
                    Text("Name: \(device.1)")
                    Text("MAC Address: \(device.0)")
                    Button(action: {
                        if let index = bluetoothManager.deviceInfos.firstIndex(where: { $0.0 == device.0 }) {
                            let peripheral = bluetoothManager.peripherals[index]
                            bluetoothManager.connect(to: peripheral)
                        }
                    }) {
                        Text("Connect")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
            }

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
        }
        .onAppear {
            bluetoothManager.centralManagerDidUpdateState(bluetoothManager.centralManager)
        }
    }
}

#Preview {
    BluetoothConnectView()
}
