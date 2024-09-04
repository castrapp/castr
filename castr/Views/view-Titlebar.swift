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
    @ObservedObject var global = GlobalState.shared
    @State var sceneTitle = "No Scene Selected"
    
    var body: some View {
            HSplitView {
                leftSidebar
                main
                rightSidebar
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all)
            .onChange(of: global.selectedSceneId) { newValue in
                let newScene = global.scenes.first { $0.id == newValue }
                if let newScene = newScene {
                    sceneTitle = newScene.name
                } else {
                    sceneTitle = "No Scene Selected"
                }
               
                
            }
    }

    
    /// `Left Sidebar`
    var leftSidebar: some View {
        HStack {
            // TODO: Implement side panel collapse button and functionality
//            _Button(
//                imageName: "sidebar.left",
//                onPress: {
//                    print("pressed")
//                }
//            )
//            .padding(.leading, app.trafficLightPadding)
        }
        .frame(minWidth: 300, maxWidth: 300, maxHeight: .infinity, alignment: .leading)
        .background(MaterialView(material: .sidebar))
    }
    
    
    
    /// `Main`
    var main: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                
                
                VStack(alignment: .leading) {
                  Text(sceneTitle)
                    .fontWeight(.bold)
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
    //            Text("Number of sources")
    //                .font(.system(size: 12))
    //                .foregroundColor(.secondary)
                }
                .fixedSize()
                .padding(.leading, 10)
                
                Spacer()
                    .frame(maxWidth: .infinity)

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(BackgroundStyle.background)
            
            Spacer().frame(maxWidth: .infinity, maxHeight: 1).background(Color.black)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BackgroundStyle.background)
       
    }
    
    
    /// `Right Sidebar`
    var rightSidebar: some View {
        HStack {
            
            // TODO: Implement side panel collapse button and functionality
//            _Button(
//                imageName: "sidebar.right",
//                onPress: {
//                    print("pressed")
//                }
//            )
//            .padding(.trailing, app.defaultWindowPadding)
                        
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




