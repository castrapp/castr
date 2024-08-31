//
//  layer-Preview.swift
//  castr
//
//  Created by Harrison Hall on 8/30/24.
//

import Foundation
import SwiftUI



class PreviewLayer: CALayer {
    
    override init () {
        super.init()
        self.borderColor = CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.25)
        self.borderWidth = 1.0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func resize(withOldSuperlayerSize oldSize: CGSize) {

        guard let superlayer = superlayer else { return }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let parentWidth = superlayer.frame.width
        let desiredWidth = 3456.0
        let desiredHeight = 2234.0
        let scaleRatio = parentWidth / desiredWidth

        let newWidth = desiredWidth * scaleRatio
        let newHeight = desiredHeight * scaleRatio

        let paddedWidth = newWidth - 30.0
        let paddedHeight = newHeight * (paddedWidth / newWidth)

        let originX = (superlayer.bounds.width - paddedWidth) / 2
        let originY = (superlayer.bounds.height - paddedHeight) / 2

        self.frame = CGRect(
            origin: CGPoint(x: originX, y: originY),
            size: CGSize(width: paddedWidth, height: paddedHeight)
        )
        
        CATransaction.commit()
    }
    
    
    override func action(forKey event: String) -> CAAction? {
        return NSNull()
        
    }
    
    
//    func resizeSelectedLayer() {
//        guard let selectedLayer = LayoutState.shared.selectedSourceLayer else { return }
//        
//        CATransaction.begin()
//        CATransaction.setDisableActions(true)
//
//        // 1. set the size
//        Main.shared.onSelectlayer.frame.size = selectedLayer.frame.size
//
//       
//        // 2. set the origin
//        let newOrigin = selectedLayer.convert(selectedLayer.frame.origin, to: Main.shared.main)
//        Main.shared.onSelectlayer.frame.origin = newOrigin
//        
//        CATransaction.commit()
//    }
}
