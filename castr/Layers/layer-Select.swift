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
    
    let outlineLayer: OutlineLayer = OutlineLayer()
    let topLeft: CornerBounds = CornerBounds(cornerType: .topLeft)
    let topRight: CornerBounds = CornerBounds(cornerType: .topRight)
    let bottomLeft: CornerBounds = CornerBounds(cornerType: .bottomLeft)
    let bottomRight: CornerBounds  = CornerBounds(cornerType: .bottomRight)
    
    override init() {
        super.init()
    
        self.addSublayer(outlineLayer)

        self.addSublayer(topLeft)
        self.addSublayer(topRight)
        self.addSublayer(bottomLeft)
        self.addSublayer(bottomRight)
        
        topLeft.resize(withOldSuperlayerSize: CGSize(width: 10, height: 10))
        topRight.resize(withOldSuperlayerSize: CGSize(width: 10, height: 10))
        bottomLeft.resize(withOldSuperlayerSize: CGSize(width: 10, height: 10))
        bottomRight.resize(withOldSuperlayerSize: CGSize(width: 10, height: 10))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    
//    override func resize(withOldSuperlayerSize size: CGSize) {
//       print("resizing is required")
//        
//        guard let selectedSourceLayer = LayoutState.shared.selectedSourceLayer else { return }
//        guard let superlayer = superlayer else { return }
//        
//        CATransaction.begin()
//        CATransaction.setDisableActions(true)
//        
//        self.frame.size = selectedSourceLayer.frame.size
//        self.frame.origin = selectedSourceLayer.convert(selectedSourceLayer.frame.origin, to: superlayer)
//        
//        CATransaction.commit()
//
//    }
//    

    
    
    
    // OutlineLayer Layer
    class OutlineLayer: CALayer {
        
        override init() {
            super.init()
            self.borderColor = CGColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
            self.borderWidth = 1
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func resize(withOldSuperlayerSize size: CGSize) {
            guard let superlayer = superlayer else { return }
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.frame.size = superlayer.frame.size
            CATransaction.commit()
        }
        

    }
}
