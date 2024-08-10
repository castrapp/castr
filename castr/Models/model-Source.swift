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
            
//            private let previewer = Previewer.shared
            var layer: CALayer = CALayer()
            
            // TODO: Create available displays variable
            // TODO: Create available apps variable
            // TODO: Create available windows variable
            @Published var availableDisplays = [SCDisplay]()
            @Published var availableApps = [SCRunningApplication]()
            @Published var availableWindows = [SCWindow]()
            @Published var selectedDisplay: SCDisplay?
            @Published var excludedApps: Set<String> {
                didSet {
                    print("new thing was added or removed")
                    Task { @MainActor in
                        screenRecorder?.updateExcludedApps(excludedApps: excludedApps)
                    }
                }
            }
            
            private var contentRefreshTimer: AnyCancellable?
            private var cancellables: Set<AnyCancellable> = []
            private var screenRecorder: ScreenRecorder?
            
            init(name: String) {
                self.excludedApps = []
                super.init(type: .screenCapture, name: name)
                
                setupObservers()
                print("INITIALIZING SCREEN CAPTURE")
            }
            
            deinit {
                Task { @MainActor in
                    await stop()
                }
                cancellables.forEach { $0.cancel() }
            }
            
            private func setupObservers() {
                GlobalState.shared.$selectedSceneId.sink { [weak self] newSceneId in
                    self?.handleSceneChange(newSceneId)
                }
                .store(in: &cancellables)
                
                GlobalState.shared.$selectedSourceId.sink { [weak self] newSourceId in
                    self?.handleSourceChange(newSourceId)
                }
                .store(in: &cancellables)
            }
            
            private func handleSceneChange(_ newSceneId: String) {
                
            // TODO: Whenever the selectedSceneId changes, we nede to iterate through the list
            // TODO: of sources, all of them, and do 2 checks:
            //
            //              • If there 'scenes' array DOES CONTAIN the selectedSceneId then:
            //                then call 'start' or something.
            //
            //              • If there 'scenes' array DOES NOT CONTAIN the selectedSceneId then:
            //                then call 'stop' or something.
                
                Task { @MainActor in
                    scenes.contains(newSceneId) ? await start() : await stop()
                }
            }
            
            func handleSourceChange(_ newSourceId: String) {
                
            // TODO: iterate through all of the global sources and if the source type is
            // TODO: .screencapture or .windowcapture, then check if the selectedSourceId
            // TODO: is equal to the selectedSourcesId or not:
            // TODO: (This logic will need to be slightly changed at some point to make sure we don't double poll)
            //
            //  If the selectedSourceId IS EQUAL to the source's Id, then:
            //  • Call startMonitoringAvailableContent()
            //
            //  If the selectedSourceId IS NOT EQUAL to the source's Id, then:
            //  • Call stopMonitoringAvailableContent ()
            //
                
                if(newSourceId == id) {
//                    Task { await startMonitoringAvailableContent() }
                } else {
                    stopMonitoringAvailableContent()
                }
            }
            
            @MainActor
            func start() async {
                
                    // TODO: Refresh the available content once
                    await self.refreshAvailableContent()
                    
                    guard let display = selectedDisplay, screenRecorder == nil else { return }
                    
                    // TODO: Create the ScreenRecorder and pass in the CALayer
                    screenRecorder = ScreenRecorder(
                        capturePreview: layer,
                        availableDisplays: availableDisplays,
                        availableApps: availableApps,
                        availableWindows: availableWindows,
                        selectedDisplay: display,
                        excludedApps: excludedApps
                    )
                    
                    // TODO: Set the CALayer to be take up the full width and height of its superlayer by default
                    layer.frame = Previewer.shared.contentLayer.bounds
                    layer.contentsGravity = .resizeAspect
                    
                    // TODO: Add the CALayer to the super Layer which is previewer.contentLayer
                    Previewer.shared.contentLayer.addSublayer(layer)
                    
                print("SCREEN RECORDER IS: ", screenRecorder)
                    await screenRecorder?.start()
                    
            }
            
            @MainActor
            func stop() async {
                
                // TODO: Remove the image from the super layer CALayer which is previewer.contentLayer
                layer.removeFromSuperlayer()
                
                // TODO: Reset the CALayer
                layer.contents = nil
                
                // TODO: Stop monitoring the available content
                stopMonitoringAvailableContent()
                
                print("STOPPING")
                // TODO: Stop the screen recorder
              
                await screenRecorder?.stop()
                screenRecorder = nil
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
                do {
                    // Retrieve the available screen content to capture.
                    let availableContent = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
                    
                    await MainActor.run {
                        print("monitoring available content")
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
            
            func startMonitoringAvailableContent()  {
                
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
            
             func start() async {
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
            
            func start() async {
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
