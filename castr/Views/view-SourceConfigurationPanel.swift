//
//  SourceDetails.swift
//  castr
//
//  Created by Harrison Hall on 8/4/24.
//

import Foundation
import SwiftUI

struct SourceConfigurationPanel: View {
    
    @State var isHovered = false
    
    var body: some View {
        CustomGroupBox {
            HStack {
                Text("Source Details").sourcesTextStyle()

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
            
            
            MacOSScreenCaptureConfiguration()
            
            
        }
        .padding(10)
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
    }
}






struct MacOSScreenCaptureConfiguration: View {
    
    @State var sourceName = "Screen Capture 1"
    @FocusState var isTextFieldFocused: Bool
    @State var selectedDisplay = "Option 1"
    
    let displays = ["Option 1", "Option 2", "Option 3"]
    
    var body: some View {
        
        HStack {
            Text("Name")

            Spacer()
            
            TextField("Source Name", text: $sourceName)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .fixedSize(horizontal: true, vertical: true)
            .disabled(true)
//            .focused($isTextFieldFocused)
//            .onAppear {
//                DispatchQueue.main.async {
//                    isTextFieldFocused = false
//                }
//            }
        }
        .frame(maxWidth: .infinity, maxHeight: 30, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
//        .border(Color.red, width: 1)
        
        Spacer().panelSubSeparatorStyle()
        
        HStack {
            Text("Display")

            Spacer()
            
            Picker("", selection: $selectedDisplay) {
                ForEach(displays, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .labelsHidden()
            .fixedSize(horizontal: true, vertical: true)
        }
        .frame(maxWidth: .infinity, maxHeight: 30, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        
        Spacer().panelSubSeparatorStyle()
        
        VStack(alignment: .leading, spacing: 0) {
            Text("Pick and choose which applications and windows you would like to display.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.bottom, 10)
            

            Text("Apps")
            .padding(.bottom, 8)
            
            ScrollView {
                VStack {
//                    Text("Hello")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .border(Color.red)
           
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        
        
        
    }
}
