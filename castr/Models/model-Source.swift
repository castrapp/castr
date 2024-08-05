//
//  model-Source.swift
//  castr
//
//  Created by Harrison Hall on 8/4/24.
//

import Foundation

class SourceModel: Identifiable, ObservableObject {
    let id: String
    let type: SourceType
    @Published var name: String { didSet { markAsModified() }}
    @Published var isActive: Bool { didSet { markAsModified() }}
    @Published var isSelected: Bool { didSet { markAsModified() }}
    @Published var lastModified: Date = Date()
    
    init(type: SourceType, id: String, name: String, isActive: Bool, isSelected: Bool) {
        self.type = type
        self.id = id
        self.name = name
        self.isActive = isActive
        self.isSelected = isSelected
    }
    
    func markAsModified() {
        lastModified = Date()
    }
}


    class ScreenCaptureSourceModel: SourceModel {
        @Published var display: String { didSet { markAsModified() }}
        @Published var excludedApps: [String] { didSet { markAsModified() }}
        
        init(type: SourceType, id: String, name: String, isActive: Bool, isSelected: Bool, display: String, excludedApps: [String]) {
            self.display = display
            self.excludedApps = excludedApps
            super.init(type: type, id: id, name: name, isActive: isActive, isSelected: isSelected)
        }
    }


    class WindowCaptureSourceModel: SourceModel {
        @Published var window: String { didSet { markAsModified() }}

        init(type: SourceType, id: String, name: String, isActive: Bool, isSelected: Bool, window: String) {
            self.window = window
            super.init(type: type, id: id, name: name, isActive: isActive, isSelected: isSelected)
        }
    }
