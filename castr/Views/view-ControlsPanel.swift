//
//  view-ControlsPanel.swift
//  castr
//
//  Created by Harrison Hall on 8/4/24.
//

import Foundation
import SwiftUI

struct ControlsPanel: View {
    
    @State var isHovered = false
    
    var body: some View {
        CustomGroupBox {
            HStack {
                Text("Controls").sourcesTextStyle()
                
                Spacer()
               
            }
            .frame(maxWidth: .infinity, maxHeight: 30, alignment: .leading)
//            .border(Color.red, width: 1)
            .cornerRadius(5)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
//                    .stroke(Color.red, lineWidth: 1)
                    .fill(isHovered ? Color(nsColor: .quinaryLabel) : Color.clear)
            )
            .padding(5)
            .onHover { hovering in
                isHovered = hovering
            }
            .onContinuousHover { phase in
                switch phase {
                case .active:
                    NSCursor.openHand.push()
                case .ended:
                    NSCursor.pop()
                }
            }
            
            Spacer().panelMainSeparatorStyle()
            
            HStack {
                CustomControlBox(
                    title: "Hello",
                    subtitle: "world",
                    isSelected: false,
                    onPress: {
                        print("selecting")
                    }
                ) {
                    Text("Hello")
                }
                
                CustomControlBox(
                    title: "Hello",
                    subtitle: "world",
                    isSelected: false,
                    onPress: {
                        print("selecting")
                    }
                ) {
                    Text("Hello")
                }
                Spacer()
            }
           
//            .frame(maxWidth: 100, maxHeight: 100, alignment: .leading)
//            .fixedSize(horizontal: true, vertical: true)
            .padding(10)
        }
        .padding(10)
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
    }
}



