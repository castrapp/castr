//
//  view-SourcesPanel.swift
//  castr
//
//  Created by Harrison Hall on 8/4/24.
//

import Foundation
import SwiftUI

struct SourcesPanel: View {
    
    @ObservedObject var globalState = GlobalState.shared
    @State var isHovered = false
    @State private var showPopover = false
    
    var body: some View {
        CustomGroupBox {
            HStack {
                Text("Sources").sourcesTextStyle()

            }
            .frame(maxWidth: .infinity, maxHeight: 30, alignment: .leading)
//            .border(Color.red, width: 1)
            .cornerRadius(5)
//            .overlay(
//                RoundedRectangle(cornerRadius: 5)
////                    .stroke(Color.red, lineWidth: 1)
//                    .fill(isHovered ? Color(nsColor: .quinaryLabel) : Color.clear)
//            )
            .padding(5)
            .onHover { hovering in
                isHovered = hovering
            }
//            .onContinuousHover { phase in
//                switch phase {
//                case .active:
//                    NSCursor.openHand.push()
//                case .ended:
//                    NSCursor.pop()
//                }
//            }
            
            Spacer().panelMainSeparatorStyle()
            
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(globalState.sources) { source in

                      
                        if source.scenes.contains(globalState.selectedSceneId) {
                            SourceCard(
                                source: source,
                                onPress: {
    //                                print("selecting source")
                                    globalState.selectedSourceId = source.id
                                }
                            )
                        }
                    }
                }
                .padding(.vertical, 10)
            }
            
            Spacer()
            
            Spacer().frame(maxWidth: .infinity, maxHeight: 1).background(Color(nsColor: .tertiaryLabelColor))
            
            HStack(spacing: 0) {
                
                SidebarButton(
                    size: 12,
                    imageName: "plus",
                    onPress: {
                        showPopover.toggle()
                        print("adding a source is pressed")
                    }
                )
                .padding(.leading, 5)
                .padding(.trailing, 4)
                .popover(isPresented: $showPopover, attachmentAnchor: .point(.bottom), arrowEdge: .bottom) {
                    VStack{
                        Button("Screen Capture Source") {
                            print("the sources count is: ", globalState.sources.count)
                            if(globalState.sources.count == 0) {
                                globalState.addSource(sourceType: .screenCapture, name: "Screen Capture Source")
                            }
                           
                            print("Adding screen capture")
                        }
                        .padding(10)
//                        Button("Window Capture Source") {
//                            globalState.addSource(sourceType: .windowCapture, name: "Window Capture Source")
//                            print("adding window capture")
//                        }
//                        Button("Video Source") {
//                            globalState.addSource(sourceType: .video, name: "Video Source")
//                            print("adding video capture")
//                        }
//                        Button("Image Source") {
//                            globalState.addSource(sourceType: .image, name: "Image Source")
//                            print("adding image source")
//                        }
//                        Button("Color Source") {
//                            globalState.addSource(sourceType: .color, name: "Color Source")
//                            print("adding color source")
//                        }
//                        Button("Text Source") {
//                            globalState.addSource(sourceType: .text, name: "Text Source")
//                            print("adding text source")
//                        }
                    }
                }
                
                Spacer().frame(maxWidth: 1, maxHeight: .infinity).background(Color(nsColor: .quinaryLabel)).padding(.vertical, 8)
                
                SidebarButton(
                    size: 12,
                    imageName: "minus",
                    onPress: {
                        print("deleting a source")
                        globalState.deleteSelectedSource()
                    }
                )
                .padding(.horizontal, 4)
                
                Spacer()
                
//                Menu("Options") {
//                    Button("Add Source") {
//                        print("option 1 has been pressed")
//                    }
//                    Button("Delete Source") {
//                        print("option 2 has been pressed")
//                    }
//                    Button("Duplicate Source") {
//                        print("option 3 has been pressed")
//                    }
//                    Button("Toggle Source On/Off") {
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
        .padding(10)
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
    }
}



struct SourceCard: View {
    @ObservedObject var globalState = GlobalState.shared
    @ObservedObject var source: SourceModel
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
                    Text(source.name)
                    .fixedSize()
                    Text(source.type.displayName)
                    .font(.subheadline)
                    .foregroundColor(Color(nsColor: NSColor.secondaryLabelColor))
                    .fixedSize()
                }
                .padding(.vertical, 4)
                
                Spacer()
               
            }
            .background(globalState.selectedSourceId == source.id ? Color(red: 42/255, green: 85/255, blue: 180/255) : (isHovered ? Color(nsColor: .quinaryLabel) : Color.clear))
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
