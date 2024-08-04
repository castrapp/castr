//
//  toolbar.swift
//  castr
//
//  Created by Harrison Hall on 8/3/24.
//

import Foundation
import SwiftUI



struct Toolbar: View {
    
    @StateObject var layout = LayoutState.shared
    
    var body: some View {
        HStack(spacing: 0) {
            
            
            /// `Left`
            HStack(spacing: 0) {
                SidebarButton(
                    imageName: "sidebar.left",
                    onPress: {
                        print("button is pressed")
                        withAnimation(.easeInOut(duration: 0.3)) {
                            layout.isLeftPanelOpen.toggle()
                        }
                    }
                )
                .padding(.leading, 10)
            }
            .frame(maxWidth: layout.leftPanelMaxWidth, maxHeight: .infinity, alignment: .leading)
            .fixedSize(horizontal: layout.isLeftPanelOpen ? false : true, vertical: false)
//            .border(Color.red, width: 1)
            
            
            /// `Center`
            HStack(spacing: 0) {
                SidebarButton(
                    imageName: "chevron.left",
                    onPress: {
                        print("button is pressed")
                    }
                )
                .padding(.leading, 10)
                .padding(.trailing, 6)
                
                SidebarButton(
                    imageName: "chevron.right",
                    onPress: {
                        print("button is pressed")
                    }
                )
                .padding(.trailing, 10)
                
                
                VStack(alignment: .leading, spacing: 2) {
                    
                    Text("SCENE PREVIEW")
                    .font(.system(size: 10, design: .default))
                    .foregroundColor(Color(nsColor: .tertiaryLabelColor))
                    
                    Text("Scene 1")
                    .fontWeight(.bold)
                    .font(.system(size: 14))
                    
                    
                }
                
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .border(Color.red, width: 1)
            
            
            /// `Right`
            HStack(spacing: 0) {
                SidebarButton(
                    imageName: "sidebar.right",
                    onPress: {
                        print("button is pressed")
                        withAnimation(.easeInOut(duration: 0.3)) {
                            layout.isRightPanelOpen.toggle()
                        }
                    }
                )
                .padding(.trailing, 10)
            }
            .frame(maxWidth: layout.rightPanelMaxWidth, maxHeight: .infinity, alignment: .trailing)
            .fixedSize(horizontal: layout.isRightPanelOpen ? false : true, vertical: false)
//            .border(Color.orange, width: 1)
            
            
        }
        .frame(maxWidth: .infinity, maxHeight: 52, alignment: .leading)
//        .border(Color.red, width: 1)
    }
}






struct SidebarButton: View {
    
    let size: CGFloat? 
    let imageName: String
    let onPress: () -> Void
    
    @State var isHovered = false
    
    init(
        size: CGFloat? = nil,
        imageName: String,
        onPress: @escaping () -> Void
    ) {
        self.size = size
        self.imageName = imageName
        self.onPress = onPress
    }
    
    var body: some View {
        Button(action: onPress) {
            Image(systemName: imageName)
                .font(.system(size: size ?? 18))
                .foregroundColor(isHovered ? .primary : .secondary)
                .padding(5) // Padding moved here, inside the label
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(isHovered ? Color(nsColor: .quinaryLabel) : Color.clear)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
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
