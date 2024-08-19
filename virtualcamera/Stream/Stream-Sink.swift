//
//  File.swift
//  virtualcamera
//
//  Created by Harrison Hall on 8/17/24.
//

import Foundation
import CoreMediaIO
import IOKit.audio
import os.log
import Cocoa


class virtualcameraStreamSink: NSObject, CMIOExtensionStreamSource {
    
    private(set) var stream: CMIOExtensionStream!
    
    let device: CMIOExtensionDevice
    private let _streamFormat: CMIOExtensionStreamFormat
    
    init(localizedName: String, streamID: UUID, streamFormat: CMIOExtensionStreamFormat, device: CMIOExtensionDevice) {
        
        self.device = device
        self._streamFormat = streamFormat
        super.init()
        self.stream = CMIOExtensionStream(localizedName: localizedName, streamID: streamID, direction: .sink, clockType: .hostTime, source: self)
    }
    
    var formats: [CMIOExtensionStreamFormat] {
        
        return [_streamFormat]
    }
    
    var activeFormatIndex: Int = 0 {
        
        didSet {
            if activeFormatIndex >= 1 {
                os_log(.error, "Invalid index")
            }
        }
    }
    
    var availableProperties: Set<CMIOExtensionProperty> {
        
        return [.streamActiveFormatIndex, .streamFrameDuration, .streamSinkBufferQueueSize, .streamSinkBuffersRequiredForStartup, .streamSinkBufferUnderrunCount, .streamSinkEndOfData]
    }

    var client: CMIOExtensionClient?
    func streamProperties(forProperties properties: Set<CMIOExtensionProperty>) throws -> CMIOExtensionStreamProperties {
        let streamProperties = CMIOExtensionStreamProperties(dictionary: [:])
        if properties.contains(.streamActiveFormatIndex) {
            streamProperties.activeFormatIndex = 0
        }
        if properties.contains(.streamFrameDuration) {
            let frameDuration = CMTime(value: 1, timescale: Int32(kFrameRate))
            streamProperties.frameDuration = frameDuration
        }
        if properties.contains(.streamSinkBufferQueueSize) {
            streamProperties.sinkBufferQueueSize = 1
        }
        if properties.contains(.streamSinkBuffersRequiredForStartup) {
            streamProperties.sinkBuffersRequiredForStartup = 1
        }
        return streamProperties
    }
    
    func setStreamProperties(_ streamProperties: CMIOExtensionStreamProperties) throws {
        
        if let activeFormatIndex = streamProperties.activeFormatIndex {
            self.activeFormatIndex = activeFormatIndex
        }
        
    }
    
    func authorizedToStartStream(for client: CMIOExtensionClient) -> Bool {
        
        // An opportunity to inspect the client info and decide if it should be allowed to start the stream.
        self.client = client
        return true
    }
    
    func startStream() throws {
        logger.warning("STARTING THE SINK STREAM")
        guard let deviceSource = device.source as? virtualcameraDeviceSource else {
            fatalError("Unexpected source type \(String(describing: device.source))")
        }
        if let client = client {
            deviceSource.startStreamingSink(client: client)
        }
    }
    
    func stopStream() throws {
        logger.warning("STOPPING THE SINK STREAM")
        guard let deviceSource = device.source as? virtualcameraDeviceSource else {
            fatalError("Unexpected source type \(String(describing: device.source))")
        }
        deviceSource.stopStreamingSink()
    }
}

