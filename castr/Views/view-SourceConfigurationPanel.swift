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
    
//    var selectedSource: SourceModel? {
//        globalState.globalSources.first { $0.id == globalState.selectedSourceId }
//    }
    
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
            
            
            if let source = globalState.sources.first{ $0.id == globalState.selectedSourceId } {
                switch source.type {
                case .screenCapture:     ScreenCaptureConfiguration(model: (source as? ScreenCaptureSourceModel)!)
                case .windowCapture:     WindowCaptureConfiguration()
                case .image:     Text("Image Configuration")
                case .color:     Text("Color Configuration")
                   // Add more cases for other source types as needed
               }
            } else {
                Text("No source selected")
            }
            
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        
        // TODO: iterate through all of the global sources and if the source type is
        // TODO: .screencapture or .windowcapture, then check if the selectedSourceId
        // TODO: is equal to the selectedSourcesId or not:
        // TODO: (This logic will need to be slightly changed at some point to make sure we don't double poll)
        //
        //  If the selectedSourceId IS EQUAL to the source's Id, then:
        //  • Call startMonitoringAvailableContent()
        //
        //  If the selectedSourceId IS NOT EQUAL to the source's Id, then:
        //  • Call stopMonitoringAvailableContent ()
        //
        // for every source of globalState.sources
//        .onChange(of: globalState.selectedSourceId) { newValue in
//            for source in globalState.sources {
//                guard source.type == .screenCapture || source.type == .windowCapture else { return }
//                if source.id == globalState.selectedSourceId {
//                    switch source {
//                    case let screenCaptureSource as ScreenCaptureSourceModel:
//                        Task { await screenCaptureSource.startMonitoringAvailableContent() }
//                    case let windowCaptureSource as WindowCaptureSourceModel:
//                        Task { await windowCaptureSource.startMonitoringAvailableContent() }
//                    default:
//                        break
//                    }
//                } else {
//                    switch source {
//                    case let screenCaptureSource as ScreenCaptureSourceModel:
//                        screenCaptureSource.stopMonitoringAvailableContent()
//                    case let windowCaptureSource as WindowCaptureSourceModel:
//                        windowCaptureSource.stopMonitoringAvailableContent()
//                    default:
//                        break
//                    }
//                }
//            }
//        }
    }
}


