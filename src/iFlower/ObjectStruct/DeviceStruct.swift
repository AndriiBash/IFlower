//
//  DeviceStruct.swift
//  iFlower
//
//  Created by Андрiй on 08.08.2024.
//

import Foundation

struct DeviceStruct: Identifiable
{
    var id = UUID()
    var name: String
    var macAddress: String
    var imageName: String
}
