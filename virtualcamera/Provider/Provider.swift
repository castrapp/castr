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
        
       
        
        
        if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) {
            logger.warning("Shared container URL: \(containerURL.path, privacy: .public)")
            logger.warning("Shared container URL: \(containerURL.path, privacy: .public)")
            logger.warning("Shared container URL: \(containerURL.path, privacy: .public)")
            logger.warning("Shared container URL: \(containerURL.path, privacy: .public)")
        } else {
            logger.warning("Failed to get the container URL for the app group.")
            logger.warning("Failed to get the container URL for the app group.")
            logger.warning("Failed to get the container URL for the app group.")
            logger.warning("Failed to get the container URL for the app group.")
        }
        
        if let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) {
            logger.warning("GOT THE SHARED DEFUALTS")
            logger.warning("GOT THE SHARED DEFUALTS")
            logger.warning("GOT THE SHARED DEFUALTS")
            logger.warning("GOT THE SHARED DEFUALTS")
            
            if let myString = sharedDefaults.string(forKey: "testKey") {
                logger.warning("the read value is: \(myString, privacy: .public)")
                logger.warning("the read value is: \(myString, privacy: .public)")
                logger.warning("the read value is: \(myString, privacy: .public)")
                logger.warning("the read value is: \(myString, privacy: .public)")
            }
            else {
                logger.warning("COULD NOT READ VALUE")
                logger.warning("COULD NOT READ VALUE")
                logger.warning("COULD NOT READ VALUE")
                logger.warning("COULD NOT READ VALUE")
            }
           
        }
        
        else {
            logger.warning("FAILED TO GET THE SHARED DEFAULTS")
            logger.warning("FAILED TO GET THE SHARED DEFAULTS")
            logger.warning("FAILED TO GET THE SHARED DEFAULTS")
            logger.warning("FAILED TO GET THE SHARED DEFAULTS")
        }
        
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
