//
//  RowStartInfoViewModel.swift
//  iFlower
//
//  Created by Андрiй on 07.07.2024.
//

import SwiftUI

struct RowStartInfoViewModel: View 
{
    @Binding var isAnimated: Bool
    @State var startAnimate: Bool = true
    
    let imageName: String
    let mainText:  String
    let bodyText:  String
    
    var body: some View {
        HStack {
            Image(systemName: imageName)
                .resizable()
                .foregroundColor(Color.accentColor)
                .aspectRatio(contentMode: .fit)
                .frame(width: 35, height: 35, alignment: .center)
                .symbolEffect(.bounce, value: startAnimate)
                .onAppear {
                    animateIcon()
                }
            
            VStack {
                Text("\(mainText)")
                    .font(.body.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("\(bodyText)")
                    .font(.callout)
                    .foregroundColor(Color.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
            } // VStack with info
            .padding(.horizontal, 12)
            
            Spacer()
        } // Main HStack with info and image
        .padding(6)
        .padding(.horizontal, 12)
    }// body
    
    func animateIcon() {
        if isAnimated {
            startAnimate.toggle()
            
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 5) {
                DispatchQueue.main.async {
                    animateIcon()
                }
            }
        }
    }// animateIcon func}
}


