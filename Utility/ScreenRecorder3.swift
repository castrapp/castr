
import Foundation
import ScreenCaptureKit
import Combine
import OSLog
import SwiftUI

/// A provider of audio levels from the captured samples.


@MainActor
class ScreenRecorder3: NSObject, ObservableObject {
    
    /// The supported capture types.
    enum CaptureType {
        case display
        case window
    }
    
    var capturePreview: CAMetalLayer
    var availableDisplays: [SCDisplay]
    var availableApps: [SCRunningApplication]
    var availableWindows: [SCWindow]
    var excludedApps: Set<String>? { didSet { updateEngine() } }
    var selectedDisplay: SCDisplay { didSet { updateEngine() } }
    var selectedWindow: SCWindow? { didSet { updateEngine() } }
    var model: ScreenCaptureSourceModel

    init(
        capturePreview: CAMetalLayer,
        availableDisplays: [SCDisplay],
        availableApps: [SCRunningApplication],
        availableWindows: [SCWindow],
        excludedApps: Set<String> = Set(),
        selectedDisplay: SCDisplay,
        selectedWindow: SCWindow? = nil,
        model: ScreenCaptureSourceModel
    ) {
        self.capturePreview = capturePreview
        self.availableDisplays = availableDisplays
        self.availableApps = availableApps
        self.availableWindows = availableWindows
        self.excludedApps = excludedApps
        self.selectedDisplay = selectedDisplay
        self.selectedWindow = selectedWindow
        self.model = model
    }
    
    private let logger = Logger()
    
    @Published var isRunning = false
    @Published var captureType: CaptureType = .display {
        didSet { updateEngine() }
    }


    @Published var isAppExcluded = true {
        didSet { updateEngine() }
    }
    @Published var contentSize = CGSize(width: 1, height: 1)
    private var scaleFactor: Int { Int(NSScreen.main?.backingScaleFactor ?? 2) }
    
    private let captureEngine = CaptureEngine()
    private var isSetup = false
    private var subscriptions = Set<AnyCancellable>()
    

    
    private var contentFilter: SCContentFilter {
        
        if let window = selectedWindow {
            return SCContentFilter(desktopIndependentWindow: window)
        }
      
        // TODO: Implement the excluded apps somewhere in here
        let excludedApplications: [SCRunningApplication]
           
        if let excludedApps = excludedApps {
            excludedApplications = availableApps.filter { app in
                excludedApps.contains(app.bundleIdentifier)
            }
        } else {
            excludedApplications = []
        }
        
        // Create a content filter with excluded apps.
        return SCContentFilter(
            display: selectedDisplay,
            excludingApplications: excludedApplications,
            exceptingWindows: []
        )
    }
    
    private var streamConfiguration: SCStreamConfiguration {
        
        let streamConfig = SCStreamConfiguration()
        
        // Configure audio capture.
        streamConfig.capturesAudio = false
        streamConfig.excludesCurrentProcessAudio = true
        
        streamConfig.width = selectedDisplay.width * scaleFactor
        streamConfig.height = selectedDisplay.height * scaleFactor
        

        streamConfig.pixelFormat = kCVPixelFormatType_32BGRA
        
        streamConfig.minimumFrameInterval = CMTime(value: 1, timescale: 30)
        
        // Increase the depth of the frame queue to ensure high fps at the expense of increasing
        // the memory footprint of WindowServer.
        streamConfig.queueDepth = 5
        
        return streamConfig
    }
    
    
    
    
    func updateAvailableContent(displays: [SCDisplay], apps: [SCRunningApplication], windows: [SCWindow]) {
        self.availableDisplays = displays
        self.availableApps = apps
        self.availableWindows = windows
    }
    func updateExcludedApps(excludedApps: Set<String>) {
        self.excludedApps = excludedApps
    }
    func updateSelectedWindow(selectedWindow: SCWindow) {
        print("updating window")
        self.selectedWindow = selectedWindow
    }
    func updateSelectedDisplay(display: SCDisplay) {
        print("updating display")
        self.selectedDisplay = display
    }
    
    
    
    /// `Functions`
    
    func start() async {
        // Exit early if already running.
        guard !isRunning else { return }
        
        if !isSetup {
            // Starting polling for available screen content.
//            await monitorAvailableContent()
            isSetup = true
        }
        
        do {
            let config = streamConfiguration
            let filter = contentFilter
            // Update the running state.
            isRunning = true
            // Start the stream and await new video frames.
            
           
            // TODO: Set all of the layers parameters here, like device, frame, bounds, pixelFormat
            capturePreview.frame = Previewer.shared.contentLayer.frame
            capturePreview.contentsGravity = .resizeAspect
            capturePreview.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
            
            capturePreview.drawableSize = CGSize(width: streamConfiguration.width, height: streamConfiguration.height)
            capturePreview.pixelFormat = .bgra8Unorm
            capturePreview.framebufferOnly = true
            
            var width = streamConfiguration.width
            let height = streamConfiguration.height
            
            
            if let device = MetalService.shared.device {
                print("Metal device found successfully. Settings the layers device.")
                capturePreview.device = device
            } else {
                fatalError("Unable to find metal device.")
            }
            
            
            for try await frame in captureEngine.startCapture(configuration: config, filter: filter) {
                
//                print("got the frame: ", frame)
//                Previewer.shared.contentLayer.contents = frame.imageBuffer
//                capturePreview.contents = frame.imageBuffer
//                capturePreview.contents = frame.surface
////                print("rendering new frame")
//                if contentSize != frame.size {
//                    // Update the content size if it changed.
//                    contentSize = frame.size
//                }
                // TODO: Implement dynamic updating for width and heeight of metal layer's drawable and width and height, when the display (size) changes
                
                guard let imageBuffer = frame.imageBuffer else { return }
//                print("Sending to Metal.")
                
                // TODO: Call MetalService.drawBufferToLayersTexture
//                MetalService.shared.drawBufferToLayersTexture(
//                    imageBuffer: imageBuffer,
//                    metalLayer: capturePreview,
//                    width: width,
//                    height: height
//                )
                
                // 1. Get the Metal Texture and store it as a variable
                model.mtlTexture = MetalService.shared.getMetalTextureFromCVPixelBuffer(imageBuffer: imageBuffer, width: width, height: height)
                
                // 2. Draw the Metal Texture to its previewer
                guard let texture = model.mtlTexture else { return }
                MetalService.shared.drawMetalTextureToLayer(texture: texture, metalLayer: capturePreview)
                
            }
        } catch {
            logger.error("\(error.localizedDescription)")
            // Unable to start the stream. Set the running state to false.
            isRunning = false
        }
    }
    
    /// Stops capturing screen content.
    func stop() async {
        guard isRunning else { return }
        await captureEngine.stopCapture()
        model.mtlTexture = nil
        isRunning = false
    }
    
    /// - Tag: UpdateCaptureConfig
    private func updateEngine() {
        guard isRunning else { return }
        print("updating engine")
        Task {
            let filter = contentFilter
            await captureEngine.update(configuration: streamConfiguration, filter: filter)
        }
    }

    
}





