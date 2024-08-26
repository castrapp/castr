//
//  Device.swift
//  virtualcamera
//
//  Created by Harrison Hall on 8/17/24.
//

import Foundation
import CoreMediaIO
import IOKit.audio
import os.log
import Cocoa
import os




class virtualcameraDeviceSource: NSObject, CMIOExtensionDeviceSource {

    private(set) var device: CMIOExtensionDevice!
    public var _streamSource: virtualcameraStreamSource!
    public var _streamSink: virtualcameraStreamSink!
    var _streamingCounter: UInt32 = 0
    var _streamingSinkCounter: UInt32 = 0
    var _timer: DispatchSourceTimer?
    let _timerQueue = DispatchQueue(label: "timerQueue", qos: .userInteractive, attributes: [], autoreleaseFrequency: .workItem, target: .global(qos: .userInteractive))
    var _videoDescription: CMFormatDescription!
    var _bufferPool: CVPixelBufferPool!
    var _bufferAuxAttributes: NSDictionary!
    var _whiteStripeStartRow: UInt32 = 0
    var _whiteStripeIsAscending: Bool = false
    var lastMessage = "Sample Camera for macOS"
    let paragraphStyle = NSMutableParagraphStyle()
    let textFontAttributes: [NSAttributedString.Key : Any]
    var sinkStarted = false
    var lastTimingInfo = CMSampleTimingInfo()
    var client: CMIOExtensionClient?
    
    func myStreamingCounter() -> String {
        return "sc=\(_streamingCounter)"
    }
    
    init(localizedName: String) {
        
        
        logger.info("INITIALIZING THE virtualcamerDeviceSource")
        paragraphStyle.alignment = NSTextAlignment.center
        textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ]
        super.init()
        let deviceID = UUID()
        self.device = CMIOExtensionDevice(localizedName: localizedName, deviceID: deviceID, legacyDeviceID: deviceID.uuidString, source: self)
        
        CMVideoFormatDescriptionCreate(
            allocator: kCFAllocatorDefault,
            codecType: pixelFormat,
            width: fixedCamWidth,
            height: fixedCamHeight,
            extensions: nil,
            
            formatDescriptionOut: &_videoDescription
        )
        
        let pixelBufferAttributes: NSDictionary = [
            kCVPixelBufferWidthKey: fixedCamWidth,
            kCVPixelBufferHeightKey: fixedCamHeight,
            kCVPixelBufferPixelFormatTypeKey: _videoDescription.mediaSubType,
            kCVPixelBufferIOSurfacePropertiesKey: [:]
        ]
        CVPixelBufferPoolCreate(kCFAllocatorDefault, nil, pixelBufferAttributes, &_bufferPool)
        
        let videoStreamFormat = CMIOExtensionStreamFormat.init(formatDescription: _videoDescription, maxFrameDuration: CMTime(value: 1, timescale: Int32(kFrameRate)), minFrameDuration: CMTime(value: 1, timescale: Int32(kFrameRate)), validFrameDurations: nil)
        _bufferAuxAttributes = [kCVPixelBufferPoolAllocationThresholdKey: 5]
        
        let videoID = UUID()
        _streamSource = virtualcameraStreamSource(localizedName: "CastrVirtualCamera.Video", streamID: videoID, streamFormat: videoStreamFormat, device: device)
        let videoSinkID = UUID()
        _streamSink = virtualcameraStreamSink(localizedName: "CastrVirtualCamera.Video.Sink", streamID: videoSinkID, streamFormat: videoStreamFormat, device: device)
        do {
            try device.addStream(_streamSource.stream)
            try device.addStream(_streamSink.stream)
        } catch let error {
            fatalError("Failed to add stream: \(error.localizedDescription)")
        }
    }
    
    var availableProperties: Set<CMIOExtensionProperty> {
        
        return [.deviceTransportType, .deviceModel]
    }
    
    func deviceProperties(forProperties properties: Set<CMIOExtensionProperty>) throws -> CMIOExtensionDeviceProperties {
        
        let deviceProperties = CMIOExtensionDeviceProperties(dictionary: [:])
        if properties.contains(.deviceTransportType) {
            deviceProperties.transportType = kIOAudioDeviceTransportTypeVirtual
        }
        if properties.contains(.deviceModel) {
            deviceProperties.model = "Castr Virtual Camera Model"
        }
        
        return deviceProperties
    }
    
    func setDeviceProperties(_ deviceProperties: CMIOExtensionDeviceProperties) throws {
        
        
        // Handle settable properties here.
    }
    
    
    func startStreaming() {
        
        guard let _ = _bufferPool else {
            return
        }
        
        _timer = DispatchSource.makeTimerSource(flags: .strict, queue: _timerQueue)
        _timer!.schedule(deadline: .now(), repeating: 1.0/Double(kFrameRate), leeway: .seconds(0))
        
        _timer!.setEventHandler {

            if self.sinkStarted {
                guard let client = self.client else { return }
                logger.info("SINK HAS BEEN STARTED, NOW RETURNING")
                logger.info("SINK HAS BEEN STARTED, NOW RETURNING")
                logger.info("SINK HAS BEEN STARTED, NOW RETURNING")
                logger.info("SINK HAS BEEN STARTED, NOW RETURNING")
                logger.info("client is: \(client, privacy: .public)")
                
                
                self._streamSink.stream.consumeSampleBuffer(from: client) { sampleBuffer, sequenceNumber, discontinuity, hasMoreSampleBuffers, err in
                    
//                    logger.info("sample buffer is: \(sampleBuffer || err, privacy: .public)")
                    logger.info("Consuming the client's sample buffer")
                    if(discontinuity.rawValue != 0) {
                        logger.error("Discontinuity is: \(discontinuity.rawValue)")
                    }
                    if sampleBuffer != nil {
                        
                        self.lastTimingInfo.presentationTimeStamp = CMClockGetTime(CMClockGetHostTimeClock())
                        let output = CMIOExtensionScheduledOutput(sequenceNumber: sequenceNumber, hostTimeInNanoseconds: UInt64(self.lastTimingInfo.presentationTimeStamp.seconds * Double(NSEC_PER_SEC)))
                        
                        self._streamSource.stream.send(sampleBuffer!, discontinuity: [], hostTimeInNanoseconds: UInt64(sampleBuffer!.presentationTimeStamp.seconds * Double(NSEC_PER_SEC)))
                        logger.info("Client's sample buffer sent to the source stream")
                        
                        self._streamSink.stream.notifyScheduledOutputChanged(output)
                        
                    } else {
                        logger.info("sample buffer is: \(nil, privacy: .public)")
                    }
                    
                    logger.info("Sample buffer is: \(String(describing: sampleBuffer), privacy: .public)")
                    logger.info("Sequence number is: \(sequenceNumber)")
                    logger.info("Discontinuity is: \(discontinuity.rawValue)")
                    logger.info("Does the sample buffer have more buffers?: \(hasMoreSampleBuffers)")
                    logger.info("Error is: \(err)")
                    
                }
                
                return
            }
            //var text: String? = nil
             var err: OSStatus = 0
            
            var pixelBuffer: CVPixelBuffer?

            let timestamp = CMClockGetTime(CMClockGetHostTimeClock())
            let text = self.lastMessage + " \(Int(timestamp.seconds))"
            err = CVPixelBufferPoolCreatePixelBufferWithAuxAttributes(kCFAllocatorDefault, self._bufferPool, self._bufferAuxAttributes, &pixelBuffer)
            if err != 0 {
                logger.error("out of pixel buffers \(err)")
            }
            if let pixelBuffer = pixelBuffer {
                
                CVPixelBufferLockBaseAddress(pixelBuffer, [])
                let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)
                let width = CVPixelBufferGetWidth(pixelBuffer)
                let height = CVPixelBufferGetHeight(pixelBuffer)
                let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
                if let context = CGContext(data: pixelData,
                                              width: width,
                                              height: height,
                                              bitsPerComponent: 8,
                                              bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
                                              space: rgbColorSpace,
                                           //bitmapInfo: UInt32(CGImageAlphaInfo.noneSkipFirst.rawValue) | UInt32(CGImageByteOrderInfo.order32Little.rawValue))
                                           bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
                {
                    context.interpolationQuality = .high
                    let graphicsContext = NSGraphicsContext(cgContext: context, flipped: false)
                    NSGraphicsContext.saveGraphicsState()
                    NSGraphicsContext.current = graphicsContext
                    let cgContext = graphicsContext.cgContext
                    let dstRect = CGRect(x: 0, y: 0, width: width, height: height)
                    cgContext.clear(dstRect)
                    cgContext.setFillColor(NSColor.black.cgColor)
                    cgContext.fill(dstRect)
                    let textOrigin = CGPoint(x: 0, y: -height/2 + Int(fontSize/2.0))
                    let rect = CGRect(origin: textOrigin, size: NSSize(width: width, height: height))
                    text.draw(in: rect, withAttributes: self.textFontAttributes)
                    NSGraphicsContext.restoreGraphicsState()
                }
                CVPixelBufferUnlockBaseAddress(pixelBuffer, [])
            }

            if let pixelBuffer = pixelBuffer {
                var sbuf: CMSampleBuffer!
                var timingInfo = CMSampleTimingInfo()
                timingInfo.presentationTimeStamp = CMClockGetTime(CMClockGetHostTimeClock())
                err = CMSampleBufferCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: pixelBuffer, dataReady: true, makeDataReadyCallback: nil, refcon: nil, formatDescription: self._videoDescription, sampleTiming: &timingInfo, sampleBufferOut: &sbuf)
                if err == 0 {
                    self._streamSource.stream.send(sbuf, discontinuity: [], hostTimeInNanoseconds: UInt64(timingInfo.presentationTimeStamp.seconds * Double(NSEC_PER_SEC)))
                    logger.info("CONSUMING SAMPLE BUFFER for a placeholder")
                } else {
                    self.lastMessage = "err send"
                }
               
            }
        }
        
        _timer!.setCancelHandler {
        }
        
        _timer!.resume()
    }
    
    func stopStreaming() {

        _timer?.cancel()
        _timer = nil
        
    }
    
//    func consumeBuffer(_ client: CMIOExtensionClient) {
////        logger.info("CONSUMING THE SAMPLE BUFFER")
//        if sinkStarted == false {
//            return
//        }
//        self._streamSink.stream.consumeSampleBuffer(from: client) { sbuf, seq, discontinuity, hasMoreSampleBuffers, err in
//            if sbuf != nil {
//                self.lastTimingInfo.presentationTimeStamp = CMClockGetTime(CMClockGetHostTimeClock())
//                let output = CMIOExtensionScheduledOutput(sequenceNumber: seq, hostTimeInNanoseconds: UInt64(self.lastTimingInfo.presentationTimeStamp.seconds * Double(NSEC_PER_SEC)))
//                
//                if self._streamingCounter > 0 {
//                    self._streamSource.stream.send(sbuf!, discontinuity: [], hostTimeInNanoseconds: UInt64(sbuf!.presentationTimeStamp.seconds * Double(NSEC_PER_SEC)))
//                }
//                self._streamSink.stream.notifyScheduledOutputChanged(output)
//                logger.info("Does the sample buffer have more buffers?: \(hasMoreSampleBuffers)")
//                logger.info("Discontinouty is: \(discontinuity.rawValue)")
//                
//            }
//            
//                self.consumeBuffer(client)
//            
//        }
//    }

    func startStreamingSink(client: CMIOExtensionClient) {
        
        self.sinkStarted = true
        self.client = client
    }
    
    func stopStreamingSink() {
        
        self.sinkStarted = false
        self.client = nil
        
    }
}





