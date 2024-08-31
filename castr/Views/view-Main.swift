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
            print("selected source is: ", selectedSourceLayer)
        }
    }
    
}








struct Main: NSViewRepresentable {
    
    static let shared = Main()
    
    let root = RootLayer()
    let preview = PreviewLayer()
    let onSelectlayer = SelectLayer()
    
    
    private init() {
        root.borderColor = CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        root.borderWidth = 1.0
        
        root.addSublayer(preview)
        root.addSublayer(onSelectlayer)
    }
    
    
    func makeNSView(context: Context) -> LayoutPreview {
        LayoutPreview(
            rootLayer: root,
            previewLayer: preview,
            onSelectLayer: onSelectlayer
        )
    }
    
    func updateNSView(_ nsView: LayoutPreview, context: Context) {}
    
    
    

   
}




class LayoutPreview: NSView {
    
    let rootLayer: RootLayer
    let previewLayer: PreviewLayer
    let onSelectLayer: SelectLayer
    var mouseDownPositionInMain: NSPoint?
    var boundLayer: CornerBound?
   
    
    init(rootLayer: RootLayer, previewLayer: PreviewLayer, onSelectLayer: SelectLayer) {
        self.rootLayer = rootLayer
        self.previewLayer = previewLayer
        self.onSelectLayer = onSelectLayer
        super.init(frame: .zero)
        
        self.layer = rootLayer
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
        mouseDownPositionInMain = event.locationIn(in: self)
        
        guard 
            let location = mouseDownPositionInMain
        else { return }
        
        print("mouse down")
        // MARK: -
        // First Check for Bounds
        if let deepestBoundLayer = rootLayer.hitTest(location) as? CornerBound {
            boundLayer = deepestBoundLayer
            print("found bound. returning")
            return
        }
        
        // MARK: -
        // Then for Metal Layer
        if let deepestMetalLayer = previewLayer.hitTest(location) as? CustomMetalLayer {
            LayoutState.shared.selectedSourceLayer = deepestMetalLayer
            print("found metal layer. returning")
            return
        }
        
        // MARK: -
        // Otherwise default
        else {
            LayoutState.shared.selectedSourceLayer = nil
            boundLayer = nil
            print("found nothing. defaulting")
        }
        

    }
    
    override func mouseUp(with event: NSEvent) {
        mouseDownPositionInMain = nil
        boundLayer = nil
//            print("Mouse upped")
    }
    
    override func mouseEntered(with event: NSEvent) {
//            print("Mouse entered")
        

    }
    
    override func mouseExited(with event: NSEvent) {
//            print("Mouse exited")
    
    }


    override func mouseMoved(with event: NSEvent) {
      
        
    }
    
    override func mouseDragged(with event: NSEvent) {
        guard let initialMouseDown = mouseDownPositionInMain else { return }
        let currentLocation = event.locationIn(in: self)
       
        let amountMoved = currentLocation - initialMouseDown
        
        mouseDownPositionInMain = currentLocation
        
        
//        print("the orignal mouse down locaiton is: ", amountMoved)

        // Re-size
        if boundLayer != nil {
            
            
            
        }
        
        // Re-position
        else {
            guard let selectedSource = LayoutState.shared.selectedSourceLayer else { return }
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            selectedSource.frame.origin = selectedSource.frame.origin + amountMoved
            CATransaction.commit()
            
            onSelectLayer.repositionToSelected()
        }
        
        
        
        
    }
    
    
//    override func mouseDragged(with event: NSEvent) {
//     
//        guard var initialMouseDown = initalMouseDownPosition else { return }
//        
//        let currentLocation = event.locationIn(in: self)
//        let convertedCurrentLocation = preview.convert(currentLocation, from: self.layer)
//        
//
//        
//        
//        
//        // For resizing the layer
//        if let cornerBoundName = cornerBoundName {
//              print("corner being dragged: ", cornerBoundName)
//              return // Exit the function
//        }
//        
//        
//        
//        // For moving the layer
//        guard let selectedSourceLayer = LayoutState.shared.selectedSourceLayer else { return }
//    
//        CATransaction.begin()
//        CATransaction.setDisableActions(true)
//        // 1. Set the selectedSourceLayer's origin
//        selectedSourceLayer.frame.origin = selectedSourceLayer.frame.origin + dragDifference
//        print("selected source layers frame is: ", selectedSourceLayer.frame)
//        print("selected source layers bounds are: ", selectedSourceLayer.bounds.size)
//        
//        // 2. Set the onSelectLayers origin
//        let newOrigin = preview.convert(selectedSourceLayer.frame.origin, to: self.layer)
//        onSelectlayer.frame.origin = onSelectlayer.frame.origin + dragDifference
//        CATransaction.commit()
//        
//        
//        
//        initalMouseDownPosition = convertedCurrentLocation
//    }
    
    
    
    
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
