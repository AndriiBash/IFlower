//
//  RangedSliderView.swift
//  iFlower
//
//  Created by Андрiй on 24.02.2025.
//

import SwiftUI
import Foundation

struct RangedSliderView: View {
    @Binding var minValue: Int
    @Binding var maxValue: Int
    let sliderBounds: ClosedRange<Int>
    
    public init(minValue: Binding<Int>, maxValue: Binding<Int>, bounds: ClosedRange<Int>) {
        self._minValue = minValue
        self._maxValue = maxValue
        self.sliderBounds = bounds
    }
    
    var body: some View {
        GeometryReader { geometry in
            sliderView(sliderSize: geometry.size)
        }
    }
    
    @ViewBuilder private func sliderView(sliderSize: CGSize) -> some View {
        let sliderViewYCenter = sliderSize.height / 2
        ZStack {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.gray)
                .frame(height: 4)
            ZStack {
                let sliderBoundDifference = sliderBounds.count
                let stepWidthInPixel = CGFloat(sliderSize.width) / CGFloat(sliderBoundDifference)
                
                let leftThumbLocation = CGFloat(minValue - sliderBounds.lowerBound) * stepWidthInPixel
                let rightThumbLocation = CGFloat(maxValue - sliderBounds.lowerBound) * stepWidthInPixel
                
                lineBetweenThumbs(from: .init(x: leftThumbLocation, y: sliderViewYCenter), to: .init(x: rightThumbLocation, y: sliderViewYCenter))
                
                thumbView(position: CGPoint(x: leftThumbLocation, y: sliderViewYCenter), value: minValue)
                    .highPriorityGesture(DragGesture().onChanged { dragValue in
                        let dragLocation = dragValue.location.x
                        let xThumbOffset = min(max(0, dragLocation), sliderSize.width)
                        let newValue = Int(Float(sliderBounds.lowerBound) + Float(xThumbOffset / stepWidthInPixel))
                        if newValue < maxValue {
                            minValue = newValue
                        }
                    })
                
                thumbView(position: CGPoint(x: rightThumbLocation, y: sliderViewYCenter), value: maxValue)
                    .highPriorityGesture(DragGesture().onChanged { dragValue in
                        let dragLocation = dragValue.location.x
                        let xThumbOffset = min(max(CGFloat(leftThumbLocation), dragLocation), sliderSize.width)
                        let newValue = Int(Float(sliderBounds.lowerBound) + Float(xThumbOffset / stepWidthInPixel))
                        if newValue > minValue {
                            maxValue = newValue
                        }
                    })
            }
        }
    }
    
    @ViewBuilder func lineBetweenThumbs(from: CGPoint, to: CGPoint) -> some View {
        Path { path in
            path.move(to: from)
            path.addLine(to: to)
        }.stroke(Color.green, lineWidth: 4)
    }
    
    @ViewBuilder func thumbView(position: CGPoint, value: Int) -> some View {
        ZStack {
            Text("\(value)%")
                .font(.system(size: 10, weight: .semibold))
                .offset(y: -20)
            Circle()
                .frame(width: 24, height: 24)
                .foregroundColor(Color.accentColor)
                .shadow(color: Color.black.opacity(0.16), radius: 8, x: 0, y: 2)
                .contentShape(Rectangle())
        }
        .position(x: position.x, y: position.y)
    }
}
