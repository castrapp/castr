//
//  view-Preferences.swift
//  castr
//
//  Created by Harrison Hall on 8/22/24.
//

import Foundation
import SwiftUI



struct PreferencesView: View {
    
    @State var text: String = ""
    @ObservedObject var settings = Settings.shared
    
    var body: some View {
        HSplitView {
            
            VStack(spacing: 0) {
                TextField("Placeholder", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disabled(true)
                .padding(.bottom, 10)
                
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
                    case .permissions:      PermissionsView
                    case .virtualCamera:    VirtualCameraView
                    case .recording:        RecordingView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .clipped()

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
//
    }
    
    
    /// `Virtual Camera Settings`
    var VirtualCameraView: some View {
        VStack(spacing: 0) {
            
            Text(settings.virtualCamera_modelName)
                .font(.system(size: 16, weight: .bold))
                .padding(.top, 50)
            
            Text(settings.virtualCamera_extensionBundleIdentifier)
                .font(.system(size: 14))
                .padding(.top, 10)
                .padding(.bottom, 20)
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Model Name")
                    Spacer()
                    Text(settings.virtualCamera_modelName)
                    .foregroundStyle(.secondary)
                }
                
                Divider()
                
                HStack {
                    Text("Extension Bundle Identifier")
                    Spacer()
                    Text(settings.virtualCamera_extensionBundleIdentifier)
                    .foregroundStyle(.secondary)
                }
                
                Divider()
                
                HStack {
                    Text("Status")
                    Spacer()
                    Text(settings.virtualCamera_status ? "Connected" : "Not Connected")
                    .foregroundStyle(.secondary)
                }
                
                Divider()
                
                HStack {
                    Text("Framerate")
                    Spacer()
                    Text(String(settings.virtualCamera_framerate))
                    .foregroundStyle(.secondary)
                }
                
                Divider()
                
                HStack {
                    Text("Output Resolution")
                    Spacer()
                    Text(settings.virtualCamera_outputResolution)
                    .foregroundStyle(.secondary)
                }
                
                Divider()
                
                HStack {
                    Text("Installed")
                    Spacer()
                    Text(settings.virtualCamera_installed ? "Yes" : "no")
                    .foregroundStyle(.secondary)
                }
                
                Divider()
                
                HStack {
                    Spacer()
                    Button("Uninstall") {}
                    Button("Install") {}
                }
              
            }
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
            ._groupBox()
            .fixedSize(horizontal: false, vertical: true)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
        .padding(.top, 2)
    }
    
    
    
    
    /// `Permissions Settings`
    var PermissionsView: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            Text("Castr requires your permission to be able to provide certain features. It is recommended to enable these permissions. but they are not required to use the app. You can always enable them later.")
            .font(.system(size: 12))
            .foregroundColor(.secondary)
            .padding(.leading, 10)
            
            ScreenRecordingView.padding(.vertical, 20)
            CameraView.padding(.vertical, 20)
            MicrophoneView.padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
        .padding(.top, 2)
    }
    
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
                Text("Yes")
            }
            
            Divider()
            
            HStack {
                Spacer()
                Button("Request Permission") {}
                Button("Change Permission") {}
            }
        }
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
        ._groupBox()
        .fixedSize(horizontal: false, vertical: true)
       
    }
    
    
    
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
                Text("Yes")
            }
            
            Divider()
            
            HStack {
                Spacer()
                Button("Request Permission") {}
                Button("Change Permission") {}
            }
        }
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
        ._groupBox()
        .fixedSize(horizontal: false, vertical: true)
       
    }
    
    
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
                Text("Yes")
            }
            
            Divider()
            
            HStack {
                Spacer()
                Button("Request Permission") {}
                Button("Change Permission") {}
            }
        }
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
        ._groupBox()
        .fixedSize(horizontal: false, vertical: true)
    }
    
    
    
    
    
    
    /// `Recording Settings`
    var RecordingView: some View {
        VStack(spacing: 0) {
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Recording Output")
                    Spacer()
                    Text("Desktop")
                    .foregroundStyle(.secondary)
                }
                
                Divider()
                
                HStack {
                    Text("Output Resolution")
                    Spacer()
                    Text("1728x1117")
                    .foregroundStyle(.secondary)
                }
                
                Divider()
                
                HStack {
                    Text("Output Framerate")
                    Spacer()
                    Text("30 FPS")
                    .foregroundStyle(.secondary)
                }
              
                Divider()
                
                HStack {
                    Text("Color Format")
                    Spacer()
                    Text("BGRA")
                    .foregroundStyle(.secondary)
                }
                
                Divider()
                
                HStack {
                    Text("Bitrate")
                    Spacer()
                    Text("15 mbps")
                    .foregroundStyle(.secondary)
                }
                
                Divider()
                
                HStack {
                    Text("Encoder")
                    Spacer()
                    Text("h264")
                    .foregroundStyle(.secondary)
                }
            }
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
            ._groupBox()
            .fixedSize(horizontal: false, vertical: true)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
        .padding(.top, 2)
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
                Image(systemName: "chevron.left")
                    .font(.system(size: 18))
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    ._toolbarButton {
                        print("previous setting")
                    }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 18))
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    ._toolbarButton {
                        print("next setting")
                    }
                
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




