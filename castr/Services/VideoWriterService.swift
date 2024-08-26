//
//  VideoWriterService.swift
//  castr
//
//  Created by Harrison Hall on 8/26/24.
//

import AVFoundation
import AppKit

class VideoWriter {
    private let videoWriterQueue = DispatchQueue(label: "com.yourdomain.videowriter", qos: .userInitiated)
    private var assetWriter: AVAssetWriter?
    private var assetWriterInput: AVAssetWriterInput?
    private var isSessionStarted = false
    private var outputURL: URL?

    func setupDefaultSaveLocation() -> Bool {
        let fileManager = FileManager.default
        
        // Get the path to the user's Desktop
        guard let desktopURL = fileManager.urls(for: .desktopDirectory, in: .userDomainMask).first else {
            print("Failed to setup save location: Unable to access Desktop directory")
            return false
        }
        
        // Create a unique filename
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let timestamp = dateFormatter.string(from: Date())
        let filename = "output_\(timestamp).mp4"
        
        // Combine the desktop path with the filename
        let saveURL = desktopURL.appendingPathComponent(filename)
        
        self.outputURL = saveURL
        print("Save location setup successfully: \(saveURL.path)")
        return true
    }

    func setupAssetWriter(width: Int, height: Int) -> Bool {
        guard let outputURL = self.outputURL else {
            print("Failed to setup asset writer: Output URL not set. Call setupDefaultSaveLocation first.")
            return false
        }

        var setupSuccess = false
        let setupGroup = DispatchGroup()
        setupGroup.enter()

        videoWriterQueue.async {
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
                        print("Asset writer setup successfully")
                        setupSuccess = true
                    } else {
                        print("Failed to setup asset writer: Cannot add input to asset writer")
                    }
                } else {
                    print("Failed to setup asset writer: AssetWriter or AssetWriterInput is nil")
                }
            } catch {
                print("Failed to setup asset writer: \(error)")
            }
            
            setupGroup.leave()
        }

        setupGroup.wait()
        return setupSuccess
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
