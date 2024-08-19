//
//  view-ControlsPanel.swift
//  castr
//
//  Created by Harrison Hall on 8/4/24.
//

import SwiftUI
import AVFoundation
import Cocoa
import CoreMediaIO
import SystemExtensions
import ScreenCaptureKit
import OSLog
import Combine

struct ControlsPanel: View {
    
    @State var isHovered = false
    @ObservedObject var global = GlobalState.shared
     @State private var assetWriter: AVAssetWriter?
     @State private var assetWriterInput: AVAssetWriterInput?
     @State private var isRecording = false
    
    
    var body: some View {
        CustomGroupBox {
            HStack {
                Text("Controls").sourcesTextStyle()
                
                Spacer()
               
            }
            .frame(maxWidth: .infinity, maxHeight: 30, alignment: .leading)
//            .border(Color.red, width: 1)
            .cornerRadius(5)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
//                    .stroke(Color.red, lineWidth: 1)
                    .fill(isHovered ? Color(nsColor: .quinaryLabel) : Color.clear)
            )
            .padding(5)
            .onHover { hovering in
                isHovered = hovering
            }

            Spacer().panelMainSeparatorStyle()
            
            HStack {

                
//                Button("Stream to Virtual Camera") {
//                    CameraViewModel.shared.start()
//                    GlobalState.shared.streamToVirtualCamera = true
//                }
//                .multilineTextAlignment(.center)
//                .lineLimit(nil)
//                .fixedSize(horizontal: false, vertical: true)
//                .disabled(global.selectedSourceId.isEmpty)

                
               
            }
           
//            .frame(maxWidth: 100, maxHeight: 100, alignment: .leading)
//            .fixedSize(horizontal: true, vertical: true)
            .padding(10)
        }
        .padding(10)
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
    }
    
    func getDevice() {
      
        // 1. Find the device
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.externalUnknown], mediaType: .video,position: .unspecified)
        guard let targetDevice = discoverySession.devices.first(where: { $0.localizedName == "Castr Virtual Camera" }) else { return }

        
        
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
        if streamIds.count == 2 {
            print("Sink Stream found")
//            sinkStream = streamIds[1]
//            initSink(deviceId: deviceObjectId, sinkStream: streamIds[1])
        }
        
    }
    
    
    
    func getInputStreams(deviceId: CMIODeviceID) -> [CMIOStreamID] {
        var dataSize: UInt32 = 0
        var dataUsed: UInt32 = 0
        var opa = CMIOObjectPropertyAddress(CMIOObjectPropertySelector(kCMIODevicePropertyStreams), .global, .main)
        CMIOObjectGetPropertyDataSize(deviceId, &opa, 0, nil, &dataSize);
        let numberStreams = Int(dataSize) / MemoryLayout<CMIOStreamID>.size
        var streamIds = [CMIOStreamID](repeating: 0, count: numberStreams)
        CMIOObjectGetPropertyData(deviceId, &opa, 0, nil, dataSize, &dataUsed, &streamIds)
        return streamIds
    }

    


}



