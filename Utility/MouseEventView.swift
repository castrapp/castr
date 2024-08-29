import SwiftUI
import AppKit

struct MouseEventView<Content: View>: NSViewRepresentable {
    var onMouseDown: (NSEvent) -> Void
    var onMouseDrag: (NSEvent) -> Void
    var onMouseUp: (NSEvent) -> Void
    var onMouseMoved: (NSEvent) -> Void
    let content: Content?

    init(onMouseDown: @escaping (NSEvent) -> Void = { _ in },
         onMouseDrag: @escaping (NSEvent) -> Void = { _ in },
         onMouseUp: @escaping (NSEvent) -> Void = { _ in },
         onMouseMoved: @escaping (NSEvent) -> Void = { _ in },
         @ViewBuilder content: () -> Content? = { nil }) {
        self.onMouseDown = onMouseDown
        self.onMouseDrag = onMouseDrag
        self.onMouseUp = onMouseUp
        self.onMouseMoved = onMouseMoved
        self.content = content()
    }

    func makeNSView(context: Context) -> CustomNSView {
        let view = CustomNSView(
            onMouseDown: onMouseDown,
            onMouseDrag: onMouseDrag,
            onMouseUp: onMouseUp,
            onMouseMoved: onMouseMoved
        )
        
        // If there's SwiftUI content, wrap it in an NSHostingView
        if let content = content {
            let hostingView = NSHostingView(rootView: content)
            hostingView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(hostingView)
            NSLayoutConstraint.activate([
                hostingView.topAnchor.constraint(equalTo: view.topAnchor),
                hostingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                hostingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                hostingView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        }

        return view
    }

    func updateNSView(_ nsView: CustomNSView, context: Context) {
        if let hostingView = nsView.subviews.first(where: { $0 is NSHostingView<Content> }) as? NSHostingView<Content>,
           let content = content {
            hostingView.rootView = content
        }
    }

    class CustomNSView: NSView {
        var onMouseDown: (NSEvent) -> Void
        var onMouseDrag: (NSEvent) -> Void
        var onMouseUp: (NSEvent) -> Void
        var onMouseMoved: (NSEvent) -> Void

        init(onMouseDown: @escaping (NSEvent) -> Void,
             onMouseDrag: @escaping (NSEvent) -> Void,
             onMouseUp: @escaping (NSEvent) -> Void,
             onMouseMoved: @escaping (NSEvent) -> Void) {
            self.onMouseDown = onMouseDown
            self.onMouseDrag = onMouseDrag
            self.onMouseUp = onMouseUp
            self.onMouseMoved = onMouseMoved
            super.init(frame: .zero)
            self.addTrackingArea(NSTrackingArea(rect: self.bounds, options: [.mouseMoved, .activeInKeyWindow, .inVisibleRect], owner: self, userInfo: nil))
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func mouseDown(with event: NSEvent) {
            onMouseDown(event)
        }

        override func mouseDragged(with event: NSEvent) {
            onMouseDrag(event)
        }

        override func mouseUp(with event: NSEvent) {
            onMouseUp(event)
        }

        override func mouseMoved(with event: NSEvent) {
            onMouseMoved(event)
        }

        override func updateTrackingAreas() {
            super.updateTrackingAreas()
            for trackingArea in trackingAreas {
                removeTrackingArea(trackingArea)
            }
            addTrackingArea(NSTrackingArea(rect: self.bounds, options: [.mouseMoved, .activeInKeyWindow, .inVisibleRect], owner: self, userInfo: nil))
        }
    }
}
