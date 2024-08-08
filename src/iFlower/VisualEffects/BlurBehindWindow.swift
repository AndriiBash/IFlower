//
//  BlurBehindWindow.swift
//  iFlower
//
//  Created by Андрiй on 08.08.2024.
//

import Foundation
import SwiftUI

struct BlurBehindWindow: NSViewRepresentable
{
    func makeNSView(context: Context) -> NSVisualEffectView
    {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.state = .active
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.material = .hudWindow
        
        return visualEffectView
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
