//
//  enum-Source.swift
//  castr
//
//  Created by Harrison Hall on 8/4/24.
//

import Foundation
import SwiftUI


enum SourceType: String {
    case screenCapture
    case windowCapture
    case video
    case image
    case color
    case text
    
    
    var name: String {
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
    
    func imageThumbnail(active: Bool) -> some View {
        switch self {
            case .screenCapture: return AnyView (
                ZStack {
                    Circle()
                    .fill(active ? Color.accentColor : Color.secondary )
                    
                    Image(systemName: "rectangle.inset.filled.badge.record")
                    .font(.system(size: 14))
                }
                .frame(minWidth: 30, maxWidth: 30, minHeight: 30, maxHeight: 30)
            )
            case .windowCapture: return AnyView (
                ZStack {
                    Circle()
                    .fill(active ? Color.accentColor : Color.secondary )
                    
                    Image(systemName: "menubar.dock.rectangle.badge.record")
                    .font(.system(size: 14))
                }
                .frame(minWidth: 30, maxWidth: 30, minHeight: 30, maxHeight: 30)
            )
            case .video: return AnyView (
                Image(systemName: "video.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.primary, Color.accentColor)
                    .frame(minWidth: 30, maxWidth: 30, minHeight: 30, maxHeight: 30)
                    
            )
            case .image: return AnyView (
                Image(systemName: "photo.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.primary, Color.accentColor)
                    .frame(minWidth: 30, maxWidth: 30, minHeight: 30, maxHeight: 30)
            )
            case .color: return AnyView (
                ZStack {
                    Circle()
                    .fill(active ? Color.accentColor : Color.secondary )
                    
                    Image(systemName: "paintbrush.pointed.fill")
                    .font(.system(size: 14))
                }
                .frame(minWidth: 30, maxWidth: 30, minHeight: 30, maxHeight: 30)
            )
            case .text:return AnyView (
                ZStack {
                    Circle()
                    .fill(active ? Color.accentColor : Color.secondary )
                    
                    Image(systemName: "character.cursor.ibeam")
                    .font(.system(size: 14))
                }
                .frame(minWidth: 30, maxWidth: 30, minHeight: 30, maxHeight: 30)
            )
        }
    }
}




enum AddSourceOption: String, CaseIterable {
    case newSource
    // TODO: Implement "Choose Existing"
//    case existingSource
    
    var displayName: String {
        switch self {
            case .newSource: return "Add New"
//            case .existingSource: return "Choose Existing"
        }
    }
}
