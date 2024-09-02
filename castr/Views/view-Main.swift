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
    
    var selectedSourceLayer: CAMetalLayer? {
        didSet { Main.shared.onSelectlayer.isHidden = (selectedSourceLayer == nil)
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
    var initialMouseDownPositionInMain: NSPoint?
    var boundLayer: CornerBound?
    var shiftChangeMonitor: Any?
    var isShiftTrue: Bool = false { didSet { handleShiftChange() } }
    var initialAspectRatio: CGFloat?
   
    
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
    
    func handleShiftChange() {
        // During shift change we need to essentailly set the CGSize of the source.bounds
        guard
            let selectedSource = LayoutState.shared.selectedSourceLayer,
            let mouseDownPositionInMain = mouseDownPositionInMain,
            let initialAspectRatio = initialAspectRatio
        else { return }
        
        let dynamicSize = getDynamicSize(layer: selectedSource, previewLayer: previewLayer, coordinate: mouseDownPositionInMain)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        // Use aspect-ratio preserved size
        if isShiftTrue {
            selectedSource.bounds.size = calculateAspectRatioPreservedSize(aspectRatio: initialAspectRatio, for: dynamicSize)
            print("Handing shift change. Apply aspect-ratio preserved size.")
        }
        
        // Use dynamic size
        else {
            selectedSource.bounds.size = dynamicSize
            print("Handing shift change. Apply dynamic size.")
        }
        
        onSelectLayer.resizeToSelected()
        
        CATransaction.commit()
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        for trackingArea in trackingAreas { removeTrackingArea(trackingArea) }
        addTrackingArea(NSTrackingArea(rect: self.bounds, options: [.mouseMoved, .activeInKeyWindow, .inVisibleRect, .mouseEnteredAndExited], owner: self, userInfo: nil))
    }
    
    
    override func mouseDown(with event: NSEvent) {
        mouseDownPositionInMain = event.locationIn(in: self)
        initialMouseDownPositionInMain =  event.locationIn(in: self)
        
        guard
            let location = mouseDownPositionInMain
        else { return }
        
        print("mouse down")
        
        if let selectedSource = LayoutState.shared.selectedSourceLayer {
            initialAspectRatio = selectedSource.bounds.size.width / selectedSource.bounds.size.height
        }
        
        
        // MARK: - Bounds
        // First Check for Bounds
        if let deepestBoundLayer = rootLayer.hitTest(location) as? CornerBound {
            boundLayer = deepestBoundLayer
            print("bound type: \(boundLayer?.cornerType.name) is hit")
            
         
            
            if shiftChangeMonitor == nil {
                
//                isShiftTrue = NSEvent.modifierFlags.contains(.shift)
                
                shiftChangeMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
                    guard let self = self else { return event }
                    self.isShiftTrue = event.modifierFlags.contains(.shift)
                    return event
                }
            }
           
            
            print("found bound. returning")
            return
        }
        
        // MARK: - Metal Layer
        // Then for Metal Layer
        if let deepestMetalLayer = previewLayer.hitTest(location) as? CustomMetalLayer {
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
        
        // MARK: - Default
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
        isShiftTrue = false
        if var shiftChangeMonitor = shiftChangeMonitor {
            NSEvent.removeMonitor(shiftChangeMonitor)
            self.shiftChangeMonitor = nil
            print("shift change monitor removed")
        }
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
        guard let initialAspectRatio = initialAspectRatio else { return }
        let currentLocation = event.locationIn(in: self)
        let amountMoved = currentLocation - initialMouseDown
        mouseDownPositionInMain = currentLocation
        
        
        // MARK: - Re-size
        // For when the user re-sizes a layer
        if let boundLayer = boundLayer {
            guard let selectedSource = LayoutState.shared.selectedSourceLayer else { return }
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            
            /// `1. Determine and set the Anchor point (if it hasnt been set already)`
            setAnchorPoint(boundLayer: boundLayer, selectedSource: selectedSource)
            
            
            /// `2. Determine and set transforms`
            /*
             (if this idea fails then I must be gtting the anchor point wrong)
             This portion of code sets the transform based on the current frame the drag is creating.
             This is depenedent upon the the current anchor point, the current bound that is being dragged,
             and the drag coordinate.
             
             The variables to use are currentLocation and anchorInSuperlayer
             
             if the bound type is top left:
                if the anchor point is positioned lower and to the right, relative to the drag coordinate,
                then no transform is applied
             
                if the anchor point is positioned higher and to the right, relative to the drag coordinate,
                then a vertical flip transform is applied
             
                if the anchor point is positioned higher and to the left, relative to the drag coordinate,
                then both a vertical flip and horizontal flip transform is applied
             
                if the anchor point is positioned lower and to the left, relative to the drag coordinate,
                then a horizontal flip is applied
             
             if the bound type is the bottom left:
                if the anchor point is positioned lower and to the left, relative to the drag coordinate,
                then no transform is applied
             
                if the anchor point is positioned higher and to the left, relative to the drag coordinate,
                then a vertical flip transform is applied
             
                if the anchor point is positioned higher and to the right, relative to the drag coordinate,
                then both a vertical flip and horizontal flip transform is applied
             
                if the anchor point is positioned lower and to the right, relative to the drag coordinate,
                then a horizontal flip is applied
              
            */
            let transform = selectedSource.affineTransform()
            var transformX: Double = transform.a
            var transformY: Double = transform.d
            
            let anchorInSuperLayer = selectedSource.position + previewLayer.frame.origin
            
            if boundLayer.cornerType == .topLeft {
                // Refactor: Anchor point comes first, then compare with the drag coordinate
                // Determine the position of the anchor point relative to the drag coordinate
                if anchorInSuperLayer.x > currentLocation.x && anchorInSuperLayer.y < currentLocation.y {
                    // Anchor point is lower and to the right (no flip needed)
                    transformX = 1.0
                    transformY = 1.0
                } else if anchorInSuperLayer.x > currentLocation.x && anchorInSuperLayer.y > currentLocation.y {
                    // Anchor point is higher and to the right (vertical flip needed)
                    transformX = 1.0
                    transformY = -1.0
                } else if anchorInSuperLayer.x < currentLocation.x && anchorInSuperLayer.y < currentLocation.y {
                    // Anchor point is lower and to the left (horizontal flip needed)
                    transformX = -1.0
                    transformY = 1.0
                } else if anchorInSuperLayer.x < currentLocation.x && anchorInSuperLayer.y > currentLocation.y {
                    // Anchor point is higher and to the left (both horizontal and vertical flips needed)
                    transformX = -1.0
                    transformY = -1.0
                }
            } 
            
            else if boundLayer.cornerType == .bottomLeft {
                // Refactor: Anchor point comes first, then compare with the drag coordinate
                // Determine the position of the anchor point relative to the drag coordinate
                if anchorInSuperLayer.x > currentLocation.x && anchorInSuperLayer.y > currentLocation.y {
                    // Anchor point is higher and to the left (no flip needed)
                    transformX = 1.0
                    transformY = 1.0
                } else if anchorInSuperLayer.x > currentLocation.x && anchorInSuperLayer.y < currentLocation.y {
                    // Anchor point is lower and to the left (vertical flip needed)
                    transformX = 1.0
                    transformY = -1.0
                } else if anchorInSuperLayer.x < currentLocation.x && anchorInSuperLayer.y > currentLocation.y {
                    // Anchor point is higher and to the right (horizontal flip needed)
                    transformX = -1.0
                    transformY = 1.0
                } else if anchorInSuperLayer.x < currentLocation.x && anchorInSuperLayer.y < currentLocation.y {
                    // Anchor point is lower and to the right (both horizontal and vertical flips needed)
                    transformX = -1.0
                    transformY = -1.0
                }
            }
            
            else if boundLayer.cornerType == .topRight {
                // Determine the position of the anchor point relative to the drag coordinate
                if anchorInSuperLayer.x < currentLocation.x && anchorInSuperLayer.y < currentLocation.y {
                    // Anchor point is lower and to the left (no flip needed)
                    transformX = 1.0
                    transformY = 1.0
                } else if anchorInSuperLayer.x < currentLocation.x && anchorInSuperLayer.y > currentLocation.y {
                    // Anchor point is higher and to the left (vertical flip needed)
                    transformX = 1.0
                    transformY = -1.0
                } else if anchorInSuperLayer.x > currentLocation.x && anchorInSuperLayer.y < currentLocation.y {
                    // Anchor point is lower and to the right (horizontal flip needed)
                    transformX = -1.0
                    transformY = 1.0
                } else if anchorInSuperLayer.x > currentLocation.x && anchorInSuperLayer.y > currentLocation.y {
                    // Anchor point is higher and to the right (both horizontal and vertical flips needed)
                    transformX = -1.0
                    transformY = -1.0
                }
            }
            
            else if boundLayer.cornerType == .bottomRight {
                // Determine the position of the anchor point relative to the drag coordinate
                if anchorInSuperLayer.x < currentLocation.x && anchorInSuperLayer.y > currentLocation.y {
                    // Anchor point is higher and to the left (no flip needed)
                    transformX = 1.0
                    transformY = 1.0
                } else if anchorInSuperLayer.x < currentLocation.x && anchorInSuperLayer.y < currentLocation.y {
                    // Anchor point is lower and to the left (vertical flip needed)
                    transformX = 1.0
                    transformY = -1.0
                } else if anchorInSuperLayer.x > currentLocation.x && anchorInSuperLayer.y > currentLocation.y {
                    // Anchor point is higher and to the right (horizontal flip needed)
                    transformX = -1.0
                    transformY = 1.0
                } else if anchorInSuperLayer.x > currentLocation.x && anchorInSuperLayer.y < currentLocation.y {
                    // Anchor point is lower and to the right (both horizontal and vertical flips needed)
                    transformX = -1.0
                    transformY = -1.0
                }
            }

            selectedSource.setAffineTransform(CGAffineTransform(scaleX: transformX, y: transformY))
            onSelectLayer.setAffineTransform(CGAffineTransform(scaleX: transformX, y: transformY))
            
            
            
            /// `3. Determine and set the new layer size`
            
            let dynamicSize = getDynamicSize(layer: selectedSource, previewLayer: previewLayer, coordinate: currentLocation)
            
            
            if isShiftTrue { // Use aspect-ratio preserved size
                selectedSource.bounds.size = calculateAspectRatioPreservedSize(aspectRatio: initialAspectRatio, for: dynamicSize)
            }
            else {  // Use dynamic size
                selectedSource.bounds.size = dynamicSize
            }
                

            
            
            onSelectLayer.resizeToSelected()
            
            CATransaction.commit()
            
        }
        
        
        
        
        // MARK: - Re-position
        // For when the user repositions a layer
        else {
            guard let selectedSource = LayoutState.shared.selectedSourceLayer else { return }
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            
            selectedSource.position = selectedSource.position + amountMoved
            
            onSelectLayer.repositionToSelected()
            CATransaction.commit()
            
            print("repositioning layer")
        }
        
        
        
       
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


func setAnchorPoint(boundLayer: CornerBound, selectedSource: CAMetalLayer) {
    
    // Top left
    if boundLayer.cornerType == .topLeft {
        
        // NOTE: All this does is set the anchor point once (if its not already set)
        if selectedSource.anchorPoint != CGPoint(x: 1.0, y: 0.0) {
            adjustAnchorPointAndPosition(of: selectedSource, to: CGPoint(x: 1.0, y: 0.0))
            print("setting anchor point for top left")
        }
    }
    
    
    // Top Right
    else if boundLayer.cornerType == .topRight {
        
        // NOTE: All this does is set the anchor point once (if its not already set)
        if selectedSource.anchorPoint != CGPoint(x: 0.0, y: 0.0) {
            adjustAnchorPointAndPosition(of: selectedSource, to: CGPoint(x: 0.0, y: 0.0))
            print("setting anchor point for top right")
        }
    }
    
    
    // Bottom Left
    else if boundLayer.cornerType == .bottomLeft {
        
        // NOTE: All this does is set the anchor point once (if its not already set)
        if selectedSource.anchorPoint != CGPoint(x: 1.0, y: 1.0) {
            adjustAnchorPointAndPosition(of: selectedSource, to: CGPoint(x: 1.0, y: 1.0))
            print("setting anchor point for bottom left")
        }
    }
    
 
    // Bottom Right
    else if boundLayer.cornerType == .bottomRight {
        
        // NOTE: All this does is set the anchor point once (if its not already set)
        if selectedSource.anchorPoint != CGPoint(x: 0.0, y: 1.0) {
            adjustAnchorPointAndPosition(of: selectedSource, to: CGPoint(x: 0.0, y: 1.0))
            print("setting anchor point for bottom right")
        }
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


func calculateAspectRatioPreservedSize(aspectRatio: CGFloat, for dynamicSize: CGSize) -> CGSize {
    let widthRatio = dynamicSize.width / aspectRatio
    let heightRatio = dynamicSize.height * aspectRatio
    
    if dynamicSize.width / aspectRatio <= dynamicSize.height {
        // Width is the limiting factor, so adjust height based on width
        return CGSize(width: dynamicSize.width, height: dynamicSize.width / aspectRatio)
    } else {
        // Height is the limiting factor, so adjust width based on height
        return CGSize(width: dynamicSize.height * aspectRatio, height: dynamicSize.height)
    }
}


// FIXME: This works when no transforms are applied, all we gotta do is make this work when transforms are applied
//func calculateAspectRatioPreservedSize(layer: CALayer, dragCoordinate: CGPoint)

func getDynamicSize(layer: CALayer, previewLayer: CALayer, coordinate: CGPoint) -> CGSize {
    let anchorPointCoordinate = previewLayer.frame.origin + layer.position
    
    let dynamicWidth = abs(coordinate.x - anchorPointCoordinate.x)
    let dynamicHeight = abs(coordinate.y - anchorPointCoordinate.y)
    
    return CGSize(width: dynamicWidth, height: dynamicHeight)
}


func calculateAspectRatioPreservedSize(for layer: CALayer, previewLayer: CALayer, with dragCoordinate: CGPoint) -> CGSize {
    
    // Get the layer's current aspect ratio
    let aspectRatio = layer.bounds.size.width / layer.bounds.size.height
    
    // Calculate the origin of the layer in the superlayer's coordinate system
    let anchorPointCoordinate = previewLayer.frame.origin + layer.position
    
    // Calculate the dynamic frame size based on the drag coordinate and the anchor point coordinate
    let dynamicWidth = abs(dragCoordinate.x - anchorPointCoordinate.x)
    let dynamicHeight = abs(dragCoordinate.y - anchorPointCoordinate.y)
    
    // Determine the largest aspect ratio-preserved size that fits within the dynamic frame
    let adjustedWidth: CGFloat
    let adjustedHeight: CGFloat
    
    if dynamicWidth / aspectRatio <= dynamicHeight {
        // Width is the limiting factor, so adjust height based on width
        adjustedWidth = dynamicWidth
        adjustedHeight = dynamicWidth / aspectRatio
    } else {
        // Height is the limiting factor, so adjust width based on height
        adjustedWidth = dynamicHeight * aspectRatio
        adjustedHeight = dynamicHeight
    }
    
    return CGSize(width: adjustedWidth, height: adjustedHeight)
}
