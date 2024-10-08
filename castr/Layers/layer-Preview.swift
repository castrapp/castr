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
        
        resizeSelectedLayer()
    }
    
    
    override func action(forKey event: String) -> CAAction? {
        return NSNull()
        
    }
    
    
    func resizeSelectedLayer() {
//        guard
//            let selectedLayer = LayoutState.shared.selectedSourceLayer
//        else { return }
        
        print("resizing selected layer")
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if let sublayers = self.sublayers {
            for layer in sublayers {
                layer.frame.size = self.frame.size
            }
        }
//        selectedLayer.frame.size = self.frame.size
        
        CATransaction.commit()
    }
}
