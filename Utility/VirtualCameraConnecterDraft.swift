//
//  VirtualCameraConnecter.swift
//  castr
//
//  Created by Harrison Hall on 8/16/24.
//

import SwiftUI
import AVFoundation
import Cocoa
import CoreMediaIO
import SystemExtensions
import ScreenCaptureKit
import OSLog
import Combine
import Foundation


class VirtualCameraAdapter: ObservableObject {
    
//    static let shared = VirtualCameraAdapter()
    
    var sourceStream: CMIOStreamID?
    var sinkStream: CMIOStreamID?
    var sinkQueue: CMSimpleQueue?
    var videoDescription: CMFormatDescription!
    var bufferPool: CVPixelBufferPool!
    var propTimer: Timer?
    var readyToEnqueue = false
    var needToStream: Bool = false
    var enqueued = false
    
    private init() { }
    
    
    func setupVirtualCamera() {
      
        // 1. Find the device
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.externalUnknown], mediaType: .video,position: .unspecified)
        guard let targetDevice = discoverySession.devices.first(where: { $0.localizedName == "Swift Sample Camera" }) else { return }

        
        
        // 2. Find the device's CMIODeviceID from the CMIO Framework
        var targetCMIODeviceID: CMIODeviceID?
        var dataSize: UInt32 = 0
        var devices = [CMIOObjectID]()
        var dataUsed: UInt32 = 0
        
        var opa = CMIOObjectPropertyAddress(CMIOObjectPropertySelector(kCMIOHardwarePropertyDevices), .global, .main)
        CMIOObjectGetPropertyDataSize(CMIOObjectPropertySelector(kCMIOObjectSystemObject), &opa, 0, nil, &dataSize);
        let nDevices = Int(dataSize) / MemoryLayout<CMIOObjectID>.size
        devices = [CMIOObjectID](repeating: 0, count: Int(nDevices))
        CMIOObjectGetPropertyData(CMIOObjectPropertySelector(kCMIOObjectSystemObject), &opa, 0, nil, dataSize, &dataUsed, &devices);
        for deviceObjectID in devices {
            opa.mSelector = CMIOObjectPropertySelector(kCMIODevicePropertyDeviceUID)
            CMIOObjectGetPropertyDataSize(deviceObjectID, &opa, 0, nil, &dataSize)
            var name: CFString = "" as NSString
            CMIOObjectGetPropertyData(deviceObjectID, &opa, 0, nil, dataSize, &dataUsed, &name);
            if String(name) == targetDevice.uniqueID {
                targetCMIODeviceID = deviceObjectID
            }
        }
        
        
        
        // 3. Get the input streams using the CMIO Device's CMIODeviceID
        guard let targetCMIODeviceID = targetCMIODeviceID else { return }
        var streamIDs: [CMIOStreamID]
        var dataSize2: UInt32 = 0
        var dataUsed2: UInt32 = 0
        var opa2 = CMIOObjectPropertyAddress(CMIOObjectPropertySelector(kCMIODevicePropertyStreams), .global, .main)
        CMIOObjectGetPropertyDataSize(targetCMIODeviceID, &opa2, 0, nil, &dataSize2);
        let numberStreams = Int(dataSize2) / MemoryLayout<CMIOStreamID>.size
        var streamIds = [CMIOStreamID](repeating: 0, count: numberStreams)
        CMIOObjectGetPropertyData(targetCMIODeviceID, &opa2, 0, nil, dataSize2, &dataUsed2, &streamIds)
        streamIDs = streamIds
        
        
        
        // 4. Find and connect to the Sink Stream's Queue
        guard streamIds.count == 2 else {
            print("Sink Stream not found")
            return
        }
        
        print("Sink Stream found")
        sinkStream = streamIds[1]
        guard let sinkStream = sinkStream else { return }
        
        
        // 5. Initialize the Sink Stream
        /// 5.1 Create a pixel buffer pool
        CMVideoFormatDescriptionCreate(
            allocator: kCFAllocatorDefault,
            codecType: pixelFormat,
            width: fixedCamWidth,
            height: fixedCamHeight,
            extensions: nil,
            formatDescriptionOut: &videoDescription
        )
        let pixelBufferAttributes: NSDictionary = [
                kCVPixelBufferWidthKey: fixedCamWidth,
                kCVPixelBufferHeightKey: fixedCamHeight,
                kCVPixelBufferPixelFormatTypeKey: videoDescription.mediaSubType,
                kCVPixelBufferIOSurfacePropertiesKey: [:]
        ]
        CVPixelBufferPoolCreate(kCFAllocatorDefault, nil, pixelBufferAttributes, &bufferPool)
        
        
        
        let queuePointer = UnsafeMutablePointer<Unmanaged<CMSimpleQueue>?>.allocate(capacity: 1)
        let adapterReference = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        let result = CMIOStreamCopyBufferQueue(
            sinkStream, 
            {
                (sinkStream: CMIOStreamID, buf: UnsafeMutableRawPointer?, refcon: UnsafeMutableRawPointer?) in
                let adapter = Unmanaged<VirtualCameraAdapter>.fromOpaque(refcon!).takeUnretainedValue()
                adapter.readyToEnqueue = true
            },
            adapterReference,
            queuePointer
        )
        
        if result != 0 {
            print("Error connecting to the Sink Stream")
        } else {
            
            if let queue = queuePointer.pointee {
                self.sinkQueue = queue.takeUnretainedValue()
            }
            let resultStart = CMIODeviceStartStream(targetCMIODeviceID, sinkStream) == 0
            
            print(resultStart ? "Sink Stream has been started" : "Error starting the Sink Stream")
        }
        
        
        
        
        propTimer?.invalidate()
        propTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(propertyTimer), userInfo: nil, repeats: true)
    }
    
    
    
    // THis is stuff to eventually omit
    func getJustProperty(streamId: CMIOStreamID) -> String? {
        let selector = FourCharCode("just")
        var address = CMIOObjectPropertyAddress(selector, .global, .main)
        let exists = CMIOObjectHasProperty(streamId, &address)
        if exists {
            var dataSize: UInt32 = 0
            var dataUsed: UInt32 = 0
            CMIOObjectGetPropertyDataSize(streamId, &address, 0, nil, &dataSize)
            var name: CFString = "" as NSString
            CMIOObjectGetPropertyData(streamId, &address, 0, nil, dataSize, &dataUsed, &name);
            return name as String
        } else {
            return nil
        }
    }

    func setJustProperty(streamId: CMIOStreamID, newValue: String) {
        let selector = FourCharCode("just")
        var address = CMIOObjectPropertyAddress(selector, .global, .main)
        let exists = CMIOObjectHasProperty(streamId, &address)
        if exists {
            var settable: DarwinBoolean = false
            CMIOObjectIsPropertySettable(streamId,&address,&settable)
            if settable == false {
                return
            }
            var dataSize: UInt32 = 0
            CMIOObjectGetPropertyDataSize(streamId, &address, 0, nil, &dataSize)
            var newName: CFString = newValue as NSString
            CMIOObjectSetPropertyData(streamId, &address, 0, nil, dataSize, &newName)
        }
    }
    
    @objc func propertyTimer() {
        if let sourceStream = sourceStream {
            self.setJustProperty(streamId: sourceStream, newValue: "random")
            let just = self.getJustProperty(streamId: sourceStream)
            if let just = just {
                if just == "sc=1" {
                    needToStream = true
                } else {
                    needToStream = false
                }
            }
            print("need to stream = \(needToStream)")
        }
    }

    

    
    
    @objc func enqueue(_ sampleBuffer: CMSampleBuffer) {
        if needToStream {
            
            if (enqueued == false || readyToEnqueue == true) {
                
                if let queue = self.sinkQueue {
                    
                    enqueued = true
                    readyToEnqueue = false
                    
                    // Striped
                    if let stripedSampleBuffer = stripMetadata(from: sampleBuffer) {

                        guard CMSimpleQueueGetCount(queue) < CMSimpleQueueGetCapacity(queue) else {
                            print("error enqueuing")
                            return
                        }
                        let pointerRef = UnsafeMutableRawPointer(Unmanaged.passRetained(sampleBuffer).toOpaque())
                        CMSimpleQueueEnqueue(queue, element: pointerRef)
        
                    }
                }
            }
        }
    }
    
    
    
    
    func stripMetadata(from sampleBuffer: CMSampleBuffer) -> CMSampleBuffer? {
        
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
              let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) else {
            print("Failed to get necessary components from sample buffer")
            return nil
        }
        
        var timingInfo = CMSampleTimingInfo()
        CMSampleBufferGetSampleTimingInfo(sampleBuffer, at: 0, timingInfoOut: &timingInfo)
        
        var newSampleBuffer: CMSampleBuffer?
        let status = CMSampleBufferCreateForImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: imageBuffer,
            dataReady: true,
            makeDataReadyCallback: nil,
            refcon: nil,
            formatDescription: formatDescription,
            sampleTiming: &timingInfo,
            sampleBufferOut: &newSampleBuffer
        )
        
        if status != noErr {
            print("Failed to create new sample buffer: \(status)")
            return nil
        }
        
        
        return newSampleBuffer
    }

    
}
