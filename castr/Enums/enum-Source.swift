//
//  enum-Source.swift
//  castr
//
//  Created by Harrison Hall on 8/4/24.
//

import Foundation

enum SourceType: String {
    case screenCapture
    case windowCapture
    case video
    case image
    case color
    case text
    
    var displayName: String {
        switch self {
            case .screenCapture: return "Screen Capture Source"
            case .windowCapture: return "Window Capture Source"
            case .video: return "Video Source"
            case .image: return "Image Source"
            case .color: return "Color Source"
            case .text: return "Text Source"
        }
    }
    
    var imageName: String {
        switch self {
            case .screenCapture: return "rectangle.inset.filled.badge.record"
            case .windowCapture: return "macwindow"
            case .video: return "video"
            case .image: return "photo"
            case .color: return "paintbrush"
            case .text: return "character.cursor.ibeam"
        }
    }
}




enum AddSourceOption: String, CaseIterable {
    case newSource
    case existingSource
    
    var displayName: String {
        switch self {
            case .newSource: return "Add New"
            case .existingSource: return "Choose Existing"
        }
    }
}
