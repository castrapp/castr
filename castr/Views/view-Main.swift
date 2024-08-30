//
//  Main.swift
//  castr
//
//  Created by Harrison Hall on 8/29/24.
//

import Foundation
import SwiftUI

class LayoutHelper {
    static let shared = LayoutHelper()
    
    var mouseDownMonitor: Any?
}


class CustomPreviewLayer: CALayer {
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
        
    }
}


enum CornerType {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
    
    var name: String {
        switch self {
        case .topLeft: return "topLeft"
        case .topRight: return "topRight"
        case .bottomLeft: return "bottomLeft"
        case .bottomRight: return "bottomRight"
        }
    }
}


class CornerBounds: CALayer {
    
    let cornerType: CornerType
    
    init(cornerType: CornerType) {
        self.cornerType = cornerType
        super.init()
        self.name = cornerType.name
        self.frame.size = CGSize(width: 10, height: 10)
        self.borderWidth = 1
        self.backgroundColor = CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func resize(withOldSuperlayerSize oldSize: CGSize) {
        guard let superlayer = superlayer else { return }
        
        switch cornerType {
        case .topLeft:
            self.frame.origin = CGPoint(
                x: superlayer.frame.minX - (self.frame.width / 2),
                y: superlayer.frame.maxY - (self.frame.height / 2)
            )
        case .topRight:
            self.frame.origin = CGPoint(
                x: superlayer.frame.maxX - (self.frame.width / 2),
                y: superlayer.frame.maxY - (self.frame.height / 2)
            )
        case .bottomLeft:
            self.frame.origin = CGPoint(
                x: superlayer.frame.minX - (self.frame.width / 2),
                y: superlayer.frame.minY - (self.frame.height / 2)
            )
        case .bottomRight:
            self.frame.origin = CGPoint(
                x: superlayer.frame.maxX - (self.frame.width / 2),
                y: superlayer.frame.minY - (self.frame.height / 2)
            )
        }
    }
}


class CustomLayoutAdjusterLayer: CALayer {
    
    let highlightLayer: HighlightLayer = HighlightLayer()
    let topLeft: CornerBounds
    let topRight: CornerBounds
    let bottomLeft: CornerBounds
    let bottomRight: CornerBounds
    
    override init() {
        self.topLeft = CornerBounds(cornerType: .topLeft)
        self.topRight = CornerBounds(cornerType: .topRight)
        self.bottomLeft = CornerBounds(cornerType: .bottomLeft)
        self.bottomRight = CornerBounds(cornerType: .bottomRight)
        
        super.init()
        
        self.addSublayer(highlightLayer)
        self.addSublayer(topLeft)
        self.addSublayer(topRight)
        self.addSublayer(bottomLeft)
        self.addSublayer(bottomRight)
        
        topLeft.resize(withOldSuperlayerSize: CGSize(width: 10, height: 10))
        topRight.resize(withOldSuperlayerSize: CGSize(width: 10, height: 10))
        bottomLeft.resize(withOldSuperlayerSize: CGSize(width: 10, height: 10))
        bottomRight.resize(withOldSuperlayerSize: CGSize(width: 10, height: 10))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func highlight() {
//        print("attempting to highlight highlightLayer")
        highlightLayer.highlight()
    }
    
    func unhighlight() {
        highlightLayer.unhighlight()
    }
    
    func select() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        topLeft.isHidden = false
        topRight.isHidden = false
        bottomLeft.isHidden = false
        bottomRight.isHidden = false
        
        CATransaction.commit()
    }
    
    func unselect() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        topLeft.isHidden = true
        topRight.isHidden = true
        bottomLeft.isHidden = true
        bottomRight.isHidden = true
        
        CATransaction.commit()
    }
}





class HighlightLayer: CALayer {
    
    func highlight()  {
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        self.isHidden = false
        self.borderColor = CGColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
        self.borderWidth = 1
        
        CATransaction.commit()
    }
    
    func unhighlight(override: Bool = false)  {
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        self.isHidden = true
        self.borderColor = CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        self.borderWidth = 0
        
        CATransaction.commit()
    }
    
    override func resize(withOldSuperlayerSize oldSize: CGSize) {
        guard let superlayer = superlayer else { return }
        self.frame.size = superlayer.frame.size
        print("resizing")
    }
    
}










struct Main: NSViewRepresentable {
    
    static let shared = Main()
    
    let main = CALayer()
    let preview = CustomPreviewLayer()
    let layoutAdjuster = CustomLayoutAdjusterLayer()
    
    
    private init() {
        main.borderColor = CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        main.borderWidth = 1.0
        main.addSublayer(preview)
        main.addSublayer(layoutAdjuster)
        
//        layoutAdjuster.borderColor = CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
//        layoutAdjuster.borderWidth = 1.0
//        layoutAdjuster.frame = CGRect(x: 0, y: 0, width: 250, height: 250)
        
        preview.borderColor = CGColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0)
        preview.borderWidth = 1.0
        preview.frame = CGRect(x: 0, y: 0, width: 3456, height: 2234)
//        preview.backgroundColor = CGColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0)
//        preview.contentsGravity = .resizeAspect

        
    }
    
    func makeNSView(context: Context) -> LayoutPreview {
        LayoutPreview(
            mainLayer: main,
            preview: preview,
            layoutAdjuster: layoutAdjuster
        )
    }
    
    func updateNSView(_ nsView: LayoutPreview, context: Context) {}
    
    class LayoutPreview: NSView {
        
        let preview: CustomPreviewLayer
        let layoutAdjuster: CustomLayoutAdjusterLayer
        var mouseDownMonitor: Any?
        var isLayerSelected: Bool = false {
            didSet {
                isLayerSelected ? layoutAdjuster.select() : layoutAdjuster.unselect()
//                print("is a layer selected: ", isLayerSelected)
            }
        }
        
        init(mainLayer: CALayer, preview: CustomPreviewLayer, layoutAdjuster: CustomLayoutAdjusterLayer) {
            self.preview = preview
            self.layoutAdjuster = layoutAdjuster
            super.init(frame: .zero)
            self.layer = mainLayer
            wantsLayer = true
            
            self.addTrackingArea(NSTrackingArea(rect: self.bounds, options: [.mouseMoved, .activeInKeyWindow, .inVisibleRect], owner: self, userInfo: nil))
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        
        override func mouseDown(with event: NSEvent) {
//            print("Mouse downed")
            
            let mouseInViewCoordinates = convert(event.locationInWindow, from: nil)
            if let deepestLayer = preview.hitTest(mouseInViewCoordinates) as? CustomMetalLayer {
//                print("selected layer is: ")
                
                // set selectedSourceLayer to a layer
                GlobalState.shared.selectedSourceLayer = deepestLayer
                isLayerSelected = true
            }
            // Check if a CornerBounds is hit within layoutAdjuster
            else if let hitLayer = layoutAdjuster.hitTest(mouseInViewCoordinates) as? CornerBounds {
                print("CornerBounds hit: \(hitLayer.name ?? "Unknown")")
                // Handle selection of a CornerBounds layer here if needed
                // For example, you might want to set it as selected or perform some other action
            }
            else  {
                // set selectedSourceLayer to nil
                GlobalState.shared.selectedSourceLayer = nil
                isLayerSelected = false
                layoutAdjuster.unhighlight()
            }
        }
        
        override func mouseDragged(with event: NSEvent) {
//            print("Mouse dragged")
        }
        
        override func mouseUp(with event: NSEvent) {
//            print("Mouse upped")
        }
        
        override func mouseEntered(with event: NSEvent) {
//            print("Mouse entered")
            
            // If mouse enters and there is a monitor then remove it
            if let monitor = mouseDownMonitor {
                NSEvent.removeMonitor(monitor)
            }
        }
        
        override func mouseExited(with event: NSEvent) {
//            print("Mouse exited")
            if GlobalState.shared.selectedSourceLayer == nil {
                layoutAdjuster.unhighlight()
            }
            
            // If mouse exits, we set a lisetner to listen for if a mouse down event occurs
            if LayoutHelper.shared.mouseDownMonitor != nil { return }
            
            LayoutHelper.shared.mouseDownMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .otherMouseDown, .rightMouseDown]) { [weak self] event in
               guard let self = self else { return event }
               
                // Reset selectedSourceLayer
                GlobalState.shared.selectedSourceLayer = nil
                isLayerSelected = false
                self.layoutAdjuster.unhighlight()
//               print("Mouse down detected after exit, resetting selectedSourceLayer.")
               
               // Remove the monitor
               if let monitor = LayoutHelper.shared.mouseDownMonitor {
                   NSEvent.removeMonitor( LayoutHelper.shared.mouseDownMonitor)
                   LayoutHelper.shared.mouseDownMonitor = nil
               }
               
               return event
           }
        }
        
        override func mouseMoved(with event: NSEvent) {
            let mouseInViewCoordinates = convert(event.locationInWindow, from: nil)
            
            if let deepestLayer = preview.hitTest(mouseInViewCoordinates) as? CustomMetalLayer {
//                print("deepest layer found: ", deepestLayer)
                let originInMainLayer = preview.convert(deepestLayer.frame.origin, to: self.layer)
                
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                
                layoutAdjuster.frame.size = deepestLayer.frame.size
                layoutAdjuster.frame.origin = originInMainLayer
                
                CATransaction.commit()
                
//                print("new origin is: ", originInMainLayer)
                
//                print("attempting to highlight layoutAdjuster")
                layoutAdjuster.highlight()
            } else {
                if GlobalState.shared.selectedSourceLayer == nil {
                    layoutAdjuster.unhighlight()
                }
            }
            
           
            //            print("Mouse over", convert(event.locationInWindow, from: nil))
        }
        
        override func updateTrackingAreas() {
            super.updateTrackingAreas()
            for trackingArea in trackingAreas {
                removeTrackingArea(trackingArea)
            }
            addTrackingArea(NSTrackingArea(rect: self.bounds, options: [.mouseMoved, .activeInKeyWindow, .inVisibleRect, .mouseEnteredAndExited], owner: self, userInfo: nil))
        }
        
    }

}



