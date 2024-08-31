//
//  Main.swift
//  castr
//
//  Created by Harrison Hall on 8/29/24.
//

import Foundation
import SwiftUI
import AppKit







class LayoutState {
    static let shared = LayoutState()
    
    var selectedSourceLayer: CAMetalLayer? {
        didSet {
            Main.shared.onSelectlayer.isHidden = (selectedSourceLayer == nil)
        }
    }
    
}








struct Main: NSViewRepresentable {
    
    static let shared = Main()
    
    let main = MainLayer()
    let preview = PreviewLayer()
    let onSelectlayer = SelectLayer()
    
    
    private init() {
        main.borderColor = CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        main.borderWidth = 1.0
        
        main.addSublayer(preview)
        main.addSublayer(onSelectlayer)
    }
    
    
    func makeNSView(context: Context) -> LayoutPreview {
        LayoutPreview(
            mainLayer: main,
            preview: preview,
            onSelectlayer: onSelectlayer
        )
    }
    
    func updateNSView(_ nsView: LayoutPreview, context: Context) {}
    
    
    

   
}




class LayoutPreview: NSView {
    
    let preview: PreviewLayer
    let onSelectlayer: SelectLayer
    var initalMouseDownPosition: NSPoint?
    var cornerBoundName: String?
   
    
    init(mainLayer: CALayer, preview: PreviewLayer, onSelectlayer: SelectLayer) {
        self.preview = preview
        self.onSelectlayer = onSelectlayer
        super.init(frame: .zero)
        self.layer = mainLayer
        wantsLayer = true
        
        self.addTrackingArea(NSTrackingArea(rect: self.bounds, options: [.mouseMoved, .activeInKeyWindow, .inVisibleRect], owner: self, userInfo: nil))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        for trackingArea in trackingAreas { removeTrackingArea(trackingArea) }
        addTrackingArea(NSTrackingArea(rect: self.bounds, options: [.mouseMoved, .activeInKeyWindow, .inVisibleRect, .mouseEnteredAndExited], owner: self, userInfo: nil))
    }
    
    
    override func mouseDown(with event: NSEvent) {
        let location = event.locationIn(in: self)
        initalMouseDownPosition = preview.convert(location, from: self.layer)
       
        
        
//        let mouseInViewCoordinates = convert(event.locationInWindow, from: nil)
        
        // If its a Corner Bound
        if let cornerBound = onSelectlayer.hitTest(location) as? CornerBounds {
            cornerBoundName = cornerBound.name
            print("CornerBounds hit: \(cornerBound.name ?? "Unknown")")
           
        }
        // If its a Metal Layer
        else if let deepestLayer = preview.hitTest(location) as? CustomMetalLayer {
            LayoutState.shared.selectedSourceLayer = deepestLayer
            print("MetalLayer hit: \(deepestLayer.name ?? "Unknown")")
        }
        
        
        
        // Otherwise
        else  {
            LayoutState.shared.selectedSourceLayer = nil
            cornerBoundName = nil
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        initalMouseDownPosition = nil
        cornerBoundName = nil
//            print("Mouse upped")
    }
    
    override func mouseEntered(with event: NSEvent) {
//            print("Mouse entered")
        

    }
    
    override func mouseExited(with event: NSEvent) {
//            print("Mouse exited")
    
    }


    override func mouseMoved(with event: NSEvent) {
        let mouseInViewCoordinates = convert(event.locationInWindow, from: nil)
        
        if let deepestLayer = preview.hitTest(mouseInViewCoordinates) as? CustomMetalLayer {
            let originInMainLayer = preview.convert(deepestLayer.frame.origin, to: self.layer)
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            
            onSelectlayer.frame.size = deepestLayer.frame.size
            onSelectlayer.frame.origin = originInMainLayer
            
            CATransaction.commit()
            
        } else {
            
        }
        
    }
    
    override func mouseDragged(with event: NSEvent) {
     
        guard var initialMouseDown = initalMouseDownPosition else { return }
        
        let currentLocation = event.locationIn(in: self)
        let convertedCurrentLocation = preview.convert(currentLocation, from: self.layer)
        
        let dragDifference = convertedCurrentLocation - initialMouseDown
        
        
        
        // For resizing the layer
        if let cornerBoundName = cornerBoundName {
              print("corner being dragged: ", cornerBoundName)
              return // Exit the function
        }
        
        
        
        // For moving the layer
        guard let selectedSourceLayer = LayoutState.shared.selectedSourceLayer else { return }
    
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        // 1. Set the selectedSourceLayer's origin
        selectedSourceLayer.frame.origin = selectedSourceLayer.frame.origin + dragDifference
        print("selected source layers frame is: ", selectedSourceLayer.frame)
        print("selected source layers bounds are: ", selectedSourceLayer.bounds.size)
        
        // 2. Set the onSelectLayers origin
        let newOrigin = preview.convert(selectedSourceLayer.frame.origin, to: self.layer)
        onSelectlayer.frame.origin = onSelectlayer.frame.origin + dragDifference
        CATransaction.commit()
        
        
        
        initalMouseDownPosition = convertedCurrentLocation
    }
    
    
    
    
} // End of class




extension NSEvent {
    func locationIn(in view: NSView?) -> CGPoint {
        guard let view = view else {
            return self.locationInWindow
        }
        return view.convert(self.locationInWindow, from: nil)
    }
}

extension CGPoint {
    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}
