import Cocoa
import SwiftUI
import AppKit
import ObjectiveC.runtime


// Create and run the application explicitly
let mainApp = NSApplication.shared
let delegate = AppDelegate()
mainApp.delegate = delegate
mainApp.run()



class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    var preferencesPanel: NSPanel?
    let contentView = ContentView()
    var observation: NSKeyValueObservation?

    override init() {
        MetalService.shared.setupMetal()
        print("the app group identifier is: ", appGroupIdentifier)
        
        // Access the shared UserDefaults using the app group identifier
        if let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) {
            // Save a string value
              sharedDefaults.set("Hello World", forKey: "testKey")
        }
        
        if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) {
            print("Shared container URL: \(containerURL.path)")
        } else {
            print("Failed to get the container URL for the app group.")
        }
        
        
        
        
        
        if let sharedDefaults = UserDefaults(suiteName: settingsDefaultsIdentifier) {
            // Save a string value
            sharedDefaults.set("3456", forKey: "width")
            sharedDefaults.set("2234", forKey: "height")
            sharedDefaults.set("30", forKey: "framerate")
        }
        
        if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: settingsDefaultsIdentifier) {
            print("Shared container URL: \(containerURL.path)")
        } else {
            print("Failed to get the container URL for the app group.")
        }
        

    }

    deinit {
        observation?.invalidate()
    }
    
    

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("Application did finish launching")
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1000, height: 600),
            styleMask: [.titled, .closable, .resizable, .miniaturizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        if let titlebar = window.standardWindowButton(.closeButton)?.superview {
            
            // Adding a custom titlebar
            let customTitlebarView = NSHostingView(rootView: TitlebarView())
            
            titlebar.addSubview(customTitlebarView)
            
            customTitlebarView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                customTitlebarView.leadingAnchor.constraint(equalTo: titlebar.leadingAnchor),
                customTitlebarView.trailingAnchor.constraint(equalTo: titlebar.trailingAnchor),
                customTitlebarView.topAnchor.constraint(equalTo: titlebar.topAnchor),
                customTitlebarView.bottomAnchor.constraint(equalTo: titlebar.bottomAnchor)
            ])
            
            
            // Remove NSVisualEffectView in default titlebar view to get rid of unwanted titlebar background that occurs in fullscreen
            if let visualEffectView = titlebar.subviews.first(where: { $0 is NSVisualEffectView }) as? NSVisualEffectView {
                visualEffectView.removeFromSuperview()
            }
            
        }
        
        
        
        
        
        // Setup Window Toolbar
        window.toolbar = NSToolbar(identifier: "MainToolbar")
        window.toolbarStyle = .unified
        
        // Setup Window Titlebar
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        
        
        // Setup for a translucent background
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = .hudWindow  // You can change this to other materials
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.state = .active
        
        window.contentView = visualEffectView
        
        let hostingView = NSHostingView(rootView: contentView)
        visualEffectView.addSubview(hostingView)
        
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: visualEffectView.topAnchor),
            hostingView.leadingAnchor.constraint(equalTo: visualEffectView.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: visualEffectView.trailingAnchor),
            hostingView.bottomAnchor.constraint(equalTo: visualEffectView.bottomAnchor)
        ])
        
        
        
        App.shared.trafficLightPadding = getTrafficLightPadding()
        if let closeButton = window.standardWindowButton(.closeButton) {
            App.shared.defaultWindowPadding = closeButton.frame.origin.x
        }

        
        window.center()
        window.makeKeyAndOrderFront(nil)
        
        
        setupObservers()
        
        setupMenu()
    
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    
    
    func setupObservers() {
        
        // Entering Fullscreen
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterFullScreen), name: NSWindow.willEnterFullScreenNotification, object: window)
        
        // Exiting Fullscreen
        NotificationCenter.default.addObserver(self, selector: #selector(willExitFullScreen), name: NSWindow.willExitFullScreenNotification, object: window)
        
        // Close Buttons Opacity
        if let closeButton = window.standardWindowButton(.closeButton) {
            observation = closeButton.observe(\.alphaValue, options: [.new]) { button, change in
     
                withAnimation(.easeInOut(duration: 0.2)) {
                    App.shared.trafficLightPadding = self.getTrafficLightPadding()
                }
            }
        }
    }
   
    
    
    func setupMenu() {
        let mainMenu = NSMenu()
        
        let appMenuItem = NSMenuItem()
        appMenuItem.submenu = NSMenu()
        mainMenu.addItem(appMenuItem)
        
        let settingsItem = NSMenuItem(title: "Settings", action: #selector(openSettings), keyEquivalent: ",")
        appMenuItem.submenu?.addItem(settingsItem)
        
        // Add a separator
        appMenuItem.submenu?.addItem(NSMenuItem.separator())
        
        // Add the Quit menu item
        let quitItem = NSMenuItem(title: "Quit Castr", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appMenuItem.submenu?.addItem(quitItem)
        
        NSApplication.shared.mainMenu = mainMenu
    }

    
    
    
    @objc func openSettings() {
        if preferencesPanel == nil {
            preferencesPanel = NSPanel(
                contentRect: NSRect(x: 0, y: 0, width: 900, height: 700),
                styleMask: [.titled, .closable,  .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            
            // Add custom titlebar
            if let titlebar = preferencesPanel?.standardWindowButton(.closeButton)?.superview {
                let customTitlebarView = NSHostingView(rootView: PreferencesPanelTitlebarView())
                
                titlebar.addSubview(customTitlebarView)
                
                customTitlebarView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    customTitlebarView.leadingAnchor.constraint(equalTo: titlebar.leadingAnchor),
                    customTitlebarView.trailingAnchor.constraint(equalTo: titlebar.trailingAnchor),
                    customTitlebarView.topAnchor.constraint(equalTo: titlebar.topAnchor),
                    customTitlebarView.bottomAnchor.constraint(equalTo: titlebar.bottomAnchor)
                ])
                
                // Remove NSVisualEffectView in default titlebar view
                if let visualEffectView = titlebar.subviews.first(where: { $0 is NSVisualEffectView }) as? NSVisualEffectView {
                    visualEffectView.removeFromSuperview()
                }
            }
//
//            // Setup for a translucent background
//            let visualEffectView = NSVisualEffectView()
//            visualEffectView.material = .hudWindow  // You can change this to other materials
//            visualEffectView.blendingMode = .behindWindow
//            visualEffectView.state = .active
//
//            preferencesPanel?.contentView = visualEffectView
//
//            let hostingView = NSHostingView(rootView: PreferencesView())
//            visualEffectView.addSubview(hostingView)
//
//            hostingView.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                hostingView.topAnchor.constraint(equalTo: visualEffectView.topAnchor),
//                hostingView.leadingAnchor.constraint(equalTo: visualEffectView.leadingAnchor),
//                hostingView.trailingAnchor.constraint(equalTo: visualEffectView.trailingAnchor),
//                hostingView.bottomAnchor.constraint(equalTo: visualEffectView.bottomAnchor)
//            ])
            
            
            
            // Hide minimize butotn and fullscreen button
            preferencesPanel?.standardWindowButton(.miniaturizeButton)?.isHidden = true
            preferencesPanel?.standardWindowButton(.zoomButton)?.isHidden = true
            
            // Setup Preferences Toolbar
            preferencesPanel?.toolbar = NSToolbar(identifier: "PreferencesToolbar")
            preferencesPanel?.toolbarStyle = .unified
            
            // Setup Preferences Titlebar
            preferencesPanel?.titlebarAppearsTransparent = true
            preferencesPanel?.titleVisibility = .hidden
            
            
            preferencesPanel?.title = "Settings"
            preferencesPanel?.contentView = NSHostingView(rootView: PreferencesView())
            preferencesPanel?.isFloatingPanel = true
            preferencesPanel?.isReleasedWhenClosed = false
            

        }
       
        preferencesPanel?.center()
        preferencesPanel?.makeKeyAndOrderFront(nil)
    }
    
            
            /// `Observer Functions`
            @objc func willEnterFullScreen(_ notification: Notification) {
                print("Entering fullscreen")
                
                guard
                    let closeButton = window.standardWindowButton(.closeButton)
                else { return }

                App.shared.trafficLightPadding = closeButton.frame.origin.x
            }

            
           @objc func willExitFullScreen(_ notification: Notification) {
                print("Exiting fullscreen")
               
               guard
                   let closeButton = window.standardWindowButton(.closeButton),
                   let zoomButton = window.standardWindowButton(.zoomButton)
               else { return }

               App.shared.trafficLightPadding = closeButton.frame.origin.x + (zoomButton.frame.maxX - closeButton.frame.origin.x) + 10
            }
            
            
            
            func getTrafficLightPadding() -> CGFloat {
                guard
                    let closeButton = window.standardWindowButton(.closeButton),
                    let zoomButton = window.standardWindowButton(.zoomButton)
                else { return CGFloat(0) }
                    
                let closeButtonInitialX = closeButton.frame.origin.x
                let trafficLightWidth = zoomButton.frame.maxX - closeButton.frame.minX
                
                return closeButtonInitialX + (trafficLightWidth * CGFloat(closeButton.alphaValue)) + (CGFloat(closeButton.alphaValue) * 10)
            }
    
    
   

}












// TODO: DELETE THIS
import AVFoundation

class ScreenRecordingPermissionHelper {
    static func checkScreenRecordingPermission() -> Bool {
        let queue = DispatchQueue(label: "com.yourapp.screencapture")
        let stream = CGDisplayStream(dispatchQueueDisplay: CGMainDisplayID(),
                                     outputWidth: 1,
                                     outputHeight: 1,
                                     pixelFormat: Int32(kCVPixelFormatType_32BGRA),
                                     properties: nil,
                                     queue: queue) { _, _, _, _ in }
        
        return stream != nil
    }
}



func checkAndInstallCastrVirtualCamera() {
    let isCastrCameraInstalled = checkForCastrVirtualCamera()
    
    if isCastrCameraInstalled {
        print("Castr Virtual Camera is already installed.")
        CameraViewModel.shared.start()
        GlobalState.shared.streamToVirtualCamera = true
    } else {
        print("Castr Virtual Camera not found. Attempting to install...")
        SystemExtensionManager.shared.installExtension(extensionIdentifier: "harrisonhall.castr.virtualcamera") { success, error in
            if success {
                print("Castr Virtual Camera installed successfully")
                CameraViewModel.shared.start()
                GlobalState.shared.streamToVirtualCamera = true
            } else {
                if let error = error {
                    print("Failed to install Castr Virtual Camera: \(error.localizedDescription)")
                } else {
                    print("Failed to install Castr Virtual Camera")
                }
            }
        }
    }
}

func checkForCastrVirtualCamera() -> Bool {
    let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.externalUnknown],
                                                           mediaType: .video,
                                                           position: .unspecified)
    
    let devices = discoverySession.devices
    
    for device in discoverySession.devices {
        if device.localizedName == "Castr Virtual Camera" {
            return true
        }
    }
    
    return false
}
