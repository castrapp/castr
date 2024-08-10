//
//  view-WindowCapture.swift
//  castr
//
//  Created by Harrison Hall on 8/4/24.
//

import Foundation
import SwiftUI

struct WindowCaptureConfiguration: View {
    
    @ObservedObject var globalState = GlobalState.shared
    @ObservedObject var model: WindowCaptureSourceModel
    
    @FocusState var isTextFieldFocused: Bool
    @State var selectedWindow = "Option 1"
    
    let windows = ["Option 1", "Option 2", "Option 3"]
    
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
            Text("Window")

            Spacer()
            
            Picker("", selection: $selectedWindow) {
                ForEach(windows, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .labelsHidden()
            .fixedSize(horizontal: true, vertical: true)
        }
        .frame(maxWidth: .infinity, maxHeight: 30, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        
    }
}
