//
//  SourcesPanel.swift
//  castr
//
//  Created by Harrison Hall on 8/3/24.
//

import Foundation
import SwiftUI


struct ScenesPanel: View {
    
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
                    SceneCard(
                        title: "Scene 1",
                        subtitle: "7 sources",
                        isSelected: false,
                        onPress: {
                            print("pressed")
                        }
                    )
                    SceneCard(
                        title: "Scene 2",
                        subtitle: "4 sources",
                        isSelected: false,
                        onPress: {
                            print("pressed")
                        }
                    )
                    SceneCard(
                        title: "Scene 3",
                        subtitle: "0 sources",
                        isSelected: true,
                        onPress: {
                            print("pressed")
                        }
                    )
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
                        print("button is pressed")
                    }
                )
                .padding(.horizontal, 4)
                
                Spacer().frame(maxWidth: 1, maxHeight: .infinity).background(Color(nsColor: .quinaryLabel)).padding(.vertical, 8)
                
                SidebarButton(
                    size: 12,
                    imageName: "minus",
                    onPress: {
                        print("button is pressed")
                    }
                )
                .padding(.horizontal, 4)
                
                Spacer()
                
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
    @State var title: String
    @State var subtitle: String
    @State var isSelected: Bool
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
                    Text(title)
                    .fixedSize()
                    Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(Color(nsColor: NSColor.secondaryLabelColor))
                    .fixedSize()
                }
                .padding(.vertical, 4)
                
                Spacer()
               
            }
            .background(isSelected ? Color(red: 42/255, green: 85/255, blue: 180/255) : (isHovered ? Color(nsColor: .quinaryLabel) : Color.clear))
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


