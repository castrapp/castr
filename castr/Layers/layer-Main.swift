//
//  class-Main.swift
//  castr
//
//  Created by Harrison Hall on 8/30/24.
//

import Foundation
import AppKit



class MainLayer: CALayer {
    
   
    
    override func layoutSublayers() {

        guard let selectedSourceLayer = LayoutState.shared.selectedSourceLayer else { return }
       
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        Main.shared.onSelectlayer.frame.size = selectedSourceLayer.frame.size
//        Main.shared.onSelectlayer.frame.origin = selectedSourceLayer.convert(selectedSourceLayer.frame.origin, to: self)
        
        print("new frames origin should be: ",  selectedSourceLayer.convert(selectedSourceLayer.frame.origin, to: self))
        
        CATransaction.commit()
//        print("subviews should update")
    }
    
}
