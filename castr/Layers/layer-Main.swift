//
//  class-Main.swift
//  castr
//
//  Created by Harrison Hall on 8/30/24.
//

import Foundation
import AppKit



class RootLayer: CALayer {
    
    override func layoutSublayers() {
        Main.shared.onSelectlayer.repositionToSelected()
        Main.shared.onSelectlayer.resizeToSelected()
    }
    
}
