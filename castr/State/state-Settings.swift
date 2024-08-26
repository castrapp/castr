//
//  model-Preferences.swift
//  castr
//
//  Created by Harrison Hall on 8/22/24.
//

import Foundation
import Combine

class Settings: ObservableObject {
    
    static let shared = Settings()
    
    private init() {}
    
    @Published var selectedSetting: SettingsEnum = .permissions

    
    /// `Permission Settings`
    @Published var permission_screenRecording: Bool = false
    @Published var permission_camera: Bool = false
    @Published var permission_microphone: Bool = false
    
    
    /// `Virtual Camera Settings`
    @Published var virtualCamera_modelName: String = "Castr Virtual Camera"
    @Published var virtualCamera_extensionBundleIdentifier: String = "harrisonhall.castr.virtualcamera"
    @Published var virtualCamera_status: Bool = true
    @Published var virtualCamera_framerate: Int = 30
    @Published var virtualCamera_outputResolution: String = "1728x1117"
    @Published var virtualCamera_installed: Bool = true
}



enum SettingsEnum: String, CaseIterable {
    case permissions = "Permissions"
//    case video = "Video"
//    case audio = "Audio"
    case virtualCamera = "Virtual Camera"
    case recording = "Recording"
//    case streaming = "Streaming"
    
    var title: String {
        self.rawValue
    }
    
    var imageName: String {
        switch self {
        case .permissions:      return "key.horizontal"
//        case .video:            return ""
//        case .audio:            return ""
        case .virtualCamera:    return "video"
        case .recording:        return "rectangle.inset.filled.badge.record"
//        case .streaming:        return ""
        }
    }
}
