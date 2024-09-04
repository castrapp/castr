//
//  view-Preferences.swift
//  castr
//
//  Created by Harrison Hall on 8/22/24.
//

import Foundation
import SwiftUI
import AVFoundation
import ScreenCaptureKit


struct PreferencesView: View {
    
    @State var text: String = ""
    @ObservedObject var settings = Settings.shared
    
    
    var body: some View {
        HSplitView {
            
            VStack(spacing: 0) {
//                TextField("Placeholder", text: $text)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .disabled(true)
//                .padding(.bottom, 10)
                
                ForEach(SettingsEnum.allCases, id: \.self) { setting in
                    SettingCard(
                        title: setting.title,
                        imageName: setting.imageName,
                        isSelected: settings.selectedSetting == setting
                    )
                    .onMouseDown {
                        print("Mousing Down on \(setting.title)")
                        settings.selectedSetting = setting
                    }
                }
                
            }
            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            .frame(minWidth: 150, maxWidth: 200, maxHeight: .infinity, alignment: .top)
            .background(MaterialView(material: .sidebar))
            
            
            ScrollView {
                switch settings.selectedSetting {
                    case .permissions:      PermissionsSettingsView()
                    case .virtualCamera:    VirtualCameraSettingsView()
                    
                    // TODO: Implement recording functionality
//                    case .recording:        RecordingSettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .clipped()

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)

    }

}






/// `Permissions Settings`

struct PermissionsSettingsView: View {
    
    @State var screenRecordingEnabled = false
    @State var cameraEnabled = false
    @State var microphoneEnabled = false
    
    @State var screenRecordingDenied = false
    @State var cameraDenied = false
    @State var microphoneDenied = false
   
 
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            Text("Castr requires your permission to be able to provide certain features. It is recommended to enable these permissions. but they are not required to use the app. You can always enable them later.")
            .font(.system(size: 12))
            .foregroundColor(.secondary)
            .padding(.leading, 10)
            
            ScreenRecordingView.padding(.vertical, 20)
//            CameraView.padding(.vertical, 20)
//            MicrophoneView.padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
        .padding(.top, 2)
        .onAppear { 
            requestScreenRecording()
//            requestCamera()
//            requestMicrophone()
            print("Permissions settings are appearing:")
        }
    }
    
    
    
    
    /// `Screen Recording Permission View`
    
    var ScreenRecordingView: some View {

        VStack(alignment: .leading, spacing: 10) {
            
            HStack(spacing: 10) {
                Image(systemName: "rectangle.inset.filled.badge.record")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 35, height: 35)
                .padding(.leading, 6)
                .padding(.trailing, 2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Screen Recording")
                        .font(.system(size: 13))
                    
                    Text("This allows Castr to record the contents of your screen and system audio, even while using other applications. Castr requires this permission to be able to capture your screen.")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                }
            }
           
            Divider()
            
            HStack {
                Text("Enabled")
                Spacer()
                HStack(spacing: 0) {
                    Text(screenRecordingEnabled ? "Yes" : "No")
                    Image(systemName: "circle.fill")
                            .foregroundColor(screenRecordingEnabled ? .green : .red)
                            .font(.system(size: 7))
                            .padding(.leading, 5)
                }
            }
            
            Divider()
            
            HStack {
                if(screenRecordingDenied && !screenRecordingEnabled) {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 10))
                            .symbolRenderingMode(.multicolor)
                        Text("This permission has been denied. Please go 'System Preferences -> Privacy & Security -> Screen & System Audio Recording' to enable it.'")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                Button("Request Permission") { requestScreenRecording() }
            }
        }
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
        ._groupBox()
        .fixedSize(horizontal: false, vertical: true)
       
    }
    
    
    
    
    
    /// `Camera/Video Permission View
    
    var CameraView: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            
            HStack(spacing: 10) {
                Image(systemName: "video.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 35, height: 35)
                .padding(.leading, 6)
                .padding(.trailing, 2)

                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Camera")
                        .font(.system(size: 13))
                    
                    Text("This allows Castr to access your camera. Castr requires this permission to be able to capture your camera.")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                }
            }
           
            Divider()
            
            HStack {
                Text("Enabled")
                Spacer()
                HStack(spacing: 0) {
                    Text(cameraEnabled ? "Yes" : "No")
                    Image(systemName: "circle.fill")
                            .foregroundColor(cameraEnabled ? .green : .red)
                            .font(.system(size: 7))
                            .padding(.leading, 5)
                }
            }
            
            Divider()
            
            HStack {
                if(cameraDenied && !cameraEnabled) {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 10))
                            .symbolRenderingMode(.multicolor)
                        Text("This permission has been denied. Please go 'System Preferences -> Privacy & Security -> Camera' to enable it.'")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                Button("Request Permission") { requestCamera() }
            }
        }
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
        ._groupBox()
        .fixedSize(horizontal: false, vertical: true)
       
    }
    
    
    
    
    
    /// `Microphone Permission View`
    
    var MicrophoneView: some View {
            
        VStack(alignment: .leading, spacing: 10) {
            
            HStack(spacing: 10) {
                Image(systemName: "mic.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 35, height: 35)
                .padding(.leading, 6).padding(.trailing, 2)

                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Mircophone")
                        .font(.system(size: 13))
                    
                    Text("This allows Castr to access your microphone. Castr requires this permission to be able to capture your microphone.")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                }
            }
           
            Divider()
            
            HStack {
                Text("Enabled")
                Spacer()
                HStack(spacing: 0) {
                    Text(microphoneEnabled ? "Yes" : "No")
                    Image(systemName: "circle.fill")
                            .foregroundColor(microphoneEnabled ? .green : .red)
                            .font(.system(size: 7))
                            .padding(.leading, 5)
                }
            }
            
            Divider()
            
            HStack {
                if(microphoneDenied && !microphoneEnabled) {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 10))
                            .symbolRenderingMode(.multicolor)
                        Text("This permission has been denied. Please go 'System Preferences -> Privacy & Security -> Microphone' to enable it.'")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                Button("Request Permission") { requestMicrophone() }
            }
        }
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
        ._groupBox()
        .fixedSize(horizontal: false, vertical: true)
    }
    
    private func requestScreenRecording() {
        Task {
            do {
                // If the app doesn't have screen recording permission, this call generates an exception.
                try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
                screenRecordingEnabled = true
            } catch {
                screenRecordingEnabled = false
                screenRecordingDenied = true
            }
        }
    }
    
    private func requestCamera() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                print("Camera access granted")
                // Proceed with setting up the camera session
                cameraEnabled = true
            } else {
                print("Camera access denied")
                // Inform the user they need to grant camera access
                // You might want to show an alert here or guide them to System Settings
                cameraEnabled = false
                cameraDenied = true
            }
        }
    }
    
    
    private func requestMicrophone() {
        AVCaptureDevice.requestAccess(for: .audio) { granted in
                if granted {
                    print("Microphone access granted")
                    microphoneEnabled = true
                } else {
                    print("Microphone access denied")
                    // Inform the user they need to grant microphone access
                    // You might want to show an alert here or guide them to System Settings
                    microphoneEnabled = false
                    microphoneDenied = true
                }
            }
    }
    
}









/// `Virutal Camera Settings`



struct VirtualCameraSettingsView: View {
    
    @ObservedObject var settings = Settings.shared
    
    // Define @State properties with default values
    @State private var modelName: String = "Castr Virtual Camera"
    @State private var extensionBundleIdentifier: String = "harrisonhall.castr.virtualcamera"
    @State private var connectedStatus: Bool = false
    @State private var selectedFramerate: Int = 30
    @State private var selectedResolution: String = "1728x1117"
    @State private var installationStatus: Bool = false
    
    let resolutions = ["1728x1117", "3456x2234"]
    
    var body: some View {
        VStack(spacing: 0) {
            
            Text(modelName)
                .font(.system(size: 16, weight: .bold))
                .padding(.top, 50)
            
            Text(extensionBundleIdentifier)
                .font(.system(size: 14))
                .padding(.top, 10)
                .padding(.bottom, 20)
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Model Name")
                    Spacer()
                    Text(modelName)
                        .foregroundStyle(.secondary)
                }
                
                Divider()
                
                HStack {
                    Text("Extension Bundle Identifier")
                    Spacer()
                    Text(extensionBundleIdentifier)
                        .foregroundStyle(.secondary)
                }
                
                Divider()
                
                HStack {
                    Text("Output Resolution")
                    Spacer()
                    Picker("", selection: $selectedResolution) {
                        ForEach(resolutions, id: \.self) { resolution in
                            Text("\(resolution)").tag(resolution)
                        }
                    }
                    .buttonStyle(.borderless)
                    .fixedSize()
                    .onChange(of: selectedResolution) { newValue in
                        saveVirtualCameraSetting(key: "resolution", value: newValue)
                    }
                    .disabled(installationStatus == false)
                }
                
                Divider()
                
                HStack {
                    Text("Output Framerate")
                    Spacer()
                    Stepper("\(selectedFramerate)",
                        value: $selectedFramerate,
                        in: 0...60
                    )
                    .onChange(of: selectedFramerate) { newValue in
                       saveVirtualCameraSetting(key: "framerate", value: newValue)
                    }
                    .disabled(installationStatus == false)
                    .foregroundColor(installationStatus ? .primary : Color(NSColor.tertiaryLabelColor))
                }
                
                Divider()
                
                HStack {
                    Text("Status")
                    Spacer()
                    HStack(spacing: 0) {
                        Text(connectedStatus ? "Connected" : "Not Connected")
//                            .foregroundStyle(.secondary)
                        Image(systemName: "circle.fill")
                                .foregroundColor(connectedStatus ? .green : .red)
                                .font(.system(size: 7))
                                .padding(.leading, 5)
                    }
                }
                
                Divider()
                
                HStack {
                    Text("Installation Status")
                    Spacer()
                    HStack(spacing: 0) {
                        Text(installationStatus ? "Installed" : "Not Installed")
//                            .foregroundStyle(.secondary)
                        Image(systemName: "circle.fill")
                            .foregroundColor(installationStatus ? .green : .red)
                            .font(.system(size: 7))
                            .padding(.leading, 5)
                    }
                    .onAppear { installationStatus = checkForCastrVirtualCamera() }
                }
                
                Divider()
                
                HStack {
                    if(installationStatus == false) {
                        HStack(spacing: 2) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 10))
                                .symbolRenderingMode(.multicolor)
                            Text("To stream to the virtual camera, you must install it.")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                    Button("Uninstall") { uninstallVirtualCamera() }
                    Button("Install") { installVirtualCamera() }
                }
              
            }
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
            ._groupBox()
            .fixedSize(horizontal: false, vertical: true)
            .onAppear { loadVirtualCameraSettings() }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
        .padding(.top, 2)
    }
    
    private func installVirtualCamera() {
        SystemExtensionManager.shared.installExtension(extensionIdentifier: appVirtualCameraBundleId) { success, error in
            if success {
                print("Castr Virtual Camera installed successfully")
                installationStatus = true
            } else {
                installationStatus = false
                if let error = error {
                    print("Failed to install Castr Virtual Camera: \(error.localizedDescription)")
                } else {
                    print("Failed to install Castr Virtual Camera")
                }
            }
        }
    }
    
    private func uninstallVirtualCamera() {
        SystemExtensionManager.shared.uninstallExtension(extensionIdentifier: appVirtualCameraBundleId) { success, error in
            if success {
                print("Castr Virtual Camera uninstalled successfully")
                installationStatus = false
            } else {
//                installationStatus = false
                if let error = error {
                    print("Failed to install Castr Virtual Camera: \(error.localizedDescription)")
                } else {
                    print("Failed to install Castr Virtual Camera")
                }
            }
        }
    }
    
    
    private func loadVirtualCameraSettings() {
        guard let sharedDefaults = UserDefaults(suiteName: settingsDefaultsIdentifier) else { return }
        
        var virtualCameraSettings = sharedDefaults.dictionary(forKey: "virtualCameraSettings") as? [String: Any] ?? [:]

        // Load or initialize each setting
        selectedResolution = virtualCameraSettings["resolution"] as? String ?? selectedResolution
        selectedFramerate = virtualCameraSettings["framerate"] as? Int ?? selectedFramerate
       

        // Save default values if they weren't present
        virtualCameraSettings["resolution"] = selectedResolution
        virtualCameraSettings["framerate"] = selectedFramerate
        

        sharedDefaults.set(virtualCameraSettings, forKey: "virtualCameraSettings")
        print("Virtual Camera Settings loaded successfully.")
    }
    
    private func saveVirtualCameraSetting(key: String, value: Any) {
        guard let sharedDefaults = UserDefaults(suiteName: settingsDefaultsIdentifier) else { return }
        
        var virtualCameraSettings = sharedDefaults.dictionary(forKey: "virtualCameraSettings") as? [String: Any] ?? [:]
        virtualCameraSettings[key] = value
        sharedDefaults.set(virtualCameraSettings, forKey: "virtualCameraSettings")
        print("Virtual Camera setting '\(key)' saved with value: \(value)")
    }
}





/// `Recording Settings`

struct RecordingSettingsView: View {
    
    @ObservedObject var settings = Settings.shared
    @State var outputDestination: String?
    @State var selectedFramerate = 30
    @State var selectedResolution = "1728x1117"
    @State var selectedColorFormat = "BGRA"
    @State var selectedBitrate = 15_000_000
    @State var selectedEncoder = "h264"
     
    let resolutions = ["1728x1117", "3456x2234"]
    let encoders = ["h264", "h265"]
    let colorFormats = ["BGRA", "YUV"]
    
    var body: some View {
        VStack(spacing: 0) {
            
            VStack(alignment: .leading, spacing: 10) {
                
                HStack {
                    Text("Output Resolution")
                    Spacer()
                    Picker("", selection: $selectedResolution) {
                        ForEach(resolutions, id: \.self) { resolution in
                            Text("\(resolution)").tag(resolution)
                        }
                    }
                    .buttonStyle(.borderless)
                    .fixedSize()
                    .onChange(of: selectedResolution) { newValue in
                        saveRecordingSetting(key: "resolution", value: newValue)
                    }
                }
                
                Divider()
                
                HStack {
                    Text("Output Framerate")
                    Spacer()
                    Stepper("\(selectedFramerate)",
                        value: $selectedFramerate,
                        in: 0...60
                    )
                    .onChange(of: selectedFramerate) { newValue in
                       saveRecordingSetting(key: "framerate", value: newValue)
                    }
                }

                Divider()

                HStack {
                    Text("Color Format")
                    Spacer()
                    Picker("", selection: $selectedColorFormat) {
                        ForEach(colorFormats, id: \.self) { format in
                            Text("\(format)").tag(format)
                        }
                    }
                    .buttonStyle(.borderless) // Use the same button style as output resolution picker
                    .fixedSize()
                    .onChange(of: selectedColorFormat) { newValue in
                        saveRecordingSetting(key: "colorFormat", value: newValue)
                    }
                }

                Divider()

                HStack {
                    Text("Bitrate")
                    Spacer()
                    Stepper("\(selectedBitrate)",
                        value: $selectedBitrate,
                        in: 1_000_000...30_000_000,
                        step: 1_000_000
                    )
                    .onChange(of: selectedBitrate) { newValue in
                        saveRecordingSetting(key: "bitrate", value: newValue)
                    }

                }

                Divider()

                HStack {
                    Text("Encoder")
                    Spacer()
                    Picker("", selection: $selectedEncoder) {
                        ForEach(encoders, id: \.self) { encoder in
                            Text("\(encoder)").tag(encoder)
                        }
                    }
                    .buttonStyle(.borderless) // Use the same button style as output resolution picker
                    .fixedSize()
                    .onChange(of: selectedEncoder) { newValue in
                        saveRecordingSetting(key: "encoder", value: newValue)
                    }
                }
                
                Divider()
                
                HStack {
                    Text("Recording Output")
                    Spacer()
                    Text(outputDestination ?? "No Ouput Specified")
                    .foregroundStyle(.secondary)
                    .onAppear { loadSavedOutputDestination() }
                }
                
//                Divider()
                
                HStack {
                    if(outputDestination == nil) {
                        HStack(spacing: 2) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 10))
                                .symbolRenderingMode(.multicolor)
                            Text("To enable recording, you must specify a recording output destination.")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                    Button("Set Output Destination") {
                        selectOutputDestination()
                    }
                }
                
            }
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
            ._groupBox()
            .fixedSize(horizontal: false, vertical: true)
            .onAppear { loadRecordingSettings() }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
        .padding(.top, 2)
    }
    
    private func loadRecordingSettings() {
        guard let sharedDefaults = UserDefaults(suiteName: settingsDefaultsIdentifier) else { return }
        
        var recordingSettings = sharedDefaults.dictionary(forKey: "recordingSettings") as? [String: Any] ?? [:]

        // Load or initialize each setting
        selectedResolution = recordingSettings["resolution"] as? String ?? selectedResolution
        selectedFramerate = recordingSettings["framerate"] as? Int ?? selectedFramerate
        selectedColorFormat = recordingSettings["colorFormat"] as? String ?? selectedColorFormat
        selectedBitrate = recordingSettings["bitrate"] as? Int ?? selectedBitrate
        selectedEncoder = recordingSettings["encoder"] as? String ?? selectedEncoder

        // Save default values if they weren't present
        recordingSettings["resolution"] = selectedResolution
        recordingSettings["framerate"] = selectedFramerate
        recordingSettings["colorFormat"] = selectedColorFormat
        recordingSettings["bitrate"] = selectedBitrate
        recordingSettings["encoder"] = selectedEncoder

        sharedDefaults.set(recordingSettings, forKey: "recordingSettings")
        print("Recording Settings loaded successfully.")
    }
    
    private func saveRecordingSetting(key: String, value: Any) {
        guard let sharedDefaults = UserDefaults(suiteName: settingsDefaultsIdentifier) else { return }
        
        var recordingSettings = sharedDefaults.dictionary(forKey: "recordingSettings") as? [String: Any] ?? [:]
        recordingSettings[key] = value
        sharedDefaults.set(recordingSettings, forKey: "recordingSettings")
        print("Recording setting '\(key)' saved with value: \(value)")
    }
    
    private func selectOutputDestination() {
       let openPanel = NSOpenPanel()
       openPanel.canChooseDirectories = true
       openPanel.canCreateDirectories = true
       openPanel.canChooseFiles = false
       openPanel.prompt = "Select Output Folder"

       if openPanel.runModal() == .OK {
           if let url = openPanel.url {
               saveOutputDestination(url)
               outputDestination = url.path(percentEncoded: false)
               print("new output is: ", url.path(percentEncoded: false))
           }
       }
   }

   private func saveOutputDestination(_ url: URL) {
       do {
           let bookmarkData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
           
           if let sharedDefaults = UserDefaults(suiteName: settingsDefaultsIdentifier) {
               var recordingSettings = sharedDefaults.dictionary(forKey: "recordingSettings") as? [String: Any] ?? [:]
               recordingSettings["outputDestination"] = url.path
               recordingSettings["outputDestinationBookmark"] = bookmarkData
               sharedDefaults.set(recordingSettings, forKey: "recordingSettings")
           }
       } catch {
           print("Failed to create bookmark: \(error)")
       }
   }

   private func loadSavedOutputDestination() {
       print("attempting to load saved output destination")
       if let sharedDefaults = UserDefaults(suiteName: settingsDefaultsIdentifier),
          let recordingSettings = sharedDefaults.dictionary(forKey: "recordingSettings"),
          let savedPath = recordingSettings["outputDestination"] as? String {
           outputDestination = savedPath
       }
    
   }
    
}








struct SettingCard: View {
    
    var title: String
    var imageName: String
    var isSelected: Bool = false
    
    init(title: String, imageName: String, isSelected: Bool = false) {
        self.title = title
        self.imageName = imageName
        self.isSelected = isSelected
    }
    
    var body: some View {
        HStack {
            Image(systemName: imageName)
                .font(.system(size: 14))
                .padding(.leading, 6)
                .foregroundColor(.accentColor)
            
            Text(title)
                .font(.system(size: 14))
        }
        .frame(maxWidth: .infinity, minHeight: 36, maxHeight: 36, alignment: .leading)
        .background(
            isSelected
                ? AnyView(MaterialView(material: .selection))
                : AnyView(Color.clear)
        )
        .cornerRadius(6)
    }
}






struct PreferencesPanelTitlebarView: View {
    
    @ObservedObject var settings = Settings.shared
    
    var body: some View {
        HStack {
            
            HStack{
                
            }
            .frame(minWidth: 150, maxWidth: 200, maxHeight: .infinity)
            .background(MaterialView(material: .sidebar))
            
            HStack(spacing: 0) {
//                Image(systemName: "chevron.left")
//                    .font(.system(size: 18))
//                    .padding(.vertical, 5)
//                    .padding(.horizontal, 10)
//                    ._toolbarButton {
//                        print("previous setting")
//                    }
//                
//                Image(systemName: "chevron.right")
//                    .font(.system(size: 18))
//                    .padding(.vertical, 5)
//                    .padding(.horizontal, 10)
//                    ._toolbarButton {
//                        print("next setting")
//                    }
                
                Text(settings.selectedSetting.title)
                .font(.system(size: 14, weight: .bold))
                .padding(.leading, 10)
               
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(.leading, 10)
          
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)


    }
}




