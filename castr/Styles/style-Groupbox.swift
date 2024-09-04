//
//  style-GroupBox.swift
//  castr
//
//  Created by Harrison Hall on 8/22/24.
//

import Foundation
import SwiftUI

struct _GroupBox: ViewModifier {
    let padding: CGFloat
    let insets: CGFloat
    
    init(padding: CGFloat = 0, insets: CGFloat = 0) {
        self.padding = padding
        self.insets = insets
    }
    
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            content
        }
        .padding(insets)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(nsColor: .quaternarySystemFill))
//        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(nsColor: .tertiaryLabelColor), lineWidth: 0.5)
        )
        
        .padding(padding)
        
    }
}

extension View {
    func _groupBox(padding: CGFloat = 0, insets: CGFloat = 0) -> some View {
        self.modifier(_GroupBox(padding: padding, insets: insets))
    }
}
