//
//  sheet-initialPermissions.swift
//  castr
//
//  Created by Harrison Hall on 9/4/24.
//

import Foundation
import SwiftUI
import ScreenCaptureKit

class PermissionsModel: ObservableObject {
    static var shared = PermissionsModel()
    
    private init() {}
    
    @Published var isVirtualCameraInstalled = checkForCastrVirtualCamera()
    @Published var isScreenRecordingGranted = false
}



struct InitialPermissionsSheet: View {
    
    @ObservedObject var content = ContentModel.shared
    @ObservedObject var permissions = PermissionsModel.shared
    @State private var eventMonitor: Any?


    
    var body: some View {
        VStack(spacing: 0) {
            Text("Welcome to Castr")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
                .padding(.bottom, 40)
            
            Text("Castr requires your permission to be able to provide certain features. It is recommended to enable these permissions and features now. Although, you can always enable them later in settings.")
                .padding(.bottom, 40)
                .foregroundColor(.secondary)
            
            // MARK: - Virtual Camera
            VirtualCamera()
            if isLaunchingFromApplicationsFolder() {
                Text("It is recommended to restart the application after installing the extension, or if you do not see it available in the list of camera devices.")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .padding(.top, 10)
            }
            
            
            // MARK: - Screen Recording
            ScreenRecording()

            Spacer()
            
            Divider()
            
            HStack {
                Button("Another time") { content.showInitialPermissionsSheet = false }
                .buttonStyle(.borderless)
                .controlSize(.large)
                
                Spacer()
                
                Button("Restart Application") { closeSheet() }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(!(permissions.isVirtualCameraInstalled && permissions.isScreenRecordingGranted))
            }
            .frame(maxWidth: .infinity)
            .padding(22)
            
        }
        .frame(maxWidth: 700, minHeight: 580, alignment: .top)
        .onAppear(perform: startListeningForCommandQ)
        .onDisappear(perform: stopListeningForCommandQ)
       
    }
    
    
    func closeSheet() {
        
        // Set the "gotInitialPermissions" property in the UserDefaults to true
        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: "gotInitialPermissions")
        
        
        // Then close the modal
        content.showInitialPermissionsSheet = false
        
        
        // Then attempt to sestart the application
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
           restartApplication()
        }
    }
    
    func restartApplication() {
        // Get the path to the current executable
        let path = Bundle.main.bundlePath

        // Prepare the relaunch process
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        task.arguments = [path]

        do {
            try task.run()
        } catch {
            print("Failed to relaunch application: \(error)")
        }

        // Terminate the current app
        NSApp.terminate(nil)
    }
    
    
    
    // Function to start listening for Command+Q
    func startListeningForCommandQ() {
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.modifierFlags.contains(.command) && event.keyCode == 12 {
                
                // Close the InitialPermissionsSheet
                ContentModel.shared.showInitialPermissionsSheet = false
                
                // Ensure any modal views or sheets are dismissed before quitting
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    // Terminate the application after dismissing the sheet
                    NSApp.terminate(nil)
                }
                
                print("Attempting to quit application")
                
                return nil // Swallow the event
            }
            return event
        }
    }

    // Function to stop listening for Command+Q
    func stopListeningForCommandQ() {
        if let eventMonitor = eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
            self.eventMonitor = nil
        }
    }
    
    
  
    
}




func isLaunchingFromApplicationsFolder() -> Bool {
    let appPath = Bundle.main.bundlePath
    return appPath.contains("/Applications")
}












struct VirtualCamera: View {
    
    @State var hasInstallButtonBeenPressed = false
    @State var showSystemExtensionWarning = false
    @State var isInstalled = checkForCastrVirtualCamera() {
        didSet {
            PermissionsModel.shared.isVirtualCameraInstalled = isInstalled
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            HStack(spacing: 16) {
                Image(systemName: "camera.fill")
                .font(.system(size: 32))
                .padding(.leading, 6)
                .padding(.trailing, 2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Virtual Camera")
                        .font(.system(size: 14, weight: .bold))
                    
                    Text("This will install the Castr Virtual Camera, which you can then cast your content to.")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                }
            }
           
            Divider()
            
            HStack {
                
                // We can first check if we are installed, if so, we'll show success
                // Success
                if isInstalled {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(.primary, .blue)
                            .symbolRenderingMode(.palette)
                        Text("System Extension succesfully installed successfully enabled.")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 12))
                    }
                }
                
                // If we are not installed, then we check if we are launching from the /Applications folder
                // Application Folder Precheck
                // Standby but not launching from /Applications
                else if !isLaunchingFromApplicationsFolder() {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 10))
                            .symbolRenderingMode(.multicolor)
                        Text("Please move the app to the Applications folder to install the virtual camera extension.")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                
                // Otherwise if we are not installed, but launching the from the Applications folder, and if
                // we have also not showed the SystemExtensionWarning yet, this assumes the user has not prompted
                // the "Install" button yet, because if they did, then either isInstalled would be true and we would
                // be showing the installation success message or, isInstalled would be false but we would be showing
                // the SystemExtensionWarning
                // Standby
                else if !isInstalled && !showSystemExtensionWarning {
                    Text(hasInstallButtonBeenPressed ? "Installation attempted. Please check System Settings -> Privacy & Security and click on 'Allow' to enable it." : "Click to install the virtual camera")
                        .foregroundStyle(.secondary)
                        .font(.system(size: 12))
                }
                
        
                // Otherwise, if we are not installed, and launching from the /Applications folder, but we are showing the
                // SystemExtensionWarning, this means the user has clicked on the install button and prompted the installation
                // Failure
                else if !isInstalled  && showSystemExtensionWarning {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 10))
                            .symbolRenderingMode(.multicolor)
                        Text("System Extension denied. Go to System Settings -> Privacy & Security and click on 'Allow' to enable it.")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                
                if isInstalled {
                    Button("Installed") {}
                        .disabled(true)
                }
                
                else if !isLaunchingFromApplicationsFolder() {
                    Button("Install") {}
                        .disabled(true)
                }
                
                else if !isInstalled && !showSystemExtensionWarning {
                    Button("Install") { 
                        hasInstallButtonBeenPressed = true
                        installVirtualCamera()
                    }
                }
                
                else if !isInstalled  && showSystemExtensionWarning {
                    Button("Open System Preferences") {
                        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security") {
                           NSWorkspace.shared.open(url)
                       }
                    }
                }
               
                
             
            }
            
        }
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
        ._groupBox()
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 30)
        .onAppear {
            // Setup a window focus listener
            NotificationCenter.default.addObserver(forName: NSApplication.didBecomeActiveNotification, object: nil, queue: .main) { _ in
                
                // Everytime the window is focused, if the installationStatus is still false then we recheck the installed status
                if !isInstalled {
                    isInstalled = checkForCastrVirtualCamera()
                }
                
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self)
        }
     
    }
    
    private func installVirtualCamera() {
        SystemExtensionManager.shared.installExtension(extensionIdentifier: appVirtualCameraBundleId) { success, error in
            if success {
                print("Castr Virtual Camera installed successfully")
                isInstalled = true
                showSystemExtensionWarning = false
            } else {
                isInstalled = false
                showSystemExtensionWarning = true
            }
        }
    }
}


















struct ScreenRecording: View {
    
    @State var screenRecordingEnabled = false {
        didSet {
            PermissionsModel.shared.isScreenRecordingGranted = screenRecordingEnabled
        }
    }
    @State var showScreenRecordingWarning = false
    
    @State var hasUserClickedInstallButton = false

    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            HStack(spacing: 16) {
                Image(systemName: "rectangle.inset.filled.badge.record")
                .font(.system(size: 32))
                .padding(.leading, 6)
                .padding(.trailing, 2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Screen Recording")
                        .font(.system(size: 14, weight: .bold))
                    
                    Text("This allows Castr to record the contents of your screen and system audio, even while using other applications. Castr requires this permission to be able to capture your screen.")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                }
            }
           
            Divider()
            
            HStack(spacing: 6) {
                
                // First we can default to if the screenRecordingEnabled variable is true, if so, we will show
                // that we are successful
                // Success
                if screenRecordingEnabled {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(.primary, .blue)
                            .symbolRenderingMode(.palette)
                        Text("Screen Recording successfully enabled.")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 12))
                    }
                    .onAppear {
                        print("screen recording is: ", PermissionsModel.shared.isScreenRecordingGranted)
                        print("Virtual Camera is: ", PermissionsModel.shared.isVirtualCameraInstalled)
                    }
                }
                
                // Otherwise, if screenRecordingEnabled is not true, and if we are NOT showing the screenRecordingWarning,
                // this assumes that the user has not yet prompted the "Install" button. So we are in standby
                // Standby
                else if !screenRecordingEnabled && !showScreenRecordingWarning {
                    Text("Click to enable this permission")
                        .foregroundStyle(.secondary)
                        .font(.system(size: 12))
                }
                
                // Otherwise, if screenRecordingEnabled is not true, but we are showing the screenRecordingWarning, this
                // assumes the user has prompted the install button and the installation has failed.
                // Failure
                else if !screenRecordingEnabled && showScreenRecordingWarning {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 10))
                            .symbolRenderingMode(.multicolor)
                        Text("Screen Recording Permission denied. Go to System Settings -> Privacy & Security -> Screen & System Audio Recording to enable it.")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                
                if screenRecordingEnabled {
                    Button("Installed") {}
                    .disabled(true)
                }
                
                else if !screenRecordingEnabled && !showScreenRecordingWarning {
                    Button("Enable") { promptForScreenRecording() }
                }
                
                else if !screenRecordingEnabled && showScreenRecordingWarning {
                    Button("Open System Settings") {
                        // URL for Privacy & Security in System Settings
                        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenRecording") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                }
        
            }
        }
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
        ._groupBox()
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 30)
        .padding(.top, 30)
        .onAppear {
            
            // Setup a window focus listener
            NotificationCenter.default.addObserver(forName: NSApplication.didBecomeActiveNotification, object: nil, queue: .main) { _ in
                
                // Everytime the window is focused, if the user HAS already clicked on the install button,
                // then we can recheck the permission.
                if hasUserClickedInstallButton {
                    promptForScreenRecording()
                }
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    
    func promptForScreenRecording() {
        print("prompting for screen recording")
        hasUserClickedInstallButton =  true
        
        // Prompt the user for the permission
        let permission = checkScreenRecordingPermission()
        
        if permission {
            screenRecordingEnabled = true
            showScreenRecordingWarning = false
        }
        
        else {
            screenRecordingEnabled = false
            showScreenRecordingWarning = true
        }
    }
}




func checkScreenRecordingPermission() -> Bool {
    let mainDisplayId = CGMainDisplayID()
    let stream = CGDisplayStream(dispatchQueueDisplay: mainDisplayId,
                                 outputWidth: 1,
                                 outputHeight: 1,
                                 pixelFormat: Int32(kCVPixelFormatType_32BGRA),
                                 properties: nil,
                                 queue: DispatchQueue.global()) { _, _, _, _ in }

    return stream != nil
}
