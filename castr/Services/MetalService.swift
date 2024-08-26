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
    
    var width = 1
    var height = 1
//    var metalLayer = CAMetalLayer()
//    var screenLayer = CAMetalLayer()
    var pipelineState: MTLRenderPipelineState?
    var device: MTLDevice?
    var commandQueue: MTLCommandQueue?
    var texture: MTLTexture?
    var timerStarted: Bool = false
    
    var mtlTextureCache: CVMetalTextureCache?
    var renderPassDescriptor: MTLRenderPassDescriptor?
    
    
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
    
    func drawBufferToLayersTexture(imageBuffer: CVPixelBuffer, metalLayer: CAMetalLayer) {
        
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
//        metalLayer.contentsGravity = .resizeAspect
        
        print("received frame and metal layer: ", metalLayer.drawableSize)
        print("metals layers frame is: ", metalLayer.frame)
        print("metals layers bounds are: ", metalLayer.bounds)
        
//        guard let device = device else { fatalError("Device is nil") }
        guard let mtlTextureCache = mtlTextureCache else { fatalError("Metal texture cache is nil") }
        guard let drawable = metalLayer.nextDrawable() else { fatalError("Unable to get next drawable") }
        guard let commandBuffer = commandQueue?.makeCommandBuffer() else { fatalError("Unable to create command buffer") }
        guard let renderPassDescriptor = renderPassDescriptor else { fatalError("Render pass descriptor is nil") }
        guard let pipelineState = pipelineState else { fatalError("Pipeline state is nil") }
        
        print("got passed first guard, attempting to create cvmetal texture")
        var cvTexture: CVMetalTexture?
        CVMetalTextureCacheCreateTextureFromImage(
            kCFAllocatorDefault,
            mtlTextureCache,
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
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setFragmentTexture(texture, index: 0)
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
        
//        mtlTextureToCMSampleBuffer(texture: texture)
    }
    
    
    
    
    
    func mtlTextureToCMSampleBuffer(texture: MTLTexture) {
        
        // 1. Convert the IOSurface to a CVPixelBuffer
        guard let ioSurface = texture.iosurface else { return }
        
        var pixelBuffer: Unmanaged<CVPixelBuffer>?
        
        CVPixelBufferCreateWithIOSurface(
            kCFAllocatorDefault,
            ioSurface,
            [:] as CFDictionary,
            &pixelBuffer
        )
        
        print("The CVPixelBuffer is: ", pixelBuffer)
        
        
        
        // 2. Wrap the IOSurface with a CVPixelBuffer
        guard let pixelBuffer = pixelBuffer?.takeRetainedValue() else {
            print("Failed to create CVPixelBuffer")
            return
        }
        
        // 2. Create CMVideoFormatDescription
        var formatDescription: CMVideoFormatDescription?
        CMVideoFormatDescriptionCreateForImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: pixelBuffer,
            formatDescriptionOut: &formatDescription
        )
        guard let formatDescription = formatDescription else { return }
        
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
        
        if let sampleBuffer = sampleBuffer {
//             videoWriter.writeSampleBuffer(sampleBuffer)
        }
        print("CMSampleBuffer is: ", sampleBuffer)
    }
    
    
    
    
}



//
//var timer: DispatchSourceTimer?
//
//func createTimer() {
//    
//    print("starting timer")
//    
//    timer = DispatchSource.makeTimerSource()
//    timer?.schedule(deadline: .now(), repeating: 1.0 / 30.0)
//    timer?.setEventHandler {
//        print("Frame update at 30fps")
//    }
//    print("about to resume")
//    MetalState.shared.timerStarted = true
//    timer?.resume()
//}




import AVFoundation
import AppKit

class VideoWriter {
    private let videoWriterQueue = DispatchQueue(label: "com.yourdomain.videowriter", qos: .userInitiated)
    private var assetWriter: AVAssetWriter?
    private var assetWriterInput: AVAssetWriterInput?
    private var isSessionStarted = false
    private var outputURL: URL?

    func promptForSaveLocation(completion: @escaping (Bool) -> Void) {
        let savePanel = NSSavePanel()
        savePanel.allowedFileTypes = ["mp4"]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.title = "Save Video"
        savePanel.message = "Choose a location to save the video"
        savePanel.nameFieldStringValue = "output.mp4"

        savePanel.begin { result in
            if result == .OK, let url = savePanel.url {
                self.outputURL = url
                completion(true)
            } else {
                completion(false)
            }
        }
    }

    func setupAssetWriter(width: Int, height: Int, completion: @escaping (Bool) -> Void) {
        guard let outputURL = self.outputURL else {
            print("Output URL not set. Call promptForSaveLocation first.")
            completion(false)
            return
        }

        videoWriterQueue.async { [weak self] in
            guard let self = self else { return }
            do {
                self.assetWriter = try AVAssetWriter(outputURL: outputURL, fileType: .mp4)
                
                let outputSettings: [String: Any] = [
                    AVVideoCodecKey: AVVideoCodecType.h264,
                    AVVideoWidthKey: width,
                    AVVideoHeightKey: height
                ]
                
                self.assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: outputSettings)
                self.assetWriterInput?.expectsMediaDataInRealTime = true
                
                if let assetWriter = self.assetWriter, let assetWriterInput = self.assetWriterInput {
                    if assetWriter.canAdd(assetWriterInput) {
                        assetWriter.add(assetWriterInput)
                    }
                }
                
                DispatchQueue.main.async {
                    completion(true)
                }
            } catch {
                print("Error setting up AVAssetWriter: \(error)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }

    func startWriting(completion: @escaping () -> Void) {
        videoWriterQueue.async { [weak self] in
            self?.assetWriter?.startWriting()
            DispatchQueue.main.async {
                completion()
            }
        }
    }

    func finishWriting(completion: @escaping () -> Void) {
        videoWriterQueue.async { [weak self] in
            self?.assetWriterInput?.markAsFinished()
            self?.assetWriter?.finishWriting(completionHandler: {
                DispatchQueue.main.async {
                    completion()
                }
            })
        }
    }

    func writeSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        videoWriterQueue.async { [weak self] in
            guard let self = self,
                  let assetWriter = self.assetWriter,
                  let assetWriterInput = self.assetWriterInput else {
                print("AssetWriter or AssetWriterInput not set up")
                return
            }

            if assetWriter.status == .failed {
                print("AssetWriter status is failed. Error: \(assetWriter.error?.localizedDescription ?? "unknown error")")
                return
            }

            if !self.isSessionStarted {
                let startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                assetWriter.startSession(atSourceTime: startTime)
                self.isSessionStarted = true
            }

            if assetWriterInput.isReadyForMoreMediaData {
                assetWriterInput.append(sampleBuffer)
            } else {
                print("AssetWriterInput is not ready for more data")
            }
        }
    }
}
