//
//  view-Preview.swift
//  castr
//
//  Created by Harrison Hall on 8/4/24.
//

import Foundation
import SwiftUI




//struct MainView: NSViewRepresentable {
//    
//    init() {
//        
//    }
//    
//    func makeNSView(context: Context) -> Main {
//        Main()
//    }
//    
//    func updateNSView(_ nsView: Main, context: Context) {}
//    
//}

struct MainView<Content: View>: NSViewRepresentable {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    func makeNSView(context: Context) -> Main {
        let mainView = Main()
        let hostingView = NSHostingView(rootView: content)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        
        mainView.addSubview(hostingView)
        
        return mainView
    }
    
    func updateNSView(_ nsView: Main, context: Context) {}
    
}



class Main: NSView {
    
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func mouseDown(with event: NSEvent) {
        print("a mouse down even occured")
    }
    
    override func mouseDragged(with event: NSEvent) {
        print("a mouse drag event occured")
    }
    
    override func mouseUp(with event: NSEvent) {
        print("a mouse up event occured")
    }
    
}
