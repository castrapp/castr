//
//  MouseListener.swift
//  castr
//
//  Created by Harrison Hall on 8/12/24.
//

import Foundation
import SwiftUI

class GlobalMouseMonitor: ObservableObject {
    
    @Published var isMouseDown = false
    @Published var isMouseDragging = false
    @Published var globalMouseLocation: NSPoint = .zero
    @Published var windowMouseLocation: NSPoint = .zero
    
    private var eventMonitor: Any?
    
    init() {
        setupEventMonitor()
    }
    
    deinit {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
    
    private func setupEventMonitor() {
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .leftMouseUp, .leftMouseDragged]) { [weak self] event in
            self?.handleMouseEvent(event)
            return event
        }
    }
    
    private func handleMouseEvent(_ event: NSEvent) {
        switch event.type {
        case .leftMouseDown:    onMouseDown(event)
        case .leftMouseUp:      onMouseUp(event)
        case .leftMouseDragged: onMouseDrag(event)
        default:
            break
        }
    }
    
    func onMouseDown(_ event: NSEvent) {
        // Set the Window Mouse Location
        windowMouseLocation = event.locationInWindow
        
        // Set the Global Mouse Location
        guard let screenPoint = event.window?.convertPoint(toScreen: event.locationInWindow) else { return }
        globalMouseLocation = screenPoint
        
        isMouseDown = true
    }
    
    func onMouseUp(_ event: NSEvent) {
        isMouseDown = false
        isMouseDragging = false
    }
    
    func onMouseDrag(_ event: NSEvent) {
        // Set the Window Mouse Location
        windowMouseLocation = event.locationInWindow
        
        // Set the Global Mouse Location
        guard let screenPoint = event.window?.convertPoint(toScreen: event.locationInWindow) else { return }
        globalMouseLocation = screenPoint
        
        isMouseDragging = true
    }
}

