//
//  MaterialView.swift
//  castr
//
//  Created by Harrison Hall on 8/13/24.
//

import Foundation
import SwiftUI

struct MaterialView: NSViewRepresentable {
    var material: NSVisualEffectView.Material = .sidebar  // Add a customizable material property with a default value

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material  // Use the customizable material
        view.blendingMode = .behindWindow
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}


