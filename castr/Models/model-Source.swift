//
//  model-Source.swift
//  castr
//
//  Created by Harrison Hall on 8/4/24.
//

import Foundation
import SwiftUI
import ScreenCaptureKit
import Combine

class SourceModel: Identifiable, ObservableObject {
    
    let id: String
    let type: SourceType
    @Published var name: String
    @Published var isHidden: Bool
    @Published var scenes: [String]
    
    init(type: SourceType, name: String) {
        self.id = UUID().uuidString
        self.type = type
        self.name = name
        self.isHidden = false
        self.scenes = []
    }
}

        
        class ScreenCaptureSourceModel: SourceModel {
            
            private let previewer = Previewer.shared
            var layer: CALayer = CALayer()
            
            // TODO: Create available displays variable
            // TODO: Create available apps variable
            // TODO: Create available windows variable
            @Published var availableDisplays = [SCDisplay]()
            @Published var availableApps = [SCRunningApplication]()
            @Published var availableWindows = [SCWindow]()
            @Published var selectedDisplay: SCDisplay?
            @Published var excludedApps: [String]
            
            private var contentRefreshTimer: AnyCancellable?
            
            init(name: String) {
                self.excludedApps = []
                super.init(type: .screenCapture, name: name)
//                Task {
//                    await self.refreshAvailableContent()
//                }
            }
            
            func start() async {
                
                Task {
                    // TODO: Refresh the available content once
                    await self.refreshAvailableContent()
                    
                    guard let display = selectedDisplay else { return }
                    
                    // TODO: Create the ScreenRecorder and pass in the CALayer
                    let screenRecorder = await ScreenRecorder(
                        capturePreview: layer,
                        availableDisplays: availableDisplays,
                        availableApps: availableApps,
                        availableWindows: availableWindows,
                        selectedDisplay: display
                    )
                    
                    // TODO: Set the CALayer to be take up the full width and height of its superlayer by default
                    layer.frame = previewer.contentLayer.bounds
                    layer.contentsGravity = .resizeAspect
                    
//                    layer.backgroundColor = NSColor(.white).cgColor
//                    print("adding the selected")
                    
                    // TODO: Add the CALayer to the super Layer which is previewer.contentLayer
                    previewer.contentLayer.addSublayer(layer)
                    
                   
                    await screenRecorder.start()
                }
            }
            
            func stop() {
                
                // TODO: Remove the image from the super layer CALayer which is previewer.contentLayer
                layer.removeFromSuperlayer()
                
                // TODO: Reset the CALayer
                layer.contents = nil
                layer = CALayer()
                
                // TODO: Stop monitoring the available content
                
                // TODO: 
            }
            
            
            func startMonitoringAvailableContent() async {
                print("starting to monitor available content")
                await self.refreshAvailableContent()
                contentRefreshTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { [weak self] _ in
                    guard let self = self else { return }
                    Task {
                        await self.refreshAvailableContent()
                    }
                }
            }
            
            func stopMonitoringAvailableContent() {
                print("stopping monitoring available content")
                contentRefreshTimer?.cancel()
                contentRefreshTimer = nil
            }
            
            func refreshAvailableContent() async {
                print("monitoring available content")
                do {
                    // Retrieve the available screen content to capture.
                    let availableContent = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
                    
                    await MainActor.run {
                        availableDisplays = availableContent.displays
                        availableWindows = filterWindows(availableContent.windows)
                        availableApps = filterApplications(availableContent.applications)
                        
                        if selectedDisplay == nil {
                            selectedDisplay = availableDisplays.first
                        }
                    }
                } catch {
//                    logger.error("Failed to get the shareable content: \(error.localizedDescription)")
                }
            }
            
            private func filterWindows(_ windows: [SCWindow]) -> [SCWindow] {
                // Sort the windows by app name.
                windows.sorted { $0.owningApplication?.applicationName ?? "" < $1.owningApplication?.applicationName ?? "" }
            }
            
            private func filterApplications(_ applications: [SCRunningApplication]) -> [SCRunningApplication] {
                applications
                    .filter { $0.applicationName.isEmpty == false }
                    .sorted { $0.applicationName.lowercased() < $1.applicationName.lowercased() }
            }
                
        }


        class WindowCaptureSourceModel: SourceModel {
            
            private let previewer = Previewer.shared
            var layer: CALayer = CALayer()
            
            @Published var window: String

            init(name: String) {
                self.window = ""
                super.init(type: .windowCapture, name: name)
            }
            
            func startMonitoringAvailableContent() async {
                
            }
            
            func stopMonitoringAvailableContent() {
               
            }
        }


        class ImageSource: SourceModel {
            private let previewer = Previewer.shared
            var layer: CALayer = CALayer()
            
            @Published var imagePath: String
            
            init(name: String) {
                self.imagePath = ""
                super.init(type: .image, name: name)
            }
            
            func start() {
                // TODO: Create the image
                guard let image = NSImage(contentsOfFile: imagePath) else { return }
                
                // TODO: Set the image to the CALayer
                layer.contents = image
                
                // TODO: Set the CALayer to be take up the full width and height of its superlayer by default
                layer.frame = previewer.contentLayer.bounds
                layer.contentsGravity = .resizeAspect
                
                // TODO: Add the CALayer to the super Layer which is previewer.contentLayer
                previewer.contentLayer.addSublayer(layer)
            }
            
            func stop() {
                // TODO: Remove the image from the super layer CALayer which is previewer.contentLayer
                layer.removeFromSuperlayer()
                
                // TODO: Reset the CALayer
                layer.contents = nil
                layer = CALayer()
            }
         
        }


        class ColorSource: SourceModel {
            private let previewer = Previewer.shared
            var layer: CALayer = CALayer()
            
            @Published var color: NSColor
            
            init(name: String) {
                self.color = .white
                super.init(type: .image, name: name)
            }
            
            func start() {
                // TODO: Set the color of the CALayer
                layer.backgroundColor = color.cgColor
                
                // TODO: Set the CALayer to be take up the full width and height of its superlayer by default
                layer.frame = previewer.contentLayer.bounds
                layer.contentsGravity = .resizeAspect
                
                // TODO: Add the CALayer to the super Layer which is previewer.contentLayer
                previewer.contentLayer.addSublayer(layer)
            }
            
            func stop() {
                // TODO: Remove the image from the super layer CALayer which is previewer.contentLayer
                layer.removeFromSuperlayer()
                
                // TODO: Reset the CALayer
                layer.contents = nil
                layer = CALayer()
            }
        }
