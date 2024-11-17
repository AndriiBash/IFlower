//
//  GraphViewModel.swift
//  iFlower
//
//  Created by Андрiй on 17.11.2024.
//

import SwiftUI
import Charts

struct ChartMarkGradientViewModel: View
{
    let nameChart:  String
    let colorChart: Color
    let data:       [Double]
    let maxHeight:  CGFloat

    let linearGradient = LinearGradient(gradient: Gradient(colors: [Color.accentColor.opacity(0.4),
                                                                    Color.accentColor.opacity(0)]),
                                                                    startPoint: .top,
                                                                    endPoint: .bottom)

    var body: some View
    {
        ZStack
        {
            Color("MainBlurBGColor").opacity(0.25)
            
            HStack
            {
                VStack(alignment: .leading)
                {
                    Text(nameChart)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.primary)
                        .padding(.horizontal, 120)
                        .padding(.top, 2)
                    
                    Chart
                    {
                        ForEach(Array(data.enumerated()), id: \.offset)
                        { index, value in
                            LineMark(x: .value("index", index),
                                     y: .value("t", value))
                            .foregroundStyle(colorChart)
                        }// make line
                        .symbol(.circle)
                        .interpolationMethod(.catmullRom)

                        ForEach(Array(data.enumerated()), id: \.offset)
                        { index, value in
                            AreaMark(x: .value("index", index),
                                     y: .value("t", value))
                        }
                        .interpolationMethod(.cardinal)
                        .foregroundStyle(linearGradient)

                    }// Chart
                    .chartLegend(.hidden)
                    .padding(.vertical, 4)
                }// VStack with detail info
            }// Main HStack
            .padding(10)
        }// ZStack with info
        .frame(maxHeight: maxHeight)
        .cornerRadius(20)
        .shadow(radius: 5)
    }
}
