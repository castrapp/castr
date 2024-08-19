//
//  ContentView.swift
//  castr
//
//  Created by Harrison Hall on 8/3/24.
//

import Foundation
import SwiftUI

struct ContentView: View {
    
    @StateObject var layout = GlobalState.shared
    @ObservedObject var global = GlobalState.shared
    
    var body: some View {
        HStack(spacing: 0) {
            
            /// `Left Side Panel`
            HStack {
                VStack {
                    
//                    Spacer().toolbarPanelLineStyle()
                    
                    ScenesPanel()
                    
                    SourcesPanel()
                    
                    Toggle("Toggle Switch", isOn: $global.delayFrames)
//                    ControlsPanel()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity,  alignment: .top)
                
                Spacer().verticalBlackStyle()
                
            }
            .frame(maxWidth: layout.isLeftPanelOpen ? layout.leftPanelMaxWidth : 0, maxHeight: .infinity)
            .background(.ultraThickMaterial)
            .clipped()
            
            
            
            
            /// `Main Panel`
            VStack(spacing: 0) {
                
//                Spacer().frame(maxWidth: .infinity, maxHeight: 52).background(.windowBackground.opacity(0.85))
//                
//                Spacer().frame(maxWidth: .infinity, maxHeight: 1).background(Color.black)
                
                Spacer()
                
                PreviewPanel()
                
                Spacer()
                
//                Spacer().frame(maxWidth: .infinity, maxHeight: 1).background(Color.black)
                
//                HStack(spacing: 20) {
//                    Text("Virtual Camera Name")
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//                    .padding(.leading, 10)
//                    
//                    Text("Status")
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//                    
//                    Spacer()
//                    
//                    Text("30 / 30 FPS")
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//                    
//                    Text("1920 x 1080")
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//                    .padding(.trailing, 10)
//                    
//                }
//                .frame(maxWidth: .infinity, maxHeight: 30).background(.windowBackground.opacity(0.85))
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .border(Color.red, width: 1)
            .background(.ultraThinMaterial)
            
            
            
            
          
            /// `Right Side Panel`
            HStack {
                
                Spacer().verticalBlackStyle()
                
                VStack {
//                    Spacer().toolbarPanelLineStyle()
                    
                    SourceConfigurationPanel()
                    
                }
                .frame(maxWidth: .infinity, alignment: .top)
               
            }
            .frame(maxWidth: layout.isRightPanelOpen ? layout.rightPanelMaxWidth : 0, maxHeight: .infinity)
            .background(.ultraThickMaterial)
            .clipped()
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .border(Color.red, width: 1)
//        .overlay(alignment: .top) {
//            Toolbar()
//        
//        }
//        .ignoresSafeArea()
        
    }
}
