//
//  view-ControlsPanel.swift
//  castr
//
//  Created by Harrison Hall on 8/4/24.
//

import Foundation
import SwiftUI
import AVFoundation

struct ControlsPanel: View {
    
    @State var isHovered = false

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
            .onContinuousHover { phase in
                switch phase {
                case .active:
                    NSCursor.openHand.push()
                case .ended:
                    NSCursor.pop()
                }
            }
            
            Spacer().panelMainSeparatorStyle()
            
            HStack {
                CustomControlBox(
                    title: "start recording",
                    subtitle: "world",
                    isSelected: false,
                    onPress: {
                        print("starting recording")
                        showSavePanel()
                    }
                ) {
                    Text("Hello")
                }
                
                CustomControlBox(
                    title: "stop recording",
                    subtitle: "world",
                    isSelected: false,
                    onPress: {
                        // When you're done:
                        stopRecording()
                        
                    }
                ) {
                    Text("Hello")
                }
                Spacer()
            }
           
//            .frame(maxWidth: 100, maxHeight: 100, alignment: .leading)
//            .fixedSize(horizontal: true, vertical: true)
            .padding(10)
        }
        .padding(10)
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
    }
    
    func showSavePanel() {
            let savePanel = NSSavePanel()
            savePanel.allowedContentTypes = [.mpeg4Movie]
            savePanel.canCreateDirectories = true
            savePanel.nameFieldStringValue = "output.mp4"
            
            savePanel.begin { response in
                if response == .OK, let url = savePanel.url {
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.startConverter(outputURL: url)
                    }
                }
            }
        }
    
    func startConverter(outputURL: URL) {
        print("attempting to start converter")
        guard !isRecording else { return }
        
        print("starting converter")
        do {
            assetWriter = try AVAssetWriter(outputURL: outputURL, fileType: .mov)
            
            let videoSettings: [String: Any] = [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: 868,
                AVVideoHeightKey: 561
            ]
            
            assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
            assetWriterInput?.expectsMediaDataInRealTime = true
            
            if let assetWriter = assetWriter, let assetWriterInput = assetWriterInput {
                assetWriter.add(assetWriterInput)
                assetWriter.startWriting()
                assetWriter.startSession(atSourceTime: CMTime.zero)
                
                isRecording = true
                
                LayerToSampleBufferConverter.shared.start { sampleBuffer in
                    if assetWriterInput.isReadyForMoreMediaData {
                        print("sample buffer is: ", sampleBuffer)
                        assetWriterInput.append(sampleBuffer)
                    }
                }
            }
        } catch {
            print("Error setting up asset writer: \(error)")
        }
    }
    
    func stopRecording() {
        guard isRecording else { return }
        
        LayerToSampleBufferConverter.shared.stop()
        
        assetWriterInput?.markAsFinished()
        assetWriter?.finishWriting {
            print("Finished writing video to: \(self.assetWriter?.outputURL.path ?? "unknown")")
            self.assetWriter = nil
            self.assetWriterInput = nil
            self.isRecording = false
        }
    }
}



