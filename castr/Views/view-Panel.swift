//
//  rightPanel.swift
//  castr
//
//  Created by Harrison Hall on 8/3/24.
//

import Foundation
import SwiftUI



struct CustomGroupBox<Content: View>: View {

    let content: Content
    let padding: CGFloat

    init(
        padding: CGFloat = 0,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.padding = padding
    }

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(padding)
        .background(Color(nsColor: .quaternarySystemFill))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(nsColor: .tertiaryLabelColor), lineWidth: 1)
        )


    }
}




struct CustomControlBox<Content: View>: View {
    @State var isHovered = false
    
    let title: String
    let subtitle: String
    let isSelected: Bool
    var onPress: () -> Void
    
    let content: Content
    let padding: CGFloat

    init(
        title: String,
        subtitle: String,
        isSelected: Bool,
        padding: CGFloat = 0,
        onPress: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.isSelected = isSelected
        self.padding = padding
        self.onPress = onPress
        self.content = content()
    }

    var body: some View {
        Button(action: onPress) {
            VStack(spacing: 8) {
//                content
                Image(systemName: "video.fill")
                .font(.system(size: 16))
//                .padding(.leading, 10)
                
                Text(title)
                    .font(.subheadline)
            }
            .frame(maxWidth: 75, maxHeight: 70)
            .padding(padding)
//            .background(Color(nsColor: .quaternarySystemFill))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(nsColor: .tertiaryLabelColor), lineWidth: 1)
                    .fill(isHovered ? Color(nsColor: .quaternaryLabelColor) : Color(nsColor: .quinaryLabel) )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        .onContinuousHover { phase in
            switch phase {
            case .active:
                NSCursor.pointingHand.push()
            case .ended:
                NSCursor.pop()
            }
        }
    }
}

