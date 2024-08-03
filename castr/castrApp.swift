//
//  castrApp.swift
//  castr
//
//  Created by Harrison Hall on 8/3/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
           
            Toolbar()
            
            HStack {
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .border(Color.red, width: 1)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .border(Color.red, width: 1)
        .ignoresSafeArea()
        
    }
}
  

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
            contentRect: NSRect(x: 100, y: 100, width: 900, height: 600),
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
        
        hideStandardButtons(true)
        
        window?.contentView = NSHostingView(rootView: ContentView())
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
