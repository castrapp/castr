//
//  manager-LayoutManager.swift
//  castr
//
//  Created by Harrison Hall on 8/29/24.
//

import Foundation
import SwiftUI




struct Layout: NSViewRepresentable {
    
    static let shared = Layout()
    
    let layer = CALayer()
    
    private init() {
        layer.contentsGravity = .resizeAspect
//        layer.borderColor = CGColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)
//        layer.borderWidth = 1
    }
    
    func makeNSView(context: Context) -> LayoutPreview {
        LayoutPreview(layer: layer)
    }
    
    func updateNSView(_ nsView: LayoutPreview, context: Context) {}
    
    class LayoutPreview: NSView {
        
        init(layer: CALayer) {
            super.init(frame: .zero)
            self.layer = layer
            wantsLayer = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        
        override func mouseDown(with event: NSEvent) {
            print("Mouse downed")
            
        }
        
        override func mouseDragged(with event: NSEvent) {
            print("Mouse dragged")
        }
        
        override func mouseUp(with event: NSEvent) {
            print("Mouse upped")
        }
        
       
    }
}



