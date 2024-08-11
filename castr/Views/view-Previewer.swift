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
    
//    @ObservedObject var previewerManager = PreviewerManager.shared
    
    let contentLayer = CALayer()
    
    private init() {
        contentLayer.contentsGravity = .resizeAspect
        LayerToSampleBufferConverter.shared.setRootLayer(contentLayer)
    }
    
    func makeNSView(context: Context) -> CaptureVideoPreview {
        CaptureVideoPreview(layer: contentLayer)
    }
    
    func updateNSView(_ nsView: CaptureVideoPreview, context: Context) {}
    
    class CaptureVideoPreview: NSView {
        // Create the preview with the video layer as the backing layer.
        init(layer: CALayer) {
            super.init(frame: .zero)
            // Make this a layer-hosting view. First set the layer, then set wantsLayer to true.
            self.layer = layer
            wantsLayer = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
