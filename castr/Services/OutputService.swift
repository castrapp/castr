//
//  OutputService.swift
//  castr
//
//  Created by Harrison Hall on 8/26/24.
//

import Foundation
import Metal
import CoreMedia


let defaultWidth = 3456
let defaultHeight = 2234
class OutputService: ObservableObject {

    static let shared = OutputService()

    @Published var isRecording = false { didSet {
        isRecording ? startRecorderService() : stopRecorderService()
        handleOutputStateChange()
    } }
    @Published var isStreamingToVirtualCamera = false { didSet { handleOutputStateChange() } }
    var outputTimer: Timer?
    var videoWriter: VideoWriter?
    var buffer: CMSampleBuffer?
    

    private func handleOutputStateChange() {
        if isRecording || isStreamingToVirtualCamera {
            startOutput()
        } else {
            stopOutput()
        }
    }

    private func startOutput() {
        
        // Ensure the timer isn't already running
        if outputTimer == nil {
            print("Starting Output Timer")
            outputTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { _ in
                self.updateOutput()
            }
        }
    }

    private func stopOutput() {
        outputTimer?.invalidate()
        outputTimer = nil
        print("Stopping Output Timer")
    }
    
    private func startRecorderService() {
        print("Starting recorder service")
        videoWriter = VideoWriter()
        videoWriter?.setupDefaultSaveLocation()
        videoWriter?.setupAssetWriter(width: defaultWidth, height: defaultHeight)
        videoWriter?.startWriting {
            print("Writing started")
        }
    }
    
    private func stopRecorderService() {
        print("Stopping recorder service")
        videoWriter?.finishWriting {
            print("Writing started")
        }
    }

    private func updateOutput() {
        // Your logic to handle the output per frame
        
        
//        print("Output Service: Current sources are: ", GlobalState.shared.currentSources)
        
        // TODO: If isRecording is enabled
       
            for source in GlobalState.shared.currentSources {
                guard let texture = source.mtlTexture else { return }
                let buffer = MetalService.mtlTextureToCMSampleBuffer(texture: texture)
                
                guard let buffer = buffer else { return }
                
                print("buffer created. Attempting to writing it out.")
                if(isRecording) {
                    videoWriter?.writeSampleBuffer(buffer)
                }
                
                if(isStreamingToVirtualCamera) {
                    let pointerRef = UnsafeMutableRawPointer(Unmanaged.passRetained(buffer).toOpaque())
                    guard let sinkQueue = CameraViewModel.shared.sinkQueue else { return }
                    do {
                        try sinkQueue.enqueue(pointerRef)
                        print("Successfully enqueued")
                    } catch {
                        print("Error enqueuing: \(error)")
                    }
                }
                
//                print("the sources metal texture is: ", source.mtlTexture)
            }
//            print("Recording")
        }
    
    
    
        // TODO: Implement Texture Compositing
    
        // 1. Somehow need ot iterate through all the sources and get their mtlTexture property
        // and then composite all their texutres into 1, layer them all on top of each other
        // in the order they are in for the GlobalState.shared.currentSources, with the first
        // one being the top most one.
        
        
        // 2. Convert the texture to CMSampleBuffer
        
        
        
        // 3. Send the texture off to wherever (ie. Recording, Virtual Camera)

    private func createCompositeTexture(from sources: [SourceModel]) -> MTLTexture? {
        guard let firstSource = sources.first,
              let device = firstSource.mtlTexture?.device else { return nil }
        
        // Create a texture descriptor for the composite texture
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .bgra8Unorm,
            width: firstSource.mtlTexture!.width,
            height: firstSource.mtlTexture!.height,
            mipmapped: false
        )
        
        descriptor.usage = [.renderTarget, .shaderRead]
        guard let compositeTexture = device.makeTexture(descriptor: descriptor) else { return nil }
        
        // Create a command buffer and a render pass descriptor
        guard let commandQueue = device.makeCommandQueue(),
              let commandBuffer = commandQueue.makeCommandBuffer() else { return nil }
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        
        renderPassDescriptor.colorAttachments[0].texture = compositeTexture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 0)
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return nil }
        
        // Render each texture onto the composite texture
        for source in sources.reversed() {
            guard let texture = source.mtlTexture else { continue }
            
            renderEncoder.setFragmentTexture(texture, index: 0)
            // Setup appropriate vertex buffers, shaders, etc., here
            // Render the texture
            renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        }
        
        renderEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        return compositeTexture
    }
        
    
}
