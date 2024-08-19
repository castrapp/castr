//
//  Provider.swift
//  virtualcamera
//
//  Created by Harrison Hall on 8/17/24.
//


import Foundation
import CoreMediaIO
import IOKit.audio
import os.log
import Cocoa



class virtualcameraProviderSource: NSObject, CMIOExtensionProviderSource {
    
    private(set) var provider: CMIOExtensionProvider!
    
    private var deviceSource: virtualcameraDeviceSource!

    init(clientQueue: DispatchQueue?) {
        super.init()
        logger.info("STARTING UP THE VIRTUAL CAMERA PROVIDER")
        provider = CMIOExtensionProvider(source: self, clientQueue: clientQueue)
        deviceSource = virtualcameraDeviceSource(localizedName: cameraName)
        
        do {
            try provider.addDevice(deviceSource.device)
        } catch let error {
            fatalError("Failed to add device: \(error.localizedDescription)")
        }
    }
    
    func connect(to client: CMIOExtensionClient) throws {
        logger.warning("PROVIDER IS CONNECTING TO CLIENT: \(client, privacy: .public)")
    }

    func disconnect(from client: CMIOExtensionClient) {
        logger.warning("PROVIDER IS DISCONNECTING FROM CLIENT: \(client, privacy: .public)")
    }

    var availableProperties: Set<CMIOExtensionProperty> {
        
        // See full list of CMIOExtensionProperty choices in CMIOExtensionProperties.h
        return [.providerManufacturer]
    }
    
    func providerProperties(forProperties properties: Set<CMIOExtensionProperty>) throws -> CMIOExtensionProviderProperties {
        
        let providerProperties = CMIOExtensionProviderProperties(dictionary: [:])
        if properties.contains(.providerManufacturer) {
            providerProperties.manufacturer = "Castr Virtual Camera Manufacturer"
        }
        return providerProperties
    }
    
    func setProviderProperties(_ providerProperties: CMIOExtensionProviderProperties) throws {
        // Handle settable properties here.
        
    }
}
