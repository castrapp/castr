//
//  view-WindowCapture.swift
//  castr
//
//  Created by Harrison Hall on 8/4/24.
//

import Foundation
import SwiftUI


struct TextConfiguration: View {
    
    @ObservedObject var globalState = GlobalState.shared
    @ObservedObject var model: TextSourceModel
    
    @FocusState var isTextFieldFocused: Bool
    @FocusState private var isFocused: Bool
    
    var body: some View {
        
        HStack {
            Text("Name")

            Spacer()
            
            TextField("Source Name", text: $model.name)
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
        
        HStack {
            Text("Color")

            Spacer()
            
            // Insert Color Thang field here
            ColorPicker("", selection: $model.color)
            .labelsHidden()
            .fixedSize(horizontal: true, vertical: true)
           
        }
        .frame(maxWidth: .infinity, maxHeight: 30, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        
        Spacer().panelSubSeparatorStyle()
        
        HStack {
            Text("Font Size")

            Spacer()
            
            // Insert Color Thang field here
            Slider(value: $model.fontSize, in: 8...72, step: 1)
            .frame(width: 100)
            Text("\(Int(model.fontSize))")
            .frame(width: 30)
           
        }
        .frame(maxWidth: .infinity, maxHeight: 30, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        
        Spacer().panelSubSeparatorStyle()
        
        VStack(alignment: .leading) {
            Text("Text")

            Spacer()
            
            // Insert text field here
            TextEditor(text: $model.text)
            .textFieldStyle(RoundedBorderTextFieldStyle())
//            .fixedSize(horizontal: true, vertical: true)
            .focused($isFocused)
            .onSubmit {
                    print("text submitted")// Handle submission here
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 70)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        
    }
}
