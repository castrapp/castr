//
//  view-SystemAudioCapture.swift
//  castr
//
//  Created by Harrison Hall on 8/4/24.
//

import Foundation
import SwiftUI


struct SystemAudioCaptureConfiguration: View {
    
    @State var sourceName = "Audio Capture 1"
    @FocusState var isTextFieldFocused: Bool
    
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
        
        VStack(alignment: .leading, spacing: 0) {
            Text("Pick and choose which applications you would like to capture audio on.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.bottom, 10)
                .padding(.horizontal, 10)
            

            Text("Apps")
            .padding(.bottom, 8)
            .padding(.horizontal, 10)
            
            ScrollView {
                VStack(spacing: 0) {
                    SystemAudioCaptureCard(
                        title: "AdobeXD",
                        subtitle: "10 Windows",
                        isSelected: false,
                        onPress: {
                            print("pressed")
                        }
                    )
                    SystemAudioCaptureCard(
                        title: "Chrome",
                        subtitle: "7 Windows",
                        isSelected: false,
                        onPress: {
                            print("pressed")
                        }
                    )
                    SystemAudioCaptureCard(
                        title: "Safari",
                        subtitle: "4 Windows",
                        isSelected: false,
                        onPress: {
                            print("pressed")
                        }
                    )
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




struct SystemAudioCaptureCard: View {
    @State var title: String
    @State var subtitle: String
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
                    Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(Color(nsColor: NSColor.secondaryLabelColor))
                    .fixedSize()
                }
                .padding(.vertical, 4)
                
                Spacer()
                
                ZStack {
                    Circle()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color(nsColor: NSColor.quaternaryLabelColor))
                    
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
//        .onContinuousHover { phase in
//            switch phase {
//            case .active:
//                NSCursor.pointingHand.push()
//            case .ended:
//                NSCursor.pop()
//            }
//        }
    }
    
}
