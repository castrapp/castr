//
//  view-ScreenCapture.swift
//  castr
//
//  Created by Harrison Hall on 8/4/24.
//

import Foundation
import SwiftUI
import ScreenCaptureKit


struct ScreenCaptureConfiguration: View {
    @ObservedObject var model: ScreenCaptureSourceModel
    @FocusState var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            
            HStack {
                Text("Active")
                
                Spacer()
                
                Toggle(isOn: $model.isActive) {}
                .labelsHidden() // Hides the label for the Toggle
                .fixedSize(horizontal: true, vertical: true)
            }
            .frame(maxWidth: .infinity, maxHeight: 30, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            
            Spacer().panelSubSeparatorStyle()
            
            HStack {
                Text("Name")
                
                Spacer()
                
                TextField("Source Name", text: $model.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .fixedSize(horizontal: true, vertical: true)
                    .disabled(true)
                    .focused($isTextFieldFocused)
                    .onAppear {
                        DispatchQueue.main.async {
                            isTextFieldFocused = false
                        }
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: 30, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            
            Spacer().panelSubSeparatorStyle()
            
            HStack {
                Text("Display")
                
                Spacer()
                
                Picker("Display", selection: $model.selectedDisplay) {
                    ForEach(model.availableDisplays, id: \.self) { display in
                        Text(display.displayName)
                            .tag(SCDisplay?.some(display))
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
                    .padding(.horizontal, 10)
                
                Text("Apps")
                    .padding(.bottom, 8)
                    .padding(.horizontal, 10)
                
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(model.availableApps, id: \.self) { app in
                            Text(app.applicationName)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
    }
}
