
import Foundation
import ScreenCaptureKit
import Combine
import OSLog
import SwiftUI


@MainActor
class ScreenRecorder2: NSObject, ObservableObject {
    
    var capturePreview: CAMetalLayer
    var availableDisplays: [SCDisplay]
    var availableApps: [SCRunningApplication]
    var availableWindows: [SCWindow]
    var excludedApps: Set<String>? { didSet { updateStream() } }
    var selectedDisplay: SCDisplay { didSet { updateStream() } }
    var selectedWindow: SCWindow? { didSet { updateStream() } }
    private var stream: SCStream?
    private var streamOutput: CaptureEngineStreamOutput2
    private let videoSampleBufferQueue = DispatchQueue(label: "harrisonhall.castr.stream.\(UUID().uuidString)")

    init(
        capturePreview: CAMetalLayer,
        availableDisplays: [SCDisplay],
        availableApps: [SCRunningApplication],
        availableWindows: [SCWindow],
        excludedApps: Set<String> = Set(),
        selectedDisplay: SCDisplay,
        selectedWindow: SCWindow? = nil
    ) {
        self.capturePreview = capturePreview
        self.availableDisplays = availableDisplays
        self.availableApps = availableApps
        self.availableWindows = availableWindows
        self.excludedApps = excludedApps
        self.selectedDisplay = selectedDisplay
        self.selectedWindow = selectedWindow
        self.streamOutput = CaptureEngineStreamOutput2(layer: capturePreview)
    }
    
    private let logger = Logger()
    private var scaleFactor: Int { Int(NSScreen.main?.backingScaleFactor ?? 2) }
    
    
    
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
    func updateStream() {
        Task {
            await update(configuration: streamConfiguration, filter: contentFilter)
        }
    }
    
    
    
    /// `Functions`
    
    func start() async {

        do {
            let config = streamConfiguration
            let filter = contentFilter
     
            stream = SCStream(filter: filter, configuration: config, delegate: streamOutput)
          
            try stream?.addStreamOutput(streamOutput, type: .screen, sampleHandlerQueue: videoSampleBufferQueue)
            
            try await stream?.startCapture()
        } catch {
            logger.error("\(error.localizedDescription)")
        }
    }
    
    
    func stop() async {
        do {
            try await stream?.stopCapture()
        } catch {
            logger.error("failed to stop capturing stream")
        }
       
    }
    
    
    private func update(configuration: SCStreamConfiguration, filter: SCContentFilter) async {
        do {
            try await stream?.updateConfiguration(configuration)
            try await stream?.updateContentFilter(filter)
        } catch {
            logger.error("Failed to update the stream session: \(String(describing: error))")
        }
    }
    

  
}





class CaptureEngineStreamOutput2: NSObject, SCStreamOutput, SCStreamDelegate {
    
    let layer: CAMetalLayer
    
    init(layer: CAMetalLayer) {
        self.layer = layer
    }
    
    func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of outputType: SCStreamOutputType) {
        
        // Check for an image buffer and if its valid
        guard
            let imageBuffer = sampleBuffer.imageBuffer, sampleBuffer.isValid
        else { return }
//
        print("got the buffer: ", sampleBuffer)
        
        Task { @MainActor in
            Previewer.shared.contentLayer.contents = imageBuffer
        }
        
        
//        Previewer.shared.contentLayer.backgroundColor = .white
//        Previewer.shared.contentLayer.display()
//
//        // Get the backing IOSurface.
//        guard let surfaceRef = CVPixelBufferGetIOSurface(imageBuffer)?.takeUnretainedValue() else { return }
//        let surface = unsafeBitCast(surfaceRef, to: IOSurface.self)
        
        
//        Task { @MainActor in
//            CapturePreview.shared.contentLayer.contents = surface
//        }
        
//        MetalState.shared.draw2(imageBuffer: imageBuffer)
        
    }
    

    func stream(_ stream: SCStream, didStopWithError error: Error) {
//        continuation?.finish(throwing: error)
    }
}
