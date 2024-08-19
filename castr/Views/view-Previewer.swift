//
//  view-Preview.swift
//  castr
//
//  Created by Harrison Hall on 8/4/24.
//

import Foundation
import SwiftUI

struct Previewer: NSViewRepresentable {

    static let shared = Previewer()
    
    let contentLayer = CALayer()
    
    private init() {
        contentLayer.contentsGravity = .resizeAspect
    }
    
    func makeNSView(context: Context) -> CaptureVideoPreview {
        CaptureVideoPreview(layer: contentLayer)
    }
    
    func updateNSView(_ nsView: CaptureVideoPreview, context: Context) {}
    
    class CaptureVideoPreview: NSView {
        
        init(layer: CALayer) {
            super.init(frame: .zero)
            self.layer = layer
            wantsLayer = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    
    }
}
