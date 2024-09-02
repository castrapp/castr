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

    deinit {
        if let url = outputURL {
            url.stopAccessingSecurityScopedResource()
        }
    }
    
    func setupDefaultSaveLocation() -> Bool {
          guard let sharedDefaults = UserDefaults(suiteName: settingsDefaultsIdentifier),
                let recordingSettings = sharedDefaults.dictionary(forKey: "recordingSettings"),
                let savedPath = recordingSettings["outputDestination"] as? String,
                let bookmarkData = recordingSettings["outputDestinationBookmark"] as? Data else {
              print("Failed to setup save location: No saved output destination")
              return false
          }

          var isStale = false
          do {
              let url = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
              if url.startAccessingSecurityScopedResource() {
                  let fileManager = FileManager.default
                  
                  // Create a unique filename
                  let dateFormatter = DateFormatter()
                  dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
                  let timestamp = dateFormatter.string(from: Date())
                  let filename = "output_\(timestamp).mp4"
                  
                  // Combine the selected path with the filename
                  let saveURL = url.appendingPathComponent(filename)
                  
                  self.outputURL = saveURL
                  print("Save location setup successfully: \(saveURL.path)")
                  return true
              } else {
                  print("Failed to access security-scoped resource")
                  return false
              }
          } catch {
              print("Failed to resolve bookmark: \(error)")
              return false
          }
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
                    AVVideoHeightKey: height,
                    AVVideoCompressionPropertiesKey: [
                        AVVideoAverageBitRateKey: 50_000_000, // 50 Mbps, adjust based on quality needs
                        AVVideoMaxKeyFrameIntervalKey: 60, // Keyframes every second at 120 FPS
                        AVVideoExpectedSourceFrameRateKey: 60, // Set the frame rate to 120 FPS
                        AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel,
                   ],
                    AVVideoColorPropertiesKey: [
                            AVVideoColorPrimariesKey: AVVideoColorPrimaries_ITU_R_709_2,
                            AVVideoTransferFunctionKey: AVVideoTransferFunction_ITU_R_709_2,
                            AVVideoYCbCrMatrixKey: AVVideoYCbCrMatrix_ITU_R_709_2
                        ]
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
                print(sampleBuffer.imageBuffer)
                assetWriterInput.append(sampleBuffer)
            } else {
                print("AssetWriterInput is not ready for more data")
            }
        }
    }
}
