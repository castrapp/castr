/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A model object that provides the interface to capture screen content and system audio.
*/
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
    
    var availableDisplays: [SCDisplay]
    var availableApps: [SCRunningApplication]
    var availableWindows: [SCWindow]
    var selectedDisplay: SCDisplay { didSet { updateEngine() } }

    init(
        capturePreview: CALayer,
        availableDisplays: [SCDisplay],
        availableApps: [SCRunningApplication],
        availableWindows: [SCWindow],
        selectedDisplay: SCDisplay
    ) {
        self.capturePreview = capturePreview
        self.availableDisplays = availableDisplays
        self.availableApps = availableApps
        self.availableWindows = availableWindows
        self.selectedDisplay = selectedDisplay
    }
    
    private let logger = Logger()
    
    @Published var isRunning = false
    @Published var captureType: CaptureType = .display {
        didSet { updateEngine() }
    }
//    @Published var selectedDisplay: SCDisplay? {
//        didSet { updateEngine() }
//    }
    @Published var selectedWindow: SCWindow? {
        didSet { updateEngine() }
    }
    @Published var isAppExcluded = true {
        didSet { updateEngine() }
    }
    @Published var contentSize = CGSize(width: 1, height: 1)
    private var scaleFactor: Int { Int(NSScreen.main?.backingScaleFactor ?? 2) }
    
    /// A view that renders the screen content.
    var capturePreview: CALayer
       

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
//        guard let display = selectedDisplay else { fatalError("No display selected.") }
        
        // TODO: Implement the excluded apps somewhere in here
        
        // Create a content filter with excluded apps.
        return SCContentFilter(
            display: selectedDisplay,
            excludingApplications: [],
            exceptingWindows: []
        )
    }
    
    private var streamConfiguration: SCStreamConfiguration {
        
        let streamConfig = SCStreamConfiguration()
        
        // Configure audio capture.
        streamConfig.capturesAudio = false
        streamConfig.excludesCurrentProcessAudio = true
        
        // Configure the display content width and height.
        if captureType == .display {
            streamConfig.width = selectedDisplay.width * scaleFactor
            streamConfig.height = selectedDisplay.height * scaleFactor
        }
        
        // Configure the window content width and height.
        if captureType == .window, let window = selectedWindow {
            streamConfig.width = Int(window.frame.width) * 2
            streamConfig.height = Int(window.frame.height) * 2
        }
        
        // Set the capture interval at 60 fps.
        streamConfig.minimumFrameInterval = CMTime(value: 1, timescale: 60)
        
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
    
    
    
    /// `Functions`

//    func monitorAvailableContent() async {
//        guard !isSetup else { return }
//        // Refresh the lists of capturable content.
//        await self.refreshAvailableContent()
//        Timer.publish(every: 3, on: .main, in: .common).autoconnect().sink { [weak self] _ in
//            guard let self = self else { return }
//            Task {
//                await self.refreshAvailableContent()
//            }
//        }
////        .store(in: &subscriptions)
//    }
    
    /// Starts capturing screen content.
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
            for try await frame in captureEngine.startCapture(configuration: config, filter: filter) {
                capturePreview.contents = frame.surface
                if contentSize != frame.size {
                    // Update the content size if it changed.
                    contentSize = frame.size
                }
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
