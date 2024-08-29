//
//  view-Preview.swift
//  castr
//
//  Created by Harrison Hall on 8/4/24.
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
        
       
    }
}







struct Previewer: NSViewRepresentable {

    static let shared = Previewer()
    
    let contentLayer = CALayer()
    var captureVideoPreview: CaptureVideoPreview
    
    private init() {
        contentLayer.contentsGravity = .resizeAspect
//        contentLayer.masksToBounds = true
        contentLayer.frame = CGRect(x: 0, y: 0, width: 3456, height: 2234)
        captureVideoPreview = CaptureVideoPreview(layer: contentLayer)
    }
    
    func makeNSView(context: Context) -> CaptureVideoPreview {
        captureVideoPreview
    }
    
    func updateNSView(_ nsView: CaptureVideoPreview, context: Context) {}
    
    class CaptureVideoPreview: NSView {
        
        private var selectedLayer: CALayer?
        private var cornerSquares: [CALayer] = []
        private var draggingCorner: Int?
        private var isDraggingLayer = false
        private var initialDragPosition: CGPoint?
        
        init(layer: CALayer) {
            super.init(frame: .zero)
            self.layer = layer
            wantsLayer = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func mouseDown(with event: NSEvent) {
            let locationInWindow = event.locationInWindow
            let locationInView = convert(event.locationInWindow, from: nil)
            
            guard let rootLayer = self.layer else {
                print("No layer found")
                return
            }
            
            let locationInLayer = rootLayer.convert(locationInView, from: self.layer)
            
            if let clickedLayer = rootLayer.hitTest(locationInLayer) {
                if clickedLayer == rootLayer {
                    // Clicked on the superlayer (root layer)
                    selectedLayer = nil
                    removeCornerSquares()
                    print("Superlayer clicked, deselected")
                } else if !cornerSquares.contains(clickedLayer) {
                    // Clicked on a sublayer (not a corner square)
                    if selectedLayer != clickedLayer {
                        
                        removeCornerSquares()
                        selectedLayer = clickedLayer
                        print("Selected layer: \(clickedLayer)")
                        addCornerSquares(to: clickedLayer)
                    }
                    
                    draggingCorner = nil
                    isDraggingLayer = true
                    initialDragPosition = locationInLayer
                } else {
                    // Clicked on a corner square
                    draggingCorner = cornerSquares.firstIndex(where: { $0 == clickedLayer })
                    isDraggingLayer = false
                    initialDragPosition = nil
                }
            } else {
                // This case should not occur, but kept for safety
                selectedLayer = nil
                removeCornerSquares()
                print("No layer clicked")
            }
        }
        
        override func mouseDragged(with event: NSEvent) {
            guard let selectedLayer = selectedLayer,
                  let superlayer = selectedLayer.superlayer else { return }
            
            let locationInWindow = event.locationInWindow
            let locationInView = convert(locationInWindow, from: nil)
            let locationInSuperlayer = superlayer.convert(locationInView, from: self.layer)
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            
            if isDraggingLayer, let initialDragPosition = initialDragPosition {
                let dx = locationInSuperlayer.x - initialDragPosition.x
                let dy = locationInSuperlayer.y - initialDragPosition.y
                selectedLayer.position = CGPoint(x: selectedLayer.position.x + dx, y: selectedLayer.position.y + dy)
                updateCornerSquaresPosition()
                self.initialDragPosition = locationInSuperlayer
            } else if let draggingCorner = draggingCorner {
                var frame = selectedLayer.frame
                
                switch draggingCorner {
                case 0: // Bottom-left
                    let dx = locationInSuperlayer.x - frame.minX
                    let dy = locationInSuperlayer.y - frame.minY
                    frame.origin.x += dx
                    frame.origin.y += dy
                    frame.size.width -= dx
                    frame.size.height -= dy
                case 1: // Bottom-right
                    frame.size.width = max(locationInSuperlayer.x - frame.minX, 1)
                    let dy = locationInSuperlayer.y - frame.minY
                    frame.origin.y += dy
                    frame.size.height -= dy
                case 2: // Top-left
                    let dx = locationInSuperlayer.x - frame.minX
                    frame.origin.x += dx
                    frame.size.width -= dx
                    frame.size.height = max(locationInSuperlayer.y - frame.minY, 1)
                case 3: // Top-right
                    frame.size.width = max(locationInSuperlayer.x - frame.minX, 1)
                    frame.size.height = max(locationInSuperlayer.y - frame.minY, 1)
                default:
                    break
                }
                
                // Ensure minimum size
                frame.size.width = max(frame.size.width, 1)
                frame.size.height = max(frame.size.height, 1)
                
                selectedLayer.frame = frame
                updateCornerSquaresPosition()
            }
            
            CATransaction.commit()
        }
        
        override func mouseUp(with event: NSEvent) {
            draggingCorner = nil
            isDraggingLayer = false
            initialDragPosition = nil
        }
        
        private func addCornerSquares(to layer: CALayer) {
            guard let superlayer = layer.superlayer else {
                print("No superlayer found")
                return
            }
            
            let frame = layer.frame
            let cornerSize: CGFloat = 20
            
            let corners = [
                CGPoint(x: frame.minX, y: frame.minY), // Bottom-left
                CGPoint(x: frame.maxX, y: frame.minY), // Bottom-right
                CGPoint(x: frame.minX, y: frame.maxY), // Top-left
                CGPoint(x: frame.maxX, y: frame.maxY)  // Top-right
            ]
            
            for corner in corners {
                let square = CALayer()
                square.backgroundColor = NSColor.red.cgColor
                square.frame = CGRect(x: corner.x - cornerSize/2, y: corner.y - cornerSize/2, width: cornerSize, height: cornerSize)
                superlayer.addSublayer(square)
                cornerSquares.append(square)
            }
        }
        
        private func removeCornerSquares() {
            for square in cornerSquares {
                square.removeFromSuperlayer()
            }
            cornerSquares.removeAll()
        }
        
        private func updateCornerSquaresPosition() {
            guard let selectedLayer = selectedLayer else { return }
            let frame = selectedLayer.frame
            let cornerSize: CGFloat = 20
            
            let corners = [
                CGPoint(x: frame.minX, y: frame.minY), // Bottom-left
                CGPoint(x: frame.maxX, y: frame.minY), // Bottom-right
                CGPoint(x: frame.minX, y: frame.maxY), // Top-left
                CGPoint(x: frame.maxX, y: frame.maxY)  // Top-right
            ]
            
            for (index, square) in cornerSquares.enumerated() {
                let corner = corners[index]
                square.frame = CGRect(x: corner.x - cornerSize/2, y: corner.y - cornerSize/2, width: cornerSize, height: cornerSize)
            }
        }
    }
}
