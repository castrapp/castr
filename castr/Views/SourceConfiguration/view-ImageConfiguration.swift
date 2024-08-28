//
//  view-WindowCapture.swift
//  castr
//
//  Created by Harrison Hall on 8/4/24.
//

import Foundation
import SwiftUI
import MetalKit

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
                    
                    // Load the texture using MetalKit
                    do {
                        let newTexture = try loadTextureUsingMetalKit(url: selectedFile, device: device)
                        model.mtlTexture = newTexture
                        print("New Texture is: ", newTexture)
                    } catch {
                        print("Failed to load texture: \(error.localizedDescription)")
                    }
                }
            } catch {
                print("Error selecting file: \(error.localizedDescription)")
            }
        }
    }
    
    func loadTextureUsingMetalKit(url: URL, device: MTLDevice) throws -> MTLTexture {
           let loader = MTKTextureLoader(device: device)
           return try loader.newTexture(URL: url, options: nil)
   }
    

}
