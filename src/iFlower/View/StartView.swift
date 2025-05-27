//
//  StartView.swift
//  iFlower
//
//  Created by Андрiй on 07.07.2024.
//

import SwiftUI

struct StartView: View 
{
    @AppStorage("isFirstStart") private var isFirstStart: Bool = true
    @State private var animateRowIndo: Bool = true
    
    var body: some View
    {
        VStack
        {
            VStack
            {
                Image(systemName: "leaf.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100, alignment: .center)
                    .foregroundColor(Color.green)
                
                Text("Зустрічайте")
                Text("iFlower!")
                    .foregroundColor(Color.accentColor)
            }// VStack header
            .font(.largeTitle.bold())
            .padding(.top, 18)

            VStack(spacing: 15)
            {
                RowStartInfoViewModel(isAnimated: $animateRowIndo,
                                      imageName: "sprinkler.and.droplets",
                                      mainText: String(localized: "Догляд за рослиною"),
                                      bodyText: "iFlower дозволяє дистанційно займатись поливом рослини")

                RowStartInfoViewModel(isAnimated: $animateRowIndo,
                                      imageName: "thermometer.sun",
                                      mainText: String(localized: "Отримання даних"),
                                      bodyText: "Завдяки застосунку у Вас є можливість слідкуванням за датчиками, які надають інформацію про вологість повітря, ґрунту тощо")

                RowStartInfoViewModel(isAnimated: $animateRowIndo,
                                      imageName: "chart.xyaxis.line",
                                      mainText: String(localized: "Графічний аналіз"),
                                      bodyText: "Застосунок надає можливість перегляду зміни температури або вологості з пливом часу")
            }// VStack with main info about app
            .padding(.top, 30)
            .padding(.horizontal, 12)

            Spacer()
            
            Button
            {
                animateRowIndo = false
                isFirstStart = false
            }
            label:
            {
                Text(String(localized: "Далі"))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 34)
                    .font(.body)
                    .foregroundColor(Color("MainTextColor"))
            }// button for open main window
            .keyboardShortcut(.defaultAction)
            .shadow(radius: 2)
            .padding()
        }// main VStack
        .frame(minWidth: 390, maxWidth: 390,
               minHeight: 600, maxHeight: 600)
        .fixedSize()
        .navigationTitle("")
    }
}

#Preview 
{
    StartView()
}
