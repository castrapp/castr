//
//  OutputService.swift
//  castr
//
//  Created by Harrison Hall on 8/26/24.
//

import Foundation
import Metal
import CoreMedia
import SwiftUI
import MetalKit


let defaultWidth = 3456
let defaultHeight = 2234
let canvasSize = CGSize(width: 3456, height: 2234)

// Define LayerInfo struct
struct LayerInfo {
    var layerOrigin: float2
    var layerSize: float2
    var superlayerSize: float2
}


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
    
    // Actions to do once
    var device: MTLDevice?
    var commandQueue: MTLCommandQueue?
    
    
    var pipelineState: MTLRenderPipelineState?
    var mtlTextureCache: CVMetalTextureCache?
    var renderPassDescriptor: MTLRenderPassDescriptor?
    var runOnce = false
    var layer = CAMetalLayer()
    
    init() {
        setupMetal()
    }
    

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
            outputTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { _ in
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
    
    func setupMetal() {
        print("Output Services: Starting setup.")
        
        guard let device = MTLCreateSystemDefaultDevice(),
              let library = device.makeDefaultLibrary() else {
            fatalError("Could not create Metal device or library")
        }
        self.device = device
        self.commandQueue = device.makeCommandQueue()
        
        let width = 3456
        let height = 2234
        layer.drawableSize = CGSize(width: width, height: height)
        layer.pixelFormat = .bgra8Unorm
        layer.framebufferOnly = true
        layer.device = device
        
        setupPipelineState(device: device, library: library)
        setupTextureCache(device: device)
        setupRenderPassDescriptor()

        print("Output Services: Metal setup successful.")
    }

    
    private func setupPipelineState(device: MTLDevice, library: MTLLibrary) {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertexShader2")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragmentShader2")
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError("Failed to create pipeline state: \(error)")
        }
        print("Output Services: Setup pipeline state successfully.")
    }
    
    private func setupTextureCache(device: MTLDevice) {
        CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &mtlTextureCache)
        
        print("Output Services: Setup texture cache successfully.")
    }
    
    private func setupRenderPassDescriptor() {
        renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor?.colorAttachments[0].loadAction = .clear
        renderPassDescriptor?.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        renderPassDescriptor?.colorAttachments[0].storeAction = .store
        
        print("Output Services: Setup render pass descriptor successfully.")
    }
    
    private func checkMetalStatus() -> Bool {
        guard let device = device else {
            print("Output Services: Device is not configured.")
            return false
        }
        guard let mtlTextureCache = mtlTextureCache else {
            print("Output Services: Metal Texture Cache is not configured.")
            return false
        }
        guard let commandBuffer = commandQueue?.makeCommandBuffer() else {
            print("Output Services: Commmand Buffer is not configured.")
            return false
        }
        guard let renderPassDescriptor = renderPassDescriptor else {
            print("Output Services: Render Pass Descriptor is not configured.")
            return false
        }
        guard let pipelineState = pipelineState else {
            print("Output Services: Pipeline State is not Configured.")
            return false
        }
        
        return true
        
    }

    private func updateOutput() {
     
        if checkMetalStatus() == false { return }
       
        /// `1. Get the current drawable`
        guard let drawable = layer.nextDrawable() else { fatalError("Unable to get next drawable") }
        renderPassDescriptor!.colorAttachments[0].texture = drawable.texture
    
        
        /// `2. Setup a Command Buffer and Render Encoder`
        guard let commandBuffer = commandQueue?.makeCommandBuffer() else { fatalError("Unable to create command buffer") }
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor!) else { return }
    
        
        
        /// `3. Prepare draw calls for compositing the textures`
        for source in GlobalState.shared.currentSources {
            guard let texture = source.mtlTexture else { continue }
        
            // Superlayer and sublayer properties
            guard let superlayer = source.layer.superlayer else { fatalError("no super layer available") }
            
            var layerInfo = LayerInfo(
                layerOrigin: float2(Float(source.layer.frame.origin.x), Float(source.layer.frame.origin.y)),
                layerSize: float2(Float(source.layer.frame.size.width), Float(source.layer.frame.size.height)),
                superlayerSize: float2(Float(superlayer.bounds.size.width), Float(superlayer.bounds.size.height))
            )

            // Pass the LayerInfo to the shader
            renderEncoder.setVertexBytes(&layerInfo, length: MemoryLayout<LayerInfo>.size, index: 0)

            // Pass the texture size
            var drawableSize = float2(Float(drawable.texture.width), Float(drawable.texture.height))
            renderEncoder.setVertexBytes(&drawableSize, length: MemoryLayout<float2>.size, index: 1)

            // Set the pipeline state
            renderEncoder.setRenderPipelineState(pipelineState!)

            // Bind the texture for this draw call
            renderEncoder.setFragmentTexture(texture, index: 0)

            // Issue the draw call
            renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        }
        
        
        /// `4. Send buffer drawing commands to GPU`
        // End encoding
        renderEncoder.endEncoding()
        
        // Commit commands to GPU
        commandBuffer.present(drawable)
        commandBuffer.commit()
            
            
         
        /// `5. Turn the Metal Texture into a CMSampleBuffer`
        let buffer = MetalService.mtlTextureToCMSampleBuffer(texture: drawable.texture)
        guard let buffer = buffer else { return }
        
        
        /// `6. The end. Send the buffer off to the requested outputs`
    
        if(isRecording) { videoWriter?.writeSampleBuffer(buffer) }
        
        
        if(isStreamingToVirtualCamera) {
            let pointerRef = UnsafeMutableRawPointer(Unmanaged.passRetained(buffer).toOpaque())
            guard let sinkQueue = CameraViewModel.shared.sinkQueue else { return }
            
            do { 
                try sinkQueue.enqueue(pointerRef)
            } catch {
                print("Error enqueuing: \(error)")
            }
        }

        
    }
}
