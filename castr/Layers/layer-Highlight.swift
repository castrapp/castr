//
//  layer-Highlight.swift
//  castr
//
//  Created by Harrison Hall on 8/30/24.
//

import Foundation
import SwiftUI
import AppKit

class HighlightLayer: CALayer {
    
    func highlight()  {
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        self.isHidden = false
        self.borderColor = CGColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
        self.borderWidth = 1
        
        CATransaction.commit()
    }
    
    func unhighlight(override: Bool = false)  {
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        self.isHidden = true
        self.borderColor = CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        self.borderWidth = 0
        
        CATransaction.commit()
    }
    
    override func resize(withOldSuperlayerSize oldSize: CGSize) {
        guard let superlayer = superlayer else { return }
        self.frame.size = superlayer.frame.size
        print("resizing")
    }
    
}
