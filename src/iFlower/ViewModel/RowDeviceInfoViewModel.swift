//
//  RowDeviceInfoViewModel.swift
//  iFlower
//
//  Created by Андрiй on 09.08.2024.
//

import SwiftUI

struct RowDeviceInfoViewModel: View
{
    let imageName: String
    let mainText:  String
    let bodyText:  String
    let colorImage: Color

    var body: some View
    {
        ZStack
        {
            Color("MainBlurBGColor").opacity(0.25)
            
            HStack
            {
                Image(systemName: imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .foregroundColor(colorImage)
                
                VStack(alignment: .leading)
                {
                    Text(mainText)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.primary)
                    Text(bodyText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }// VStack with detail info
                .padding(.leading, 2)
            }// Main HStack
            .padding(10)
        }// ZStack with info
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}
