//
//  style-PanelStyles.swift
//  castr
//
//  Created by Harrison Hall on 8/23/24.
//

import Foundation
import SwiftUI

struct PanelHeaderText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .fontWeight(.bold)
            .font(.system(size: 14))
            .foregroundColor(.primary)
            .padding(.leading, 10)
            .fixedSize()
    }
}


struct PanelDivider: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: 1)
            .background(Color(nsColor: .quaternarySystemFill))
            .padding(.horizontal, 10)
    }
}



struct PanelButton: ViewModifier {
    let onPress: () -> Void
    @State var isHovered = false
    
    init(
        onPress: @escaping () -> Void
    ) {
        self.onPress = onPress
    }
    
    func body(content: Content) -> some View {
        Button(action: onPress) {
            content
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(isHovered ? Color(nsColor: .quinaryLabel) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}




extension View {
    func _panelHeaderText() -> some View {
        self.modifier(PanelHeaderText())
    }
    
    func _panelDivider() -> some View {
        self.modifier(PanelDivider())
    }
    
    func _panelButton(perform action: @escaping () -> Void) -> some View {
        self.modifier(PanelButton(onPress: action ))
    }
}

