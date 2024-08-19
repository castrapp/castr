//
//  Source.swift
//  virtualcamera
//
//  Created by Harrison Hall on 8/17/24.
//

import Foundation
import CoreMediaIO
import IOKit.audio
import os.log
import Cocoa



class virtualcameraStreamSource: NSObject, CMIOExtensionStreamSource {
    private(set) var stream: CMIOExtensionStream!
    let device: CMIOExtensionDevice
    private let _streamFormat: CMIOExtensionStreamFormat
    public var just: String = "toto"
    public var rust: String = "0"
    var count = 0
    
    init(localizedName: String, streamID: UUID, streamFormat: CMIOExtensionStreamFormat, device: CMIOExtensionDevice) {
        
        self.device = device
        self._streamFormat = streamFormat
        super.init()
        self.stream = CMIOExtensionStream(localizedName: localizedName, streamID: streamID, direction: .source, clockType: .hostTime, source: self)
    }
    
    var formats: [CMIOExtensionStreamFormat] {
        
        return [_streamFormat]
    }
    
    var activeFormatIndex: Int = 0 {
        didSet {
            if activeFormatIndex >= 1 { os_log(.error, "Invalid index")}
        }
    }
    
    var availableProperties: Set<CMIOExtensionProperty> {
        return [.streamActiveFormatIndex, .streamFrameDuration, CMIOExtensionPropertyCustomPropertyData_just]
    }
    
    func streamProperties(forProperties properties: Set<CMIOExtensionProperty>) throws -> CMIOExtensionStreamProperties {
        let streamProperties = CMIOExtensionStreamProperties(dictionary: [:])
        if properties.contains(.streamActiveFormatIndex) {
            streamProperties.activeFormatIndex = 0
        }
        if properties.contains(.streamFrameDuration) {
            let frameDuration = CMTime(value: 1, timescale: Int32(kFrameRate))
            streamProperties.frameDuration = frameDuration
        }
        if properties.contains(CMIOExtensionPropertyCustomPropertyData_just) {
            streamProperties.setPropertyState(CMIOExtensionPropertyState(value: self.just as NSString), forProperty: CMIOExtensionPropertyCustomPropertyData_just)

        }
        return streamProperties
    }
    
    func setStreamProperties(_ streamProperties: CMIOExtensionStreamProperties) throws {
        
        if let activeFormatIndex = streamProperties.activeFormatIndex {
            self.activeFormatIndex = activeFormatIndex
        }
        
        if let state = streamProperties.propertiesDictionary[CMIOExtensionPropertyCustomPropertyData_just] {
            if let newValue = state.value as? String {
                self.just = newValue
                if let deviceSource = device.source as? virtualcameraDeviceSource {
                    self.just = deviceSource.myStreamingCounter()
                }
            }
        }
    }
    
    func authorizedToStartStream(for client: CMIOExtensionClient) -> Bool {
       
        // An opportunity to inspect the client info and decide if it should be allowed to start the stream.
        logger.warning("Client is trying to connect: \(client, privacy: .public)")
        
        return true
    }
    
    func startStream() throws {
        logger.warning("STARTING THE SOURCE STREAM")
        guard let deviceSource = device.source as? virtualcameraDeviceSource else {
            fatalError("Unexpected source type \(String(describing: device.source))")
        }
        self.rust = "1"
        deviceSource.startStreaming()
    }
    
    func stopStream() throws {
        
        logger.warning("STOPPING THE SOURCE STREAM")
        guard let deviceSource = device.source as? virtualcameraDeviceSource else {
            fatalError("Unexpected source type \(String(describing: device.source))")
        }
        self.rust = "0"
        deviceSource.stopStreaming()
    }
}

