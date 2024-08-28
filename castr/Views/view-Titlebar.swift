//
//  view-Titlebar.swift
//  castr
//
//  Created by Harrison Hall on 8/16/24.
//

import Foundation
import SwiftUI


struct TitlebarView: View {
    @ObservedObject var app = App.shared
    @State private var flipped = false
    
    var body: some View {
            HSplitView {
                leftSidebar
                main
                rightSidebar
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all)
    }

    
    /// `Left Sidebar`
    var leftSidebar: some View {
        HStack {
            
            _Button(
                imageName: "sidebar.left",
                onPress: {
                    print("pressed")
                }
            )
            .padding(.leading, app.trafficLightPadding)
        }
        .frame(minWidth: 300, maxWidth: 300, maxHeight: .infinity, alignment: .leading)
        .background(MaterialView(material: .sidebar))
    }
    
    
    
    /// `Main`
    var main: some View {
        HStack {
            Spacer()
            Button("flip text") {
                flipped.toggle()
            }
            
            Text("Middle")
                .padding(.trailing)
                .font(.system(size: 16))
                .rotation3DEffect(
                    .degrees(flipped ? -90 : 0),
                    axis: (x: 1, y: 0, z: 0)
//                        perspective: 0.5
                )
                .animation(.easeInOut(duration: 1), value: flipped)
                .offset(x: 0, y: flipped ? 10 : 0)
            
//            HStack {
//                Spacer()
//                
//            }
//            .frame(maxWidth: 1132, maxHeight: 22)
////            .border(Color.red)
//            .background(
//                RoundedRectangle(cornerRadius: 6)
//                    .fill(WindowBackgroundShapeStyle.windowBackground)
//            )
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BackgroundStyle.background)
    }
    
    
    /// `Right Sidebar`
    var rightSidebar: some View {
        HStack {
            
            _Button(
                imageName: "sidebar.right",
                onPress: {
                    print("pressed")
                }
            )
            .padding(.trailing, app.defaultWindowPadding)
                        
        }
        .frame(minWidth: 300, maxWidth: 300, maxHeight: .infinity, alignment: .trailing)
        .background(MaterialView(material: .sidebar))
    }
    
    
    
}



struct _Button: View {
    
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
                .padding(5)
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
        
    }
}




