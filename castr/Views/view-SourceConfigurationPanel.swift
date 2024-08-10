//
//  SourceDetails.swift
//  castr
//
//  Created by Harrison Hall on 8/4/24.
//

import Foundation
import SwiftUI

struct SourceConfigurationPanel: View {
    
    @ObservedObject var globalState = GlobalState.shared
    @State var isHovered = false
    
    
    var body: some View {
        CustomGroupBox {
            HStack {
                Text("Source Configuration").sourcesTextStyle()

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
            
            
            if let source = globalState.sources.first { $0.id == globalState.selectedSourceId } {
                switch source.type {
                case .screenCapture:     ScreenCaptureConfiguration(model: (source as? ScreenCaptureSourceModel)!)
                case .windowCapture:     WindowCaptureConfiguration(model: (source as? WindowCaptureSourceModel)!)
                case .image:     ImageConfiguration(model: (source as? ImageSourceModel)!)
                case .color:     ColorConfiguration(model: (source as? ColorSourceModel)!)
                case .text:     TextConfiguration(model: (source as? TextSourceModel)!)
                   // Add more cases for other source types as needed
               }
            } else {
                Text("No source selected")
            }
            
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        
    }
}


