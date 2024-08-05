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
    
    var displayName: String {
        switch self {
            case .screenCapture: return "Screen Capture Source"
            case .windowCapture: return "Window Capture Source"
        }
    }
}
