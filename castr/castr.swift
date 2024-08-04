//
//  castrApp.swift
//  castr
//
//  Created by Harrison Hall on 8/3/24.
//

import SwiftUI

  


@main
struct castrApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
              EmptyView()
        }
    }
}




class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow?
    var fullscreenObserver: NSObjectProtocol?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        window = NSWindow(
            contentRect: NSRect(x: 100, y: 100, width: 1400, height: 800),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window?.title = "Castr"
        window?.toolbar?.isVisible = false
        window?.titleVisibility = .hidden
        window?.titlebarAppearsTransparent = true
        window?.isMovable = false
        window?.collectionBehavior = [.fullScreenPrimary]
        
        
        // Create a transparent NSVisualEffectView
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = .fullScreenUI
        visualEffectView.state = .active
        visualEffectView.blendingMode = .behindWindow
        
        // Set the visual effect view as the window's content view
        window?.contentView = visualEffectView
        
        hideStandardButtons(true)
        
        // Create and add the SwiftUI view
        let contentView = NSHostingView(rootView: ContentView())
        contentView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.addSubview(contentView)
        
        // Add constraints to make the content view fill the visual effect view
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: visualEffectView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: visualEffectView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: visualEffectView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: visualEffectView.bottomAnchor)
        ])
        
        window?.makeKeyAndOrderFront(nil)
        
        // Add observer for fullscreen changes
        fullscreenObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.didEnterFullScreenNotification,
            object: window,
            queue: .main
        ) { [weak self] _ in
            self?.hideStandardButtons(false)
            print("entering fullscreen mode")
        }
        
        NotificationCenter.default.addObserver(
            forName: NSWindow.didExitFullScreenNotification,
            object: window,
            queue: .main
        ) { [weak self] _ in
            self?.hideStandardButtons(true)
            print("exiting fullscreen mode")
        }
    }
    
    func hideStandardButtons(_ hide: Bool) {
        window?.standardWindowButton(.closeButton)?.isHidden = hide
        window?.standardWindowButton(.miniaturizeButton)?.isHidden = hide
        window?.standardWindowButton(.zoomButton)?.isHidden = hide
        window?.titleVisibility = hide ? .hidden : .visible
    }
    
    deinit {
        if let observer = fullscreenObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
