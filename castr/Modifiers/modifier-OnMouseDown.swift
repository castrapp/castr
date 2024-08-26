//
//  modifier-OnMouseDown.swift
//  castr
//
//  Created by Harrison Hall on 8/23/24.
//

import Foundation
import SwiftUI
import AppKit

struct OnMouseDownModifier: ViewModifier {
    
    let onMouseDown: () -> Void
    
    func body(content: Content) -> some View {
        content
        .overlay(MouseDownRepresentable(onMouseDown: onMouseDown))
    }
}

extension View {
    func onMouseDown(perform action: @escaping () -> Void) -> some View {
        self.modifier(OnMouseDownModifier(onMouseDown: action))
    }
}

struct MouseDownRepresentable: NSViewRepresentable {
    var onMouseDown: () -> Void
    
    class MouseDownView: NSView {
        var onMouseDown: () -> Void
        
        init(onMouseDown: @escaping () -> Void) {
            self.onMouseDown = onMouseDown
            super.init(frame: .zero)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func mouseDown(with event: NSEvent) {
            onMouseDown()
            super.mouseDown(with: event) // Optionally call the super method if you want default behavior as well
        }
    }
    
    func makeNSView(context: Context) -> NSView {
        return MouseDownView(onMouseDown: onMouseDown)
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}

