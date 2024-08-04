//
//  view-SourcesPanel.swift
//  castr
//
//  Created by Harrison Hall on 8/4/24.
//

import Foundation
import SwiftUI

struct SourcesPanel: View {
    
    @State var isHovered = false
    
    var body: some View {
        CustomGroupBox {
            HStack {
                Text("Sources").sourcesTextStyle()

            }
            .frame(maxWidth: .infinity, maxHeight: 30, alignment: .leading)
//            .border(Color.red, width: 1)
            .cornerRadius(5)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
//                    .stroke(Color.red, lineWidth: 1)
                    .fill(isHovered ? Color(nsColor: .quinaryLabel) : Color.clear)
            )
            .padding(5)
            .onHover { hovering in
                isHovered = hovering
            }
            .onContinuousHover { phase in
                switch phase {
                case .active:
                    NSCursor.openHand.push()
                case .ended:
                    NSCursor.pop()
                }
            }
            
            Spacer().panelMainSeparatorStyle()
        }
        .padding(10)
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
    }
}

