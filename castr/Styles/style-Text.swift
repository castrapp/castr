//
//  Text.swift
//  castr
//
//  Created by Harrison Hall on 8/4/24.
//

import Foundation
import SwiftUI

struct SourcesTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .fontWeight(.bold)
            .font(.system(size: 12))
            .padding(.leading, 10)
            .fixedSize()
    }
}

extension View {
    func sourcesTextStyle() -> some View {
        self.modifier(SourcesTextStyle())
    }
}
