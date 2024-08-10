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
    
    @ObservedObject var globalState = GlobalState.shared
    @ObservedObject var model: ScreenCaptureSourceModel
    
    @FocusState var isTextFieldFocused: Bool
    
    
    var body: some View {
        
        HStack {
            Text("Name")

            Spacer()
            
            TextField("Source Name", text: $model.name)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .fixedSize(horizontal: true, vertical: true)
            .disabled(true)
            .onAppear {
                
            }
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
                        ScreenCaptureCard(
                            model: model,
                            app: app,
                            title: app.applicationName,
//                            subtitle: "10 Windows",
                            isSelected: false,
                            onPress: {
                                if (model.excludedApps.contains(app.bundleIdentifier)) {
                                    model.excludedApps.remove(app.bundleIdentifier)
                                } else {
                                    model.excludedApps.insert(app.bundleIdentifier)
                                }
                                
                               
                                
                            }
                        )
                            
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .border(Color.red)
           
        }
        .frame(maxWidth: .infinity)
//        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        
        
        
    }
}




struct ScreenCaptureCard: View {
    var model: ScreenCaptureSourceModel
    var app: SCRunningApplication
    @State var title: String
    @State var subtitle: String?
    var isHidden: Bool {
        model.excludedApps.contains(app.bundleIdentifier)
    }
    @State var isSelected: Bool
    @State var isHovered = false
    var onPress: () -> Void
    
    var body: some View {
        Button(action: onPress) {
            HStack(spacing: 10) {
               
                if let appIcon = NSImage(named: "NSApplicationIcon") {
                        Image(nsImage: appIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 30, maxHeight: 30)
                        .padding(.leading, 5)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                    .fixedSize()
                    if let subtitle = subtitle {
                        Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(Color(nsColor: NSColor.secondaryLabelColor))
                        .fixedSize()
                    }
                }
                .padding(.vertical, 4)
                
                Spacer()
                
                ZStack {
                    Circle()
                    .frame(width: 30, height: 30)
                    .foregroundColor(
                        !isHidden ? Color(nsColor: NSColor.controlAccentColor) : Color(nsColor: NSColor.quaternaryLabelColor)
                    )
                    
                    Image(systemName: "rectangle.3.group.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .foregroundColor(.white)
                }
                .frame(maxWidth: 28, maxHeight: 28)
                .padding(.trailing, 5)
                .padding(.vertical, 5)
               
            }
            .frame(maxWidth: .infinity, maxHeight: 40)
            .frame(height: 40)
            .background(Color.clear)
            .background(isSelected ? Color(red: 42/255, green: 85/255, blue: 180/255) : (isHovered ? Color(nsColor: .quinaryLabel) : Color.clear))
//            .background(isHovered ? (isSelected ? Color(red: 42/255, green: 85/255, blue: 180/255) : Color(nsColor: .quinaryLabel)) : (isSelected ?  Color(red: 42/255, green: 85/255, blue: 180/255) : Color.clear))
        
            .cornerRadius(6)
            .padding(.horizontal, 5)
    
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
//            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
//            }
        }
        .onContinuousHover { phase in
            switch phase {
            case .active:
                NSCursor.pointingHand.push()
            case .ended:
                NSCursor.pop()
            }
        }
    }
    
}
