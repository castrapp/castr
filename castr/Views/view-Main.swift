//
//  view-Main.swift
//  castr
//
//  Created by Harrison Hall on 8/29/24.
//

import Foundation
import SwiftUI


struct MainView3: View {
    
    var body: some View {
        VStack(spacing: 0) {
           

    
        }
        .frame(idealWidth: .infinity, maxWidth: .infinity, maxHeight: .infinity)
        .background(WindowBackgroundShapeStyle.windowBackground)
        .border(Color.red)
    }
    
    
    
  
}




import SwiftUI
import AppKit

struct MainView2<Content: View>: NSViewRepresentable {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    func makeNSView(context: Context) -> Main {
        let mainView = Main()
        let hostingView = NSHostingView(rootView: content)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        
        mainView.addSubview(hostingView)
        
        // Constraints to match the hosting view to the Main view's size
//        NSLayoutConstraint.activate([
//            hostingView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
//            hostingView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
//            hostingView.topAnchor.constraint(equalTo: mainView.topAnchor),
//            hostingView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor)
//        ])
        
        return mainView
    }

    func updateNSView(_ nsView: Main, context: Context) {
        if let hostingView = nsView.subviews.first as? NSHostingView<Content> {
            hostingView.rootView = content
        }
    }
}
