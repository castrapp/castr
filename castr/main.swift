//
//  castrApp.swift
//  castr
//
//  Created by Harrison Hall on 8/3/24.
//

import SwiftUI
import AVFoundation
  


@main
struct castrApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
              SettingsPanel()
        }
    }
}




class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        window = NSWindow(
            contentRect: NSRect(x: 100, y: 100, width: 1400, height: 800),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window?.title = "Castr"
        window?.toolbar?.isVisible = true
//        window?.titleVisibility = .hidden
//        window?.titlebarAppearsTransparent = true
//        window?.isMovable = false
//        window?.collectionBehavior = [.fullScreenPrimary]
        
        
        // Create a transparent NSVisualEffectView
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = .fullScreenUI
        visualEffectView.state = .active
        visualEffectView.blendingMode = .behindWindow
        
        // Set the visual effect view as the window's content view
        window?.contentView = visualEffectView
        
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
        

        
        // Ask to install extension
        checkAndInstallCastrVirtualCamera()
        
        let hasPermission = ScreenRecordingPermissionHelper.checkScreenRecordingPermission()
        if hasPermission {
            print("Screen recording permission is granted")
        } else {
            print("Screen recording permission is not granted")
        }
        
    }

}











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
