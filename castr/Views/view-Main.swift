//
//  Main.swift
//  castr
//
//  Created by Harrison Hall on 8/29/24.
//

import Foundation
import SwiftUI
import AppKit


import Cocoa

// Function to create an arrow CALayer
func createArrowLayer() -> CALayer {
    // Create a CAShapeLayer
    let arrowLayer = CAShapeLayer()
    
    // Define the path for the arrow
    let arrowPath = NSBezierPath()
    arrowPath.move(to: CGPoint(x: 10, y: 30))   // Start at the bottom of the arrow
    arrowPath.line(to: CGPoint(x: 30, y: 30))   // Bottom right
    arrowPath.line(to: CGPoint(x: 30, y: 20))   // Right side of the stem
    arrowPath.line(to: CGPoint(x: 40, y: 20))   // Right corner of the arrowhead
    arrowPath.line(to: CGPoint(x: 20, y: 0))    // Tip of the arrowhead (upward)
    arrowPath.line(to: CGPoint(x: 0, y: 20))    // Left corner of the arrowhead
    arrowPath.line(to: CGPoint(x: 10, y: 20))   // Left side of the stem
    arrowPath.close()                           // Back to the start point
    
    // Convert NSBezierPath to CGPath
    let path = arrowPath.cgPath
    
    // Set the path to the shape layer
    arrowLayer.path = path
    
    // Set the fill color
    arrowLayer.fillColor = NSColor.black.cgColor
    
    // Set the stroke color (optional, if you want an outline)
    arrowLayer.strokeColor = NSColor.black.cgColor
    arrowLayer.lineWidth = 2.0
    
    // Set the bounds and position of the layer
    arrowLayer.bounds = CGRect(x: 0, y: 0, width: 40, height: 30)
    arrowLayer.position = CGPoint(x: 50, y: 50) // Adjust as needed
    
    return arrowLayer
}







class LayoutState {
    static let shared = LayoutState()
    
    var currentOrigin: CGPoint?
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
        
//        onSelectlayer.actions = ["hidden": NSNull()]
        
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
            print("bound type: \(boundLayer?.cornerType.name) is hit")
            print("found bound. returning")
            return
        }
        
        // MARK: -
        // Then for Metal Layer
        if let deepestMetalLayer = previewLayer.hitTest(location) as? CustomMetalLayer {
            // TODO: I think we may need to set the transform for the onSelectedLayer to the
            // TODO: to the same whatever transform this layer has
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            LayoutState.shared.selectedSourceLayer = deepestMetalLayer
            onSelectLayer.transform = deepestMetalLayer.transform
            if let name = deepestMetalLayer.name {
                GlobalState.shared.selectedSourceId = name
            }
            
            CATransaction.commit()
            print("found metal layer. returning")
            return
        }
        
        // MARK: -
        // Otherwise default
        else {
            LayoutState.shared.selectedSourceLayer = nil
            boundLayer = nil
            
            if let selectedSource = LayoutState.shared.selectedSourceLayer {
                LayoutState.shared.currentOrigin = selectedSource.frame.origin
            }
            
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
        
        
        // MARK: -
        // Re-size
        if let boundLayer = boundLayer {
            guard let selectedSource = LayoutState.shared.selectedSourceLayer else { return }
            
            
            let transform = selectedSource.affineTransform()
            var newWidth: CGFloat?
            var newHeight: CGFloat?
            
            
            // MARK: -
            // Top left
            if boundLayer.cornerType == .topLeft {
                
                if selectedSource.anchorPoint != CGPoint(x: 1.0, y: 0.0) {
                    adjustAnchorPointAndPosition(of: selectedSource, to: CGPoint(x: 1.0, y: 0.0))
                    print("setting anchor point for top left")
                }
   
                newWidth = selectedSource.bounds.size.width - (amountMoved.x * transform.a) /* I think we need to times this amount movedx by the current scale x*/
                newHeight = selectedSource.bounds.size.height + (amountMoved.y * transform.d)
            }
            
            // MARK: -
            // Top Right
            else if boundLayer.cornerType == .topRight {
                
                if selectedSource.anchorPoint != CGPoint(x: 0.0, y: 0.0) {
                    adjustAnchorPointAndPosition(of: selectedSource, to: CGPoint(x: 0.0, y: 0.0))
                    print("setting anchor point for top right")
                }
                
                /*
                 So right here I also need to do a check like how I do in the topleft part
                 where i check if the anchorpoint is 0,0 or not, and if its not then I need to set it.
                 When I do this the same way as above in the top left, where I first save the current origin
                 then apply the new anchor point, then set the origin to that saved origin / restore the original origin
                 it works fine, that is, when there are no transforms applied to the layer, but see there is a problem
                 that occurs when transforms are appled to the layer, like if the layer is flipped vertically for example
                 when the layer is flipped vertically, it sets the origins x right but as for the y, it will set it either
                 one whole layers hieght above the orignal origins y or below it, it seems like it depends on what the pervious
                 anchor point was
                 */
                
                newWidth = selectedSource.bounds.size.width + (amountMoved.x * transform.a) /* I think we need to times this amount movedx by the current scale x*/
                newHeight = selectedSource.bounds.size.height + (amountMoved.y * transform.d)
            }
            
            
            // MARK: -
            // Bottom Left
            else if boundLayer.cornerType == .bottomLeft {
                
                if selectedSource.anchorPoint != CGPoint(x: 1.0, y: 1.0) {
                    adjustAnchorPointAndPosition(of: selectedSource, to: CGPoint(x: 1.0, y: 1.0))
                    print("setting anchor point for bottom left")
                }
                
                newWidth = selectedSource.bounds.size.width - (amountMoved.x * transform.a) /* I think we need to times this amount movedx by the current scale x*/
                newHeight = selectedSource.bounds.size.height - (amountMoved.y * transform.d)
            }
            
            // MARK: -
            // Bottom Right
            else if boundLayer.cornerType == .bottomRight {
                
                if selectedSource.anchorPoint != CGPoint(x: 0.0, y: 1.0) {
                    adjustAnchorPointAndPosition(of: selectedSource, to: CGPoint(x: 0.0, y: 1.0))
                    print("setting anchor point for bottom right")
                }
                
                newWidth = selectedSource.bounds.size.width + (amountMoved.x * transform.a) /* I think we need to times this amount movedx by the current scale x*/
                newHeight = selectedSource.bounds.size.height - (amountMoved.y * transform.d)
            }
            
            
            
            
            guard let newWidth = newWidth, let newHeight = newHeight else { return }
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            
            selectedSource.bounds.size.width = newWidth
            selectedSource.bounds.size.height = newHeight
            
            var transformX: Double = transform.a
            var transformY: Double = transform.d
            
            // Width
            if newWidth < 0 {
                if transform.a > 0 { transformX = -1.0 }
                if transform.a < 0 { transformX = 1.0 }
            }
                
            
            // Height
            if newHeight < 0 {
                if transform.d > 0 { transformY = -1.0 }
                if transform.d < 0 { transformY = 1.0 }
            }
            
            
            selectedSource.setAffineTransform(CGAffineTransform(scaleX: transformX, y: transformY))
            onSelectLayer.setAffineTransform(CGAffineTransform(scaleX: transformX, y: transformY))
            
            
            onSelectLayer.resizeToSelected()
            
            CATransaction.commit()
            
        }
        
        
        // MARK: -
        // Re-position
        else {
            guard let selectedSource = LayoutState.shared.selectedSourceLayer else { return }
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            
            selectedSource.position = selectedSource.position + amountMoved
//            print("new position is: ", selectedSource.position)
            
            onSelectLayer.repositionToSelected()
            CATransaction.commit()
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


func adjustAnchorPointAndPosition(of layer: CALayer, to newAnchorPoint: CGPoint) {
    guard let superlayer = layer.superlayer else { return }
    
    CATransaction.begin()
    CATransaction.setDisableActions(true)

    // Calculate the old anchor point in the superlayer's coordinate space
    let oldAnchorPoint = layer.anchorPoint
    let oldPosition = layer.position
    
    // Get the size of the layer
    let layerSize = layer.bounds.size
    
    // Calculate the old position based on the old anchor point
    let oldAnchorPointInSuperlayer = CGPoint(x: oldAnchorPoint.x * layerSize.width,
                                             y: oldAnchorPoint.y * layerSize.height)
    
    // Calculate the new anchor point in the superlayer's coordinate space
    let newAnchorPointInSuperlayer = CGPoint(x: newAnchorPoint.x * layerSize.width,
                                             y: newAnchorPoint.y * layerSize.height)
    
    // Calculate the offset caused by the anchor point change
    let anchorPointOffset = newAnchorPointInSuperlayer - oldAnchorPointInSuperlayer
    
    // Apply the transform to the offset to take into account the current layer's transformation
    let transformedOffset = anchorPointOffset.applying(layer.affineTransform())
    
    // Update the anchor point
    layer.anchorPoint = newAnchorPoint
    
    // Adjust the position by subtracting the transformed offset
    layer.position = oldPosition + transformedOffset
    
    CATransaction.commit()
}
