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
    
    func renderTextureToCAMetalLayer(texture: MTLTexture, metalLayer: CAMetalLayer) {
        guard let drawable = metalLayer.nextDrawable() else {
            print("Failed to get CAMetalLayer drawable")
            return
        }
        guard let device = MetalService.shared.device else { return }
        let commandQueue = device.makeCommandQueue()!
        let commandBuffer = commandQueue.makeCommandBuffer()!
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0)
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        
        // Set up your rendering pipeline and shaders here
        // For simplicity, this example assumes you have a pre-configured render pipeline
//        renderEncoder.setRenderPipelineState(model.renderPipelineState)
        
        // Set the texture to the fragment shader (assuming you use slot 0)
        renderEncoder.setFragmentTexture(texture, index: 0)
        
        // Draw a full-screen quad or whatever is appropriate for your rendering
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
