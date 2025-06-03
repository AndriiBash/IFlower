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
    @State private var chartSelection: Int?
    
    let nameChart:      String
    let colorChart:     Color
    let data:           [Double]
    let yesterdayData:  [Double]
    let maxHeight:      CGFloat

    let linearGradient = LinearGradient(gradient: Gradient(colors: [Color.accentColor.opacity(0.4),
                                                                    Color.accentColor.opacity(0)]),
                                                                    startPoint: .top,
                                                                    endPoint: .bottom)

    var body: some View {
        ZStack {
            Color("MainBlurBGColor").opacity(0.25)
            
            HStack {
                VStack(alignment: .leading) {
                    Text(nameChart)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.primary)
                        .padding(.horizontal, 120)
                        .padding(.top, 2)
                    
                    Chart {
                        ForEach(Array(yesterdayData.enumerated()), id: \.offset)
                        { index, value in
                            LineMark(x: .value("Index", index),
                                     y: .value("Value", value),
                                     series: .value("", "yesterdayData"))
                            .foregroundStyle(Color.gray)
                            .lineStyle(.init(dash: [5, 5]))
                        }
                        .interpolationMethod(.catmullRom)

                        
                        ForEach(Array(data.enumerated()), id: \.offset)
                        { index, value in
                            LineMark(x: .value("index", index),
                                     y: .value("t", value))
                        }// make line
                        .foregroundStyle(colorChart)
                        .symbol(.circle)
                        .interpolationMethod(.catmullRom)


                        ForEach(Array(data.enumerated()), id: \.offset)
                        { index, value in
                            AreaMark(x: .value("index", index),
                                     y: .value("t", value))
                            
                        }
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(linearGradient)
                        
                        if let chartSelection
                        {
                            let isNearLeftEdge = chartSelection < 5
                            let isNearRightEdge = chartSelection > data.count - 5
                            let yesterdayValue = (yesterdayData.indices.contains(chartSelection)) ? yesterdayData[chartSelection] : 0

                            PointMark(x: .value("Index", chartSelection),
                                      y: .value("Value", data[chartSelection]))
                                .symbol(Circle())
                                .symbolSize(100)
                                .foregroundStyle(colorChart)
                                .annotation(position: isNearLeftEdge ? .trailing : isNearRightEdge ? .leading : .top)
                                {
                                    ZStack
                                    {
                                        Text("Температура о \(chartSelection):00\nСьогодні \(data[chartSelection], specifier: "%.2f") °C \nВчора була \(yesterdayValue, specifier: "%.2f") °C")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .padding(6)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(colorChart)
                                                    .shadow(radius: 3)
                                            )
                                    }
                                }
                        }// if selected chart, make pointMark with info about temperature
                    }// Chart
                    .chartLegend(.hidden)
                    .chartXScale(domain: 0 ... max(data.count - 1, 23))
                    .chartYScale(domain: 0 ... (data.max() ?? 1) * 1.5)
                    .chartXSelection(value: $chartSelection)
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
