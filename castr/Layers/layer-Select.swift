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
    
    override init() {
        super.init()
    
        self.borderColor = CGColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
        self.borderWidth = 1
        self.frame = CGRect(x: 0.0, y: 0.0, width: 100, height: 100)
        self.isHidden = false
        repositionToSelected()
        resizeToSelected()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isHidden: Bool {
        didSet {
            guard let source = LayoutState.shared.selectedSourceLayer else { return }
            print("ISHIDDEN IS SET")

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
        
        self.frame.origin = Main.shared.preview.frame.origin + source.frame.origin
        
        CATransaction.commit()
    }
    
    func resizeToSelected() {
        guard
            let superlayer = superlayer,
            let source = LayoutState.shared.selectedSourceLayer
        else { return }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        self.frame.size = source.frame.size
        
        CATransaction.commit()
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
