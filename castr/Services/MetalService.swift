//
//  MetalState.swift
//  CaptureSample
//
//  Created by Harrison Hall on 8/20/24.
//  Copyright © 2024 Apple. All rights reserved.
//

import Foundation
import SwiftUI
import Metal
import QuartzCore
import Cocoa
import MetalKit
import AVFAudio
import ScreenCaptureKit
import CoreVideo


var videoTexture: MTLTexture?

class MetalService: ObservableObject {
    
    static let shared = MetalService()
    
    var pipelineState: MTLRenderPipelineState? { didSet { updateMetalServiceStatus() } }
    var device: MTLDevice? { didSet { updateMetalServiceStatus() } }
    var commandQueue: MTLCommandQueue? { didSet { updateMetalServiceStatus() } }
    var mtlTextureCache: CVMetalTextureCache? { didSet { updateMetalServiceStatus() } }
    var renderPassDescriptor: MTLRenderPassDescriptor? { didSet { updateMetalServiceStatus() } }
    
    var isMetalServiceReady: Bool = false
    
    
    func setupMetal() {
        print("Metal Services: Starting setup.")
        
        guard let device = MTLCreateSystemDefaultDevice(),
              let library = device.makeDefaultLibrary() else {
            fatalError("Could not create Metal device or library")
        }
        self.device = device
        self.commandQueue = device.makeCommandQueue()
        
        setupPipelineState(device: device, library: library)
        setupTextureCache(device: device)
        setupRenderPassDescriptor()

        updateMetalServiceStatus()
        print("Metal Services: Metal setup successful.")
    }
    
    private func setupPipelineState(device: MTLDevice, library: MTLLibrary) {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertexShader")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragmentShader")
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError("Failed to create pipeline state: \(error)")
        }
        print("Metal Services: Setup pipeline state successfully.")
    }
    
    private func setupTextureCache(device: MTLDevice) {
        CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &mtlTextureCache)
        
        print("Metal Services: Setup texture cache successfully.")
    }
    
    private func setupRenderPassDescriptor() {
        renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor?.colorAttachments[0].loadAction = .clear
        renderPassDescriptor?.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        renderPassDescriptor?.colorAttachments[0].storeAction = .store
        
        print("Metal Services: Setup render pass descriptor successfully.")
    }
    
    
    // TODO: Consider refactoring this to be getMetalServicesStatus where it checks all the guards and returns true or false
    private func updateMetalServiceStatus() {
        guard let device = device else { 
            isMetalServiceReady = false
            print("Metal Services: Device is not configured.")
            return
        }
        guard let mtlTextureCache = mtlTextureCache else {
            isMetalServiceReady = false
            print("Metal Services: Metal Texture Cache is not configured.")
            return
        }
        guard let commandBuffer = commandQueue?.makeCommandBuffer() else {
            isMetalServiceReady = false
            print("Metal Services: Commmand Buffer is not configured.")
            return
        }
        guard let renderPassDescriptor = renderPassDescriptor else {
            isMetalServiceReady = false
            print("Metal Services: Render Pass Descriptor is not configured.")
            return
        }
        guard let pipelineState = pipelineState else {
            isMetalServiceReady = false
            print("Metal Services: Pipeline State is not Configured.")
            return
        }
        
        isMetalServiceReady = true
    }
    
    
    
    func drawBufferToLayersTexture(imageBuffer: CVPixelBuffer, metalLayer: CAMetalLayer, width: Int, height: Int) {
    
        if isMetalServiceReady == false { return }
        
    
        
        print("Metal Service: Received frame and metal layer")
        print("Metal Service: Attempting to create cvmetal texture")
        
        var cvTexture: CVMetalTexture?
        CVMetalTextureCacheCreateTextureFromImage(
            kCFAllocatorDefault,
            mtlTextureCache!,
            imageBuffer,
            nil,
            .bgra8Unorm,
            width,
            height,
            0,
            &cvTexture
        )
        
        print("cvmetal texture created, attempting to extract metal texture")
        
        guard let cvTexture = cvTexture,
              let texture = CVMetalTextureGetTexture(cvTexture) else { return }
        
        print("metal texture extracted")
        print("the textue ioSurface is: ", texture.iosurface)
        
       
        renderTextureToCAMetalLayerTexture(sourceTexture: texture, targetLayer: metalLayer)
        
//        mtlTextureToCMSampleBuffer(texture: texture)
    }
    
    
    func renderTextureToCAMetalLayerTexture(sourceTexture: MTLTexture, targetLayer: CAMetalLayer) {
        
        if isMetalServiceReady == false { return }
        
        guard let drawable = targetLayer.nextDrawable() else { fatalError("Unable to get next drawable") }
        guard let commandBuffer = commandQueue?.makeCommandBuffer() else { fatalError("Unable to create command buffer") }
        
        renderPassDescriptor!.colorAttachments[0].texture = drawable.texture
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor!) else { return }
        
        renderEncoder.setRenderPipelineState(pipelineState!)
        renderEncoder.setFragmentTexture(sourceTexture, index: 0)
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
        
    }
    
    
    
    
    static func mtlTextureToCMSampleBuffer(texture: MTLTexture) -> CMSampleBuffer? {
        
        // 1. Convert the IOSurface to a CVPixelBuffer
        guard let ioSurface = texture.iosurface else { return nil }
        
        var pixelBuffer: Unmanaged<CVPixelBuffer>?
        
        CVPixelBufferCreateWithIOSurface(
            kCFAllocatorDefault,
            ioSurface,
            [:] as CFDictionary,
            &pixelBuffer
        )
        
//        print("The CVPixelBuffer is: ", pixelBuffer)
        
        
        
        // 2. Wrap the IOSurface with a CVPixelBuffer
        guard let pixelBuffer = pixelBuffer?.takeRetainedValue() else {
            print("Failed to create CVPixelBuffer")
            return nil
        }
        
        // 2. Create CMVideoFormatDescription
        var formatDescription: CMVideoFormatDescription?
        CMVideoFormatDescriptionCreateForImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: pixelBuffer,
            formatDescriptionOut: &formatDescription
        )
        guard let formatDescription = formatDescription else { return nil }
        
        // 3. Create CMSampleBuffer
        let currentTime = CMTime(seconds: CACurrentMediaTime(), preferredTimescale: 1000000)
        var sampleBuffer: CMSampleBuffer?
        var timingInfo = CMSampleTimingInfo(
            duration: CMTime.invalid,
            presentationTimeStamp: currentTime,
            decodeTimeStamp: CMTime.invalid
        )
        
        CMSampleBufferCreateForImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: pixelBuffer,
            dataReady: true,
            makeDataReadyCallback: nil,
            refcon: nil,
            formatDescription: formatDescription,
            sampleTiming: &timingInfo,
            sampleBufferOut: &sampleBuffer
        )
        
//        print("CMSampleBuffer is: ", sampleBuffer)
        
        return sampleBuffer
    }
    
    
    
    func getMetalTextureFromCVPixelBuffer(imageBuffer: CVPixelBuffer, width: Int, height: Int) -> MTLTexture? {
        
        if isMetalServiceReady == false { return nil }
        
//        print("Metal Service: Received frame and metal layer")
//        print("Metal Service: Attempting to create cvmetal texture")
        
        var cvTexture: CVMetalTexture?
        CVMetalTextureCacheCreateTextureFromImage(
            kCFAllocatorDefault,
            mtlTextureCache!,
            imageBuffer,
            nil,
            .bgra8Unorm,
            width,
            height,
            0,
            &cvTexture
        )
        
//        print("cvmetal texture created, attempting to extract metal texture")
        
        guard let cvTexture = cvTexture,
              let texture = CVMetalTextureGetTexture(cvTexture) else { return nil }
        
//        print("metal texture extracted: ", texture)
        
        return texture
    }
    
    
    
    func drawMetalTextureToLayer(texture: MTLTexture, metalLayer: CAMetalLayer) {
        
        if isMetalServiceReady == false { return }
        guard let drawable = metalLayer.nextDrawable() else { fatalError("Unable to get next drawable") }
        guard let commandBuffer = commandQueue?.makeCommandBuffer() else { fatalError("Unable to create command buffer") }
 
//        print("the textue ioSurface is: ", texture.iosurface)
        renderPassDescriptor!.colorAttachments[0].texture = drawable.texture
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor!) else { return }
        
        renderEncoder.setRenderPipelineState(pipelineState!)
        renderEncoder.setFragmentTexture(texture, index: 0)
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()

    }
    
    
    func drawMetalTextureToDrawable(texture: MTLTexture, drawable: CAMetalDrawable) {
        
        if isMetalServiceReady == false { return }
        guard let commandBuffer = commandQueue?.makeCommandBuffer() else { fatalError("Unable to create command buffer") }
 
//        print("the textue ioSurface is: ", texture.iosurface)
        renderPassDescriptor!.colorAttachments[0].texture = drawable.texture
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor!) else { return }

        renderEncoder.setRenderPipelineState(pipelineState!)
        renderEncoder.setFragmentTexture(texture, index: 0)
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()

    }
    
    
    
}
