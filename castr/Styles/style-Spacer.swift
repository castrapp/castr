//
//  style-Spacer.swift
//  castr
//
//  Created by Harrison Hall on 8/4/24.
//

import Foundation
import SwiftUI

struct PanelMainSeparatorStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: 1)
            .background(Color(nsColor: .quaternaryLabelColor))
            .padding(.horizontal, 10)
    }
}

struct PanelSubSeparatorStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: 1)
            .background(Color(nsColor: .quinaryLabel))
            .padding(.horizontal, 10)
    }
}

struct VerticalBlackStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: 1, maxHeight: .infinity)
            .background(Color.black)
    }
}

struct ToolbarPanelLineStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: 1)
            .background(Color(nsColor: .quinaryLabel))
            .padding(.top, 52)
    }
}

    

extension View {
    func panelMainSeparatorStyle() -> some View {
        self.modifier(PanelMainSeparatorStyle())
    }
    func panelSubSeparatorStyle() -> some View {
        self.modifier(PanelSubSeparatorStyle())
    }
    func verticalBlackStyle() -> some View {
        self.modifier(VerticalBlackStyle())
    }
    func toolbarPanelLineStyle() -> some View {
        self.modifier(ToolbarPanelLineStyle())
    }
}
