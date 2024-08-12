//
//  view-MouseEvent.swift
//  castr
//
//  Created by Harrison Hall on 8/12/24.
//

import Foundation
import SwiftUI

struct MouseEventView<Content: View>: NSViewRepresentable {
    var onMouseDown: ((NSPoint) -> Void)?
    var onMouseUp: (() -> Void)?
    var onDrag: ((NSPoint) -> Void)?
    var content: Content

    init(
        onMouseDown: ((NSPoint) -> Void)? = nil,
        onMouseUp: (() -> Void)? = nil,
        onDrag: ((NSPoint) -> Void)? = nil,
        @ViewBuilder content: () -> Content = { EmptyView() }
    ) {
        self.onMouseDown = onMouseDown
        self.onMouseUp = onMouseUp
        self.onDrag = onDrag
        self.content = content()
    }

    func makeNSView(context: Context) -> MouseDetectingView {
        let hostingView = NSHostingView(rootView: content)
        let view = MouseDetectingView(hostingView: hostingView)
        view.onMouseDown = onMouseDown
        view.onMouseUp = onMouseUp
        view.onDrag = onDrag
        return view
    }

    func updateNSView(_ nsView: MouseDetectingView, context: Context) {
        if let hostingView = nsView.subviews.first as? NSHostingView<Content> {
            hostingView.rootView = content
        }
    }
}

class MouseDetectingView: NSView {
    var onMouseDown: ((NSPoint) -> Void)?
    var onMouseUp: (() -> Void)?
    var onDrag: ((NSPoint) -> Void)?
    
    private var isDragging = false

    init(hostingView: NSView) {
        super.init(frame: .zero)
        addSubview(hostingView)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: topAnchor),
            hostingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: trailingAnchor),
            hostingView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func mouseDown(with event: NSEvent) {
        isDragging = true
        let locationInView = convert(event.locationInWindow, from: nil)
        onMouseDown?(locationInView)
    }

    override func mouseUp(with event: NSEvent) {
        isDragging = false
        onMouseUp?()
    }

    override func mouseDragged(with event: NSEvent) {
        if isDragging {
            let locationInView = convert(event.locationInWindow, from: nil)
            onDrag?(locationInView)
        }
    }
}
