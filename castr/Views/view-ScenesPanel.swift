//
//  SourcesPanel.swift
//  castr
//
//  Created by Harrison Hall on 8/3/24.
//

import Foundation
import SwiftUI


struct ScenesPanel: View {
    
    @ObservedObject var globalState = GlobalState.shared
    
    var body: some View {
        
        CustomGroupBox {
            HStack {
                Text("Scenes").sourcesTextStyle()

            }
            .frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
            
            Spacer().panelMainSeparatorStyle()
//                    .border(Color.red, width: 1)
            
            
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(globalState.scenes) { scene in
                        SceneCard(
                            scene: scene,
                            onPress: {
                                print("pressed")
                                globalState.selectedSceneId = scene.id
                            }
                        )
                    }
                }
                .padding(.vertical, 10)
                
            }
//            .border(Color.red, width: 1)
           
            
            Spacer().frame(maxWidth: .infinity, maxHeight: 1).background(Color(nsColor: .tertiaryLabelColor))
            
            HStack(spacing: 0) {
                SidebarButton(
                    size: 12,
                    imageName: "plus",
                    onPress: {
                        if(globalState.scenes.count == 0) {
                            globalState.addScene(name: "")
                        }
                        print("adding a scene")
                    }
                )
                .padding(.leading, 5)
                .padding(.trailing, 4)
                
                Spacer().frame(maxWidth: 1, maxHeight: .infinity).background(Color(nsColor: .quinaryLabel)).padding(.vertical, 8)
                
                SidebarButton(
                    size: 12,
                    imageName: "minus",
                    onPress: {
                        globalState.deleteSelectedScene()
                        print("deleting a scene")
                    }
                )
                .padding(.horizontal, 4)
                
                Spacer()
                
//                Menu("Options") {
//                    Button("Add Scene") {
//                        print("option 1 has been pressed")
//                    }
//                    Button("Delete Scene") {
//                        print("option 2 has been pressed")
//                    }
//                    Button("Duplicate Scene") {
//                        print("option 3 has been pressed")
//                    }
//                    Button("Set as Active Scene") {
//                        print("option 4 has been pressed")
//                    }
//                }
//                .fixedSize(horizontal: true, vertical: true)
//                .padding(.trailing, 5)
                
            }
            .frame(maxWidth: .infinity, maxHeight: 32, alignment: .leading)
//            .border(Color.red, width: 1)
            .background(WindowBackgroundShapeStyle.windowBackground.opacity(0.5))
            
        }
//                .border(Color.red, width: 1)
        .padding(10)
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
       
    }
}



struct SceneCard: View {
    @ObservedObject var globalState = GlobalState.shared
    @ObservedObject var scene: SceneModel
    @State var isHovered = false
    var onPress: () -> Void
    
    var body: some View {
        Button(action: onPress) {
            HStack(spacing: 10) {
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
                .frame(maxWidth: 30, maxHeight: 30)
                .padding(.leading, 5)
                .padding(.vertical, 5)

                
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(scene.name)
                    .fixedSize()
                    Text("\(scene.sources.count) Sources")
                    .font(.subheadline)
                    .foregroundColor(Color(nsColor: NSColor.secondaryLabelColor))
                    .fixedSize()
                }
                .padding(.vertical, 4)
                
                Spacer()
               
            }
            .background(scene.id == globalState.selectedSceneId ? Color(red: 42/255, green: 85/255, blue: 180/255) : (isHovered ? Color(nsColor: .quinaryLabel) : Color.clear))
//            .background(isHovered ? (isSelected ? Color(red: 42/255, green: 85/255, blue: 180/255) : Color(nsColor: .quinaryLabel)) : (isSelected ?  Color(red: 42/255, green: 85/255, blue: 180/255) : Color.clear))
            .frame(maxWidth: .infinity, maxHeight: 100)
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


