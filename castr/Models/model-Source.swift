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

class CustomMetalLayer: CAMetalLayer {
    override func resize(withOldSuperlayerSize oldSize: CGSize) {

        guard let newSize = superlayer?.frame.size else { return }
        
        let scale = (newSize.width / oldSize.width)
        
//        self.frame = CGRect(
//            origin: CGPoint(
//                x: self.frame.origin.x * scale,
//                y: self.frame.origin.y * scale
//            ),
//            size: CGSize(
//                width: self.frame.width * scale,
//                height: self.frame.height * scale
//            )
//        )
        
    }
}




class SourceModel: Identifiable, ObservableObject {
    
    let id: String
    let type: SourceType
    @Published var name: String
    @Published var isActive: Bool {
        didSet { layer.isHidden = !isActive }
    }
    @Published var scenes: [String]
    var layer: CAMetalLayer = CustomMetalLayer()
    var mtlTexture: MTLTexture?
    
    init(type: SourceType, name: String) {
        self.id = UUID().uuidString
        self.type = type
        self.name = name
        self.isActive = true
        self.scenes = []
        layer.name = self.id
        
    }
    
}

        
        class ScreenCaptureSourceModel: SourceModel {
            
            @Published var excludedApps: Set<String> = Set<String>()
            @Published var selectedDisplay: String = ""
            @Published var screenRecorder: ScreenRecorder4?
            
            init(name: String) {
                super.init(type: .screenCapture, name: name)
                self.excludedApps = []
                
//                print("INITIALIZING SCREEN CAPTURE")
            
            }
            
        
     
            @MainActor
            func start() {
                layer.frame.size = Main.shared.preview.frame.size
                Main.shared.preview.addSublayer(layer)
//                layer.borderColor = CGColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
//                layer.borderWidth = 1.0
                
                print("previewers origin is: ", Main.shared.preview.frame.origin)
                screenRecorder = ScreenRecorder4(model: self)
                Task { @MainActor in
                    await screenRecorder?.start()
                }
            }
            
         
            func stop() {
                
                layer.removeFromSuperlayer()
                layer.contents = nil
                
                Task { @MainActor in
                    await screenRecorder?.stop()
                    screenRecorder = nil
                }
               
            }
            
        }






        class WindowCaptureSourceModel: SourceModel {
            

            @Published var availableDisplays = [SCDisplay]()
            @Published var availableApps = [SCRunningApplication]()
            @Published var availableWindows = [SCWindow]()
            @Published var selectedDisplay: SCDisplay?
            @Published var selectedWindow: SCWindow? {
                didSet {
//                    guard let window = selectedWindow else { return }
//                    print("the window has been changed")
//                    Task { @MainActor in
//                        screenRecorder?.updateSelectedWindow(selectedWindow: window)
//                    }
                }
            }
            
            private var contentRefreshTimer: AnyCancellable?
            private var cancellables: Set<AnyCancellable> = []
//            private var screenRecorder: ScreenRecorder?
            
            init(name: String) {
                super.init(type: .windowCapture, name: name)
//                
//                setupObservers()
//                print("INITIALIZING WINDOW CAPTURE")
            }
            
           
            
         
            @MainActor
            func start() async {
               
                    
            }
            
            @MainActor
            func stop() async {
              
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
                    
                    let scalingfactor = Main.shared.preview.frame.width / 3456
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
//                    layer.autoresizingMask = [.layerMaxXMargin, .layerMaxYMargin, .layerHeightSizable, .layerWidthSizable]
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
            
            
            init(name: String) {
                super.init(type: .image, name: name)
                layer.device = MetalService.shared.device
                layer.name = self.id
                
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
                Main.shared.preview.addSublayer(layer)
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
