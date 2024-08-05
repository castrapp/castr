//
//  SourceDetails.swift
//  castr
//
//  Created by Harrison Hall on 8/4/24.
//

import Foundation
import SwiftUI

struct SourceConfigurationPanel: View {
    
    @ObservedObject var sourcesState = SourcesState.shared
    @State var isHovered = false
    
    var selectedSource: SourceModel? {
        sourcesState.globalSources.first { $0.id == sourcesState.selectedSourceId }
    }
    
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
            
            
            if let source = selectedSource {
                switch source.type {
                case .screenCapture:     ScreenCaptureConfiguration()
                case .windowCapture:     WindowCaptureConfiguration()
                   // Add more cases for other source types as needed
               }
            } else {
                Text("No source selected")
            }
            
//            ScreenCaptureConfiguration()
            
//            WindowCaptureConfiguration()
            
//            SystemAudioCaptureConfiguration()
            
            
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .onChange(of: sourcesState.selectedSourceId) { newValue in
//                    print("Selected Source ID changed to: \(newValue)")
                }
    }
}


