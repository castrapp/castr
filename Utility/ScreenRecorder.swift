
import Foundation
import ScreenCaptureKit
import Combine
import OSLog
import SwiftUI

/// A provider of audio levels from the captured samples.


@MainActor
class ScreenRecorder: NSObject, ObservableObject {
    
    /// The supported capture types.
    enum CaptureType {
        case display
        case window
    }
    
    var capturePreview: CAMetalLayer
    var availableDisplays: [SCDisplay]
    var availableApps: [SCRunningApplication]
    var availableWindows: [SCWindow]
    var selectedDisplay: SCDisplay { didSet { updateEngine() } }
    var excludedApps: Set<String>? { didSet { updateEngine() } }
    var selectedWindow: SCWindow? { didSet { updateEngine() } }

    init(
        capturePreview: CAMetalLayer,
        availableDisplays: [SCDisplay],
        availableApps: [SCRunningApplication],
        availableWindows: [SCWindow],
        selectedDisplay: SCDisplay,
        excludedApps: Set<String> = Set(),
        selectedWindow: SCWindow? = nil
    ) {
        self.capturePreview = capturePreview
        self.availableDisplays = availableDisplays
        self.availableApps = availableApps
        self.availableWindows = availableWindows
        self.selectedDisplay = selectedDisplay
        self.excludedApps = excludedApps
        self.selectedWindow = selectedWindow
    }
    
    private let logger = Logger()
    
    @Published var isRunning = false
    @Published var captureType: CaptureType = .display {
        didSet { updateEngine() }
    }
//    @Published var selectedDisplay: SCDisplay? {
//        didSet { updateEngine() }
//    }

    @Published var isAppExcluded = true {
        didSet { updateEngine() }
    }
    @Published var contentSize = CGSize(width: 1, height: 1)
    private var scaleFactor: Int { Int(NSScreen.main?.backingScaleFactor ?? 2) }
    
    /// A view that renders the screen content.
       

//    @Published  var availableDisplays: [SCDisplay]
//    @Published  var availableApps: [SCRunningApplication]
//    @Published  var availableWindows: [SCWindow]
    private let captureEngine = CaptureEngine()
    private var isSetup = false
    private var subscriptions = Set<AnyCancellable>()
    
    var canRecord: Bool {
        get async {
            do {
                // If the app doesn't have screen recording permission, this call generates an exception.
                try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
                return true
            } catch {
                return false
            }
        }
    }
    
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
        
        // Configure the display content width and height.
//        if captureType == .display {
         
//        }
        
        // Configure the window content width and height.
//        if captureType == .window, let window = selectedWindow {
//            streamConfig.width = Int(window.frame.width) * 2
//            streamConfig.height = Int(window.frame.height) * 2
//        }
        
//        if selectedWindow != nil {
//            streamConfig.scalesToFit = true
//            streamConfig.pixelFormat = kCVPixelFormatType_32BGRA
//            streamConfig.backgroundColor = .clear
//            streamConfig.shouldBeOpaque = true
//        }
        
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
            for try await buffer in captureEngine.startCapture(configuration: config, filter: filter) {
                
                print("got the buffer: ", buffer)
//                capturePreview.contents = frame.surface
////                print("rendering new frame")
//                if contentSize != frame.size {
//                    // Update the content size if it changed.
//                    contentSize = frame.size
//                }
                
                // TODO: Call MetalService.drawBufferToLayersTexture
//                MetalService.shared.drawBufferToLayersTexture(imageBuffer: buffer.imageBuffer, metalLayer: capturePreview)
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

//    private func refreshAvailableContent() async {
//        do {
//            // Retrieve the available screen content to capture.
//            let availableContent = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
//            
//            availableDisplays = availableContent.displays
//            
//            let windows = filterWindows(availableContent.windows)
//            if windows != availableWindows {
//                availableWindows = windows
//            }
//            availableApps = availableContent.applications
//            
////            if selectedDisplay == nil {
////                selectedDisplay = availableDisplays.first
////            }
//
//        } catch {
//            logger.error("Failed to get the shareable content: \(error.localizedDescription)")
//        }
//    }
    
//    private func filterWindows(_ windows: [SCWindow]) -> [SCWindow] {
//        windows
//        // Sort the windows by app name.
//            .sorted { $0.owningApplication?.applicationName ?? "" < $1.owningApplication?.applicationName ?? "" }
//    }
    
}





extension SCWindow {
    var displayName: String {
        switch (owningApplication, title) {
        case (.some(let application), .some(let title)):
            return "\(application.applicationName): \(title)"
        case (.none, .some(let title)):
            return title
        case (.some(let application), .none):
            return "\(application.applicationName): \(windowID)"
        default:
            return ""
        }
    }
}

extension SCDisplay {
    var displayName: String {
        "Display: \(width) x \(height)"
    }
}
