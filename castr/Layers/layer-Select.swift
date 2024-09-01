//
//  layer-Select.swift
//  castr
//
//  Created by Harrison Hall on 8/30/24.
//

import Foundation
import SwiftUI
import AppKit

class SelectLayer: CALayer {
    
    let outlineLayer = OutlineLayer()
    let topLeft = CornerBound(cornerType: .topLeft)
    let topRight = CornerBound(cornerType: .topRight)
    let bottomLeft = CornerBound(cornerType: .bottomLeft)
    let bottomRight = CornerBound(cornerType: .bottomRight)
    
    
    override init() {
        super.init()
        self.addSublayer(outlineLayer)
        self.addSublayer(topLeft)
        self.addSublayer(topRight)
        self.addSublayer(bottomLeft)
        self.addSublayer(bottomRight)
        
        topLeft.backgroundColor = CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        topRight.backgroundColor = CGColor(red: 0.5, green: 0.0, blue: 1.0, alpha: 1.0)
        bottomRight.backgroundColor = CGColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)
        // MARK: - Start - Debugging
//        self.borderColor = CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
//        self.borderWidth = 1
        // MARK: -  End - Debugging
       
        self.frame = CGRect(x: 0.0, y: 0.0, width: 100, height: 100)
        self.isHidden = false
        self.actions = ["hidden": NSNull()]
    
        
        repositionToSelected()
        resizeToSelected()
    }
    
    override init(layer: Any) {
            super.init(layer: layer)
            
            if let layer = layer as? SelectLayer {
                // Copy any custom properties from the original layer
                self.borderColor = layer.borderColor
                self.borderWidth = layer.borderWidth
                // Copy other properties as needed
            }
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isHidden: Bool {
        didSet {
            repositionToSelected()
            resizeToSelected()
        }
    }
    
    
    func repositionToSelected() {
        guard
            let superlayer = superlayer,
            let source = LayoutState.shared.selectedSourceLayer
        else { return }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        // 1. Reposition Frame
        self.frame.origin = Main.shared.preview.frame.origin + source.frame.origin
        
        // 2. Reposition Corner Bounds
        repositionBounds()
        
//        print("repositioning to selected")
//        print("selfs frame is: ", self.frame)
//        print("self frame isHidden: ", self.isHidden)
//        
//        print("source frames origin is: ", source.frame.origin)
//        print("sources position is: ", source.position)
//        print("outline layers frame origin is: ", outlineLayer.frame.origin)
        
        CATransaction.commit()
    }
    
    func resizeToSelected() {
        guard
            let superlayer = superlayer,
            let source = LayoutState.shared.selectedSourceLayer
        else { return }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        // 1. Resize Frame
        self.frame.size = source.frame.size
        
        // 2. Resize Frame Outline
        outlineLayer.frame.size = self.frame.size
        
        CATransaction.commit()
    }
    
    
    private func repositionBounds() {
        let BoundLengthHalf = topLeft.frame.width / 2
        topLeft.frame.origin = CGPoint(x: 0.0 - BoundLengthHalf, y: self.frame.height - BoundLengthHalf)
        topRight.frame.origin = CGPoint(x: self.frame.width - BoundLengthHalf, y: self.frame.height - BoundLengthHalf)
        bottomLeft.frame.origin = CGPoint(x: 0.0 - BoundLengthHalf, y: 0.0 - BoundLengthHalf)
        bottomRight.frame.origin = CGPoint(x: self.frame.width - BoundLengthHalf, y: 0.0 - BoundLengthHalf)
    }
    
    
    
    
    
    
    
    // Outline Layer
    class OutlineLayer: CALayer {
        
        override init() {
            super.init()
            self.borderColor = CGColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
            self.borderWidth = 1
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
    
    
   
}



//// Check for Metal Layer first
//if let deepestMetalLayer = deepestMetalLayer {
//    LayoutState.shared.selectedSourceLayer = deepestMetalLayer
//}
//
//// Then Bounds
//else if {
//    
//}
//else {
//    
//}
