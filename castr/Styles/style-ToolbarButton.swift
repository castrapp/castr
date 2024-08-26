//
//  style-Toolbar.swift
//  castr
//
//  Created by Harrison Hall on 8/23/24.
//

import Foundation
import SwiftUI





struct _ToolbarButton: ViewModifier {
    
    let onPress: () -> Void
    
    @State private var isHovered = false
    
    func body(content: Content) -> some View {
        Button(action: onPress) {
            content
            .foregroundColor(isHovered ? .primary : .secondary)
            .contentShape(Rectangle())
            .background(Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
        .background(isHovered ? Color(nsColor: .quinaryLabel) : Color.clear)
        .cornerRadius(5)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

extension View {
    func _toolbarButton(
        onPress: @escaping () -> Void
    ) -> some View {
        self.modifier(_ToolbarButton(onPress: onPress))
    }
}

