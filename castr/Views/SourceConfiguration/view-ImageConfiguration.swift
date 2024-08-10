//
//  view-WindowCapture.swift
//  castr
//
//  Created by Harrison Hall on 8/4/24.
//

import Foundation
import SwiftUI


struct ImageConfiguration: View {
    @ObservedObject var globalState = GlobalState.shared
    @ObservedObject var model: ImageSourceModel
    
    @State private var isImagePickerPresented = false
    @State private var selectedImagePath: String = ""
    @State private var selectedImage: NSImage?
    
    var body: some View {
        VStack {
            HStack {
                Text("Name")
                Spacer()
                TextField("Source Name", text: $model.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .fixedSize(horizontal: true, vertical: true)
                    .disabled(true)
            }
            .frame(maxWidth: .infinity, maxHeight: 30, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            
            Spacer().panelSubSeparatorStyle()
            
            HStack {
                Text("Image")
                Spacer()
                Button("Choose Image") {
                    isImagePickerPresented = true
                }
                Text(selectedImagePath)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            .frame(maxWidth: .infinity, maxHeight: 30, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
        }
        .fileImporter(
            isPresented: $isImagePickerPresented,
            allowedContentTypes: [.image],
            allowsMultipleSelection: false
        ) { result in
            do {
               let selectedFile: URL = try result.get().first!
               if selectedFile.startAccessingSecurityScopedResource() {
                   defer { selectedFile.stopAccessingSecurityScopedResource() }
                   
                   if let imageData = try? Data(contentsOf: selectedFile),
                      let image = NSImage(data: imageData) {
                       model.image = image
                       print("image is: ", image)
//                                   saveImageToDocuments(imageData, fileName: selectedFile.lastPathComponent)
                   }
               }
           } catch {
               print("Error selecting file: \(error.localizedDescription)")
           }
        }
    }
}
