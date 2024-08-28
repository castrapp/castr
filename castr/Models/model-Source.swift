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
import AVFoundation
import MetalKit

class SourceModel: Identifiable, ObservableObject {
    
    let id: String
    let type: SourceType
    @Published var name: String
    @Published var isHidden: Bool
    @Published var scenes: [String]
    var layer: CAMetalLayer = CAMetalLayer()
    var mtlTexture: MTLTexture?
    
    init(type: SourceType, name: String) {
        self.id = UUID().uuidString
        self.type = type
        self.name = name
        self.isHidden = false
        self.scenes = []
    }
    
}

        
        class ScreenCaptureSourceModel: SourceModel {
            
    
            
            // TODO: Create available displays variable
            // TODO: Create available apps variable
            // TODO: Create available windows variable
            @Published var availableDisplays = [SCDisplay]()
            @Published var availableApps = [SCRunningApplication]()
            @Published var availableWindows = [SCWindow]()
            @Published var selectedDisplay: SCDisplay? {
                didSet {
                    guard let selectedDisplay = selectedDisplay else { return }
                    print("updating selected display")
                    Task { @MainActor in
                        screenRecorder?.updateSelectedDisplay(display: selectedDisplay)
                    }
                }
            }
            @Published var excludedApps: Set<String> {
                didSet {
                    print("updating excluded apps")
                    Task { @MainActor in
                        screenRecorder?.updateExcludedApps(excludedApps: excludedApps)
                    }
                }
            }
            
            private var contentRefreshTimer: AnyCancellable?
            private var cancellables: Set<AnyCancellable> = []
            private var screenRecorder: ScreenRecorder3?
            
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
                print("DE-INITIALIZING SCREEN CAPTURE")
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
                    Task { await startMonitoringAvailableContent() }
                } else {
                    stopMonitoringAvailableContent()
                }
            }
            
            @MainActor
            func start() async {

                // TODO: Refresh the available content once
                await self.refreshAvailableContent()
                
                guard let display = selectedDisplay, screenRecorder == nil else { return }
                
                
                // TODO: Refactor this such that we only pass in 3 things: the layer, the excluded apps, and the selected display.
                screenRecorder = ScreenRecorder3(
                    capturePreview: layer,
                    availableDisplays: availableDisplays,
                    availableApps: availableApps,
                    availableWindows: availableWindows,
                    excludedApps: excludedApps,
                    selectedDisplay: display,
                    model: self
                )
                
                // TODO: Add the CALayer to the super Layer which is previewer.contentLayer
                Previewer.shared.contentLayer.addSublayer(layer)
                
                await screenRecorder?.start()
            }
            
            @MainActor
            func stop() async {
                
                // TODO: Remove the image from the super layer CALayer which is previewer.contentLayer
                layer.removeFromSuperlayer()
                
                // TODO: Reset the CALayer
                layer.contents = nil
                
                layer = CAMetalLayer()
                
                // TODO: Stop monitoring the available content
                stopMonitoringAvailableContent()
                
                print("STOPPING")
                // TODO: Stop the screen recorder
              
                await screenRecorder?.stop()
                screenRecorder = nil
            }
            
            
            func startMonitoringAvailableContent() async {
//                print("starting to monitor available content")
                await self.refreshAvailableContent()
                contentRefreshTimer = Timer.publish(every: 2, on: .main, in: .common).autoconnect().sink { [weak self] _ in
                    guard let self = self else { return }
                    Task {
                        await self.refreshAvailableContent()
                    }
                }
            }
            
            func stopMonitoringAvailableContent() {
//                print("stopping monitoring available content")
                contentRefreshTimer?.cancel()
                contentRefreshTimer = nil
            }
            
            func refreshAvailableContent() async {
                do {
                    // Retrieve the available screen content to capture.
                    let availableContent = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
                    
                    await MainActor.run {
//                        print("monitoring available content")
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
            
//            var layer: CAMetalLayer = CAMetalLayer()
            
            // TODO: Create available displays variable
            // TODO: Create available apps variable
            // TODO: Create available windows variable
            @Published var availableDisplays = [SCDisplay]()
            @Published var availableApps = [SCRunningApplication]()
            @Published var availableWindows = [SCWindow]()
            @Published var selectedDisplay: SCDisplay?
            @Published var selectedWindow: SCWindow? {
                didSet {
                    guard let window = selectedWindow else { return }
                    print("the window has been changed")
                    Task { @MainActor in
                        screenRecorder?.updateSelectedWindow(selectedWindow: window)
                    }
                }
            }
            
            private var contentRefreshTimer: AnyCancellable?
            private var cancellables: Set<AnyCancellable> = []
            private var screenRecorder: ScreenRecorder?
            
            init(name: String) {
                super.init(type: .windowCapture, name: name)
                
                setupObservers()
                print("INITIALIZING WINDOW CAPTURE")
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
                        selectedWindow: availableWindows.first
                    )
                    
                    // TODO: Set the CALayer to be take up the full width and height of its superlayer by default
                    layer.frame = Previewer.shared.contentLayer.bounds
                    layer.contentsGravity = .resizeAspect
                    layer.backgroundColor = CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
                
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




        class ImageSourceModel: SourceModel {

            @Published var imageURL: URL? {
                didSet {
                    guard let url = imageURL else { return }
                   
                    print("GOT A NEW IMAGE URL", imageURL )
                    do {
                        let newTexture = try loadTextureUsingMetalKit(url: url)
                        print("new Texture is: ", newTexture)
                    } catch {
                        fatalError("Metal loader failed: \(error)")
                    }
                    
                }
            }
            
            override var mtlTexture: MTLTexture? {
                didSet {
                    guard let texture = mtlTexture else { return }
                    print("METAL TEXTURE HAS CHANGED: ", mtlTexture)
                    
                    let scalingfactor = Previewer.shared.contentLayer.frame.width / 3456
                    print("The scaling factor is: ", scalingfactor)
                    
                    layer.device = MetalService.shared.device
                    layer.pixelFormat = .bgra8Unorm
                    layer.framebufferOnly = true
//                    layer.frame = Previewer.shared.contentLayer.frame
                    layer.frame = CGRect(
                        origin: CGPoint(x: 0, y: 0),
                        size: CGSize(
                            width: CGFloat(texture.width) * scalingfactor,
                            height: CGFloat(texture.height) * scalingfactor
                        )
                    )
//                    layer.contentsGravity = .resizeAspect
//                    layer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
                    print("the previewers frame is: ", Previewer.shared.contentLayer.frame)
                    print("the previews bounds are: ", Previewer.shared.contentLayer.bounds)
                    
                    
                    layer.borderColor = CGColor(red: 0.0, green: 1.0, blue: 0, alpha: 1.0)
                    layer.borderWidth = CGFloat(1)
                    
                    print("drawing this texture to the layer: ", texture)

                    MetalService.shared.drawMetalTextureToLayer(texture: texture, metalLayer: layer)
             
                }
            }
            
            @Published var image: NSImage? {
                didSet {
                    Task { @MainActor in
                        if let image = image {
                            updateImage(image)
                            print("image is changing: ", image)
                        }
                    }
                }
            }
            
            private var cancellables: Set<AnyCancellable> = []
            
            init(name: String) {
                super.init(type: .image, name: name)
                layer.device = MetalService.shared.device
                
                setupObservers()
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
                
                print("scene is CHANGING")
                Task { @MainActor in
                    scenes.contains(newSceneId) ? await start() : await stop()
                }
            }
            
            @MainActor
            private func updateImage(_ newImage: NSImage) {
                print("updating with new image: ", newImage)
            
            }
            
            
            func loadTextureUsingMetalKit(url: URL) throws -> MTLTexture {
                let loader = MTKTextureLoader(device: device)
                
                return try loader.newTexture(URL: url, options: nil)
            }
            
            
            @MainActor
             func start() async {
                 
                // TODO: Create the image
              
                 
    
                 
                // TODO: Add the CALayer to the super Layer which is previewer.contentLayer
                Previewer.shared.contentLayer.addSublayer(layer)
            }
            
            @MainActor
            func stop() async {
                // TODO: Remove the image from the super layer CALayer which is previewer.contentLayer
                layer.removeFromSuperlayer()
                
                // TODO: Reset the CALayer
                layer.contents = nil
            }
            
         
            
            
         
        }




        class ColorSourceModel: SourceModel {
//            var layer: CALayer = CALayer()
            
            @Published var color: Color = .white {
                didSet {
                    Task { @MainActor in
                        changeColor()
                    }
                }
            }
            
            private var cancellables: Set<AnyCancellable> = []
            
            init(name: String) {
                super.init(type: .color, name: name)
                
                setupObservers()
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
                
                print("scene is CHANGING")
                Task { @MainActor in
                    scenes.contains(newSceneId) ? await start() : await stop()
                }
            }
            
            @MainActor
            func changeColor() {
                layer.backgroundColor = color.cgColor
            }
            
            @MainActor
            func start() async {
                // TODO: Set the color of the CALayer
                layer.backgroundColor = color.cgColor
                
                // TODO: Set the CALayer to be take up the full width and height of its superlayer by default
                layer.frame = Previewer.shared.contentLayer.bounds
                layer.contentsGravity = .resizeAspect
                
                // TODO: Add the CALayer to the super Layer which is previewer.contentLayer
                Previewer.shared.contentLayer.addSublayer(layer)
            }
            
            @MainActor
            func stop() async {
                // TODO: Remove the image from the super layer CALayer which is previewer.contentLayer
                layer.removeFromSuperlayer()
                
                // TODO: Reset the CALayer
                layer.contents = nil
//                layer = CALayer()
            }
        }





        class TextSourceModel: SourceModel {
//            var layer: CATextLayer = CATextLayer()
            
            @Published var text: String = "" {
                didSet {
                    Task { @MainActor in
                        print("text has changed too: ", text)
//                        layer.string = text
                    }
                }
            }
            @Published var fontSize: CGFloat = 20 {
                didSet {
                    Task { @MainActor in
                        print("text has changed too: ", text)
//                        layer.fontSize = fontSize
                    }
                }
            }
            @Published var color: Color = .white {
                didSet {
                    Task { @MainActor in
                        print("color has changed")
//                        layer.foregroundColor = color.cgColor
                    }
                }
            }
            
            private var cancellables: Set<AnyCancellable> = []
            
            init(name: String) {
                super.init(type: .text, name: name)
                
                setupObservers()
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
                
                print("scene is CHANGING")
                Task { @MainActor in
                    scenes.contains(newSceneId) ? await start() : await stop()
                }
            }

            
            @MainActor
            func start() async {
                // TODO: Set the text of the CATextLayer
//                layer.string = text
//                layer.fontSize = fontSize // Adjust as needed
//                layer.foregroundColor = color.cgColor
                
                // TODO: Set the color of the CATextLayer
                layer.backgroundColor = .clear
                
                // TODO: Set the CATextLayer to be take up the full width and height of its superlayer by default
                layer.frame = Previewer.shared.contentLayer.bounds
                layer.contentsGravity = .resizeAspect
                
                // TODO: Add the CATextLayer to the super Layer which is previewer.contentLayer
                Previewer.shared.contentLayer.addSublayer(layer)
            }
            
            @MainActor
            func stop() async {
                // TODO: Remove the image from the super layer CALayer which is previewer.contentLayer
                layer.removeFromSuperlayer()
                
                // TODO: Reset the CATextLayer
                layer.contents = nil
//                layer = CATextLayer()
            }
        }






        class VideoSourceModel: SourceModel {
//            var layer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer()
            private var captureSession: AVCaptureSession?
            
            @Published var availableCameras: [AVCaptureDevice] = []
            @Published var selectedCamera: AVCaptureDevice? {
                didSet {
                    Task { @MainActor in
                        await updateCaptureDevice()
                    }
                }
            }
            
            private var cancellables: Set<AnyCancellable> = []
            
            init(name: String) {
                super.init(type: .video, name: name)
                
                setupObservers()
                fetchAvailableCameras()
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
            }
            
            private func handleSceneChange(_ newSceneId: String) {
                print("scene is changing")
                Task { @MainActor in
                    scenes.contains(newSceneId) ? await start() : await stop()
                }
            }
            
            private func fetchAvailableCameras() {
                availableCameras = AVCaptureDevice.DiscoverySession(
                    deviceTypes: [.builtInWideAngleCamera, .externalUnknown],
                    mediaType: .video,
                    position: .unspecified
                ).devices
                
                selectedCamera = availableCameras.first
            }
            
            @MainActor
            private func updateCaptureDevice() async {
                await stop()
                await start()
            }
            
            @MainActor
            func start() async {
                guard let camera = selectedCamera else { return }
                
                captureSession = AVCaptureSession()
                
                do {
                    let input = try AVCaptureDeviceInput(device: camera)
                    captureSession?.addInput(input)
                } catch {
                    print("Failed to set camera input: \(error.localizedDescription)")
                    return
                }
                
//                layer = AVCaptureVideoPreviewLayer(session: captureSession!)
//                layer.videoGravity = .resizeAspect
                layer.frame = Previewer.shared.contentLayer.bounds
                
                Previewer.shared.contentLayer.addSublayer(layer)
                
                captureSession?.startRunning()
                print("starting video")
                
            }
            
            @MainActor
            func stop() async {
                captureSession?.stopRunning()
                layer.removeFromSuperlayer()
                
                // Properly clean up the capture session
                if let inputs = captureSession?.inputs as? [AVCaptureDeviceInput] {
                    for input in inputs {
                        captureSession?.removeInput(input)
                    }
                }
                
                captureSession = nil
                layer.contents = nil
                
                print("stopping video")
            }
        }
