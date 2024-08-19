//
//  virtualcamerahelper.swift
//  castr
//
//  Created by Harrison Hall on 8/16/24.
//

import Foundation
import AVFoundation
import CoreMediaIO

class VirtualCameraManager {
    static let shared = VirtualCameraManager()
    
    private var sinkStream: CMIOStreamID?
    private var sinkQueue: CMSimpleQueue?
    
    private init() {
       
    }
    
    func setupVirtualCamera() {
        // Step 1: Get the AVCaptureDevice for the virtual camera
        guard let device = AVCaptureDevice.devices(for: .video).first(where: { $0.localizedName == "Castr Virtual Camera" }) else {
            print("Failed to find Castr Virtual Camera")
            return
        }
        
        // Step 2: Get the CMIODeviceID using the AVCaptureDevice
        guard let deviceID = getCMIODevice(uid: device.uniqueID) else {
            print("Failed to get CMIODeviceID")
            return
        }
        
        // Step 3: Get the sink stream
        let streams = getStreams(deviceId: deviceID)
        guard streams.count >= 2 else {
            print("Not enough streams found")
            return
        }
        sinkStream = streams[1]
        
        // Step 4: Initialize the sink
        initSink(deviceId: deviceID, sinkStream: streams[1])
    }
    
    private func getCMIODevice(uid: String) -> CMIODeviceID? {
        var propertyAddress = CMIOObjectPropertyAddress(
            mSelector: CMIOObjectPropertySelector(kCMIOHardwarePropertyDevices),
            mScope: CMIOObjectPropertyScope(kCMIOObjectPropertyScopeGlobal),
            mElement: CMIOObjectPropertyElement(kCMIOObjectPropertyElementMaster)
        )
        
        var dataSize: UInt32 = 0
        CMIOObjectGetPropertyDataSize(CMIOObjectID(kCMIOObjectSystemObject), &propertyAddress, 0, nil, &dataSize)
        
        let deviceCount = Int(dataSize) / MemoryLayout<CMIODeviceID>.size
        var devices = [CMIODeviceID](repeating: 0, count: deviceCount)
        
        CMIOObjectGetPropertyData(CMIOObjectID(kCMIOObjectSystemObject), &propertyAddress, 0, nil, dataSize, &dataSize, &devices)
        
        for device in devices {
            propertyAddress.mSelector = CMIOObjectPropertySelector(kCMIODevicePropertyDeviceUID)
            var deviceUID: CFString = "" as CFString
            var dataUsed: UInt32 = 0
            CMIOObjectGetPropertyData(device, &propertyAddress, 0, nil, UInt32(MemoryLayout<CFString>.size), &dataUsed, &deviceUID)
            
            if String(deviceUID) == uid {
                return device
            }
        }
        
        return nil
    }
    
    private func getStreams(deviceId: CMIODeviceID) -> [CMIOStreamID] {
        var propertyAddress = CMIOObjectPropertyAddress(
            mSelector: CMIOObjectPropertySelector(kCMIODevicePropertyStreams),
            mScope: CMIOObjectPropertyScope(kCMIODevicePropertyScopeOutput),
            mElement: CMIOObjectPropertyElement(kCMIOObjectPropertyElementMaster)
        )
        
        var dataSize: UInt32 = 0
        CMIOObjectGetPropertyDataSize(deviceId, &propertyAddress, 0, nil, &dataSize)
        
        let streamCount = Int(dataSize) / MemoryLayout<CMIOStreamID>.size
        var streams = [CMIOStreamID](repeating: 0, count: streamCount)
        
        CMIOObjectGetPropertyData(deviceId, &propertyAddress, 0, nil, dataSize, &dataSize, &streams)
        
        return streams
    }
    
    private func initSink(deviceId: CMIODeviceID, sinkStream: CMIOStreamID) {
        let queuePointer = UnsafeMutablePointer<Unmanaged<CMSimpleQueue>?>.allocate(capacity: 1)
        let selfPointer = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        
        let result = CMIOStreamCopyBufferQueue(sinkStream, { _, _, _ in }, selfPointer, queuePointer)
        
        if result == 0, let queue = queuePointer.pointee {
            self.sinkQueue = queue.takeUnretainedValue()
            CMIODeviceStartStream(deviceId, sinkStream)
        } else {
            print("Failed to initialize sink")
        }
    }
    
    func enqueueFrame(_ sampleBuffer: CMSampleBuffer) {
         guard let queue = sinkQueue, CMSimpleQueueGetCount(queue) < CMSimpleQueueGetCapacity(queue) else {
             print("Queue is full or not initialized")
             return
         }
         
         // Create a copy of the sample buffer
         var copiedBuffer: CMSampleBuffer?
         CMSampleBufferCreateCopy(allocator: kCFAllocatorDefault, sampleBuffer: sampleBuffer, sampleBufferOut: &copiedBuffer)
         
         if let copiedBuffer = copiedBuffer {
             let pointerRef = UnsafeMutableRawPointer(Unmanaged.passRetained(copiedBuffer).toOpaque())
             CMSimpleQueueEnqueue(queue, element: pointerRef)
         } else {
             print("Failed to create a copy of the sample buffer")
         }
     }
}



