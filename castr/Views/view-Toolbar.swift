//
//  toolbar.swift
//  castr
//
//  Created by Harrison Hall on 8/3/24.
//

import Foundation
import SwiftUI



struct Toolbar: View {
    
    @StateObject var layout = GlobalState.shared
    @StateObject var globalMouse = GlobalMouseMonitor()
    @State var isMouseDownOnToolPanel: Bool = false
    @State var windowOrigin: CGPoint? = nil
    @State var mouseDownOrigin: CGPoint? = nil
    
    var body: some View {
        ZStack {
            MouseEventView (
                onMouseDown: { location in
                    isMouseDownOnToolPanel = true
                    print("mousing down on panel: ", location)
                },
                onMouseUp: {
                    isMouseDownOnToolPanel = false
                    print("mouse up")
                }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            
            
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        
            
            
        }
        .frame(maxWidth: .infinity, maxHeight: 52, alignment: .leading)
        .onChange(of: globalMouse.globalMouseLocation) { newLocation in
            
            if isMouseDownOnToolPanel == false { return }
            
            guard
                let mouseDownOrigin = mouseDownOrigin,
                let windowOrigin = windowOrigin
            else { return }
            
            let offsetX = globalMouse.globalMouseLocation.x - mouseDownOrigin.x
            let newWindowOriginX = windowOrigin.x + offsetX
            
            let offsetY = globalMouse.globalMouseLocation.y - mouseDownOrigin.y
            let newWindowOriginY = windowOrigin.y + offsetY
            

//            print("original window origin location is: ", windowOrigin.x, windowOrigin.y)
//            print("new window origin location should be: ", newWindowOriginX, newWindowOriginY)
            
            if let window = NSApp.mainWindow {
                window.setFrameOrigin(NSPoint(x: newWindowOriginX, y: newWindowOriginY))
            }
            
        }
        .onChange(of: globalMouse.isMouseDown) { newValue in
            print("value of isMouseDown has changed: ", newValue)
            if newValue == true {
                // Store the mouse down origin
                mouseDownOrigin = CGPoint(x: globalMouse.globalMouseLocation.x, y: globalMouse.globalMouseLocation.y)
                
                // Store the window origin
                if let window = NSApp.mainWindow {
                    windowOrigin = window.frame.origin
                }
            } else {
                // Reset the mouse down origin
                mouseDownOrigin = nil
                
                // Reset the window origin
                windowOrigin = nil
                
                // Reset isMouseDown on tool panel, just in case
                isMouseDownOnToolPanel = false
            }
        }
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
