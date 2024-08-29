//
//import Foundation
//import ScreenCaptureKit
//import Combine
//import OSLog
//import SwiftUI
//
///// A provider of audio levels from the captured samples.
//
//
//@MainActor
//class ScreenRecorder3: NSObject, ObservableObject {
//    
//    /// The supported capture types.
//    enum CaptureType {
//        case display
//        case window
//    }
//    
//    @Published var layer: CAMetalLayer
//    @Published var availableDisplays = [SCDisplay]()
//    @Published var availableApps = [SCRunningApplication]()
//    @Published var availableWindows = [SCWindow]()
//    @Published var contentRefreshTimer: AnyCancellable?
//    @Published var selectedDisplay: SCDisplay?
//    @Published var selectedWindow: SCWindow?
//
//    var excludedApps: Set<String>? { didSet { updateEngine() } }
//    var model: ScreenCaptureSourceModel
//
//    init(
//        layer: CAMetalLayer,
//        excludedApps: Set<String> = Set(),
//        model: ScreenCaptureSourceModel
//    ) {
//        self.layer = layer
//        self.excludedApps = excludedApps
//        self.model = model
//    }
//    
//    private let logger = Logger()
//    
//    @Published var isRunning = false
//    @Published var captureType: CaptureType = .display {
//        didSet { updateEngine() }
//    }
//
//
//    @Published var isAppExcluded = true {
//        didSet { updateEngine() }
//    }
//    @Published var contentSize = CGSize(width: 1, height: 1)
//    private var scaleFactor: Int { Int(NSScreen.main?.backingScaleFactor ?? 2) }
//    
//    private let captureEngine = CaptureEngine()
//    private var isSetup = false
//
//    
//
//    
//    private var contentFilter: SCContentFilter {
//        
//        if let window = selectedWindow {
//            return SCContentFilter(desktopIndependentWindow: window)
//        }
//      
//        // TODO: Implement the excluded apps somewhere in here
//        let excludedApplications: [SCRunningApplication]
//           
//        if let excludedApps = excludedApps {
//            excludedApplications = availableApps.filter { app in
//                excludedApps.contains(app.bundleIdentifier)
//            }
//        } else {
//            excludedApplications = []
//        }
//        
//
//        
//        // Create a content filter with excluded apps.
//        return SCContentFilter(
//            display: selectedDisplay,
//            excludingApplications: excludedApplications,
//            exceptingWindows: []
//        )
//    }
//    
//    private var streamConfiguration: SCStreamConfiguration {
//        
//        let streamConfig = SCStreamConfiguration()
//        
//        // Configure audio capture.
//        streamConfig.capturesAudio = false
//        streamConfig.excludesCurrentProcessAudio = true
//        
//        if let display = selectedDisplay {
//            streamConfig.width = display.width * scaleFactor
//            streamConfig.height = display.height * scaleFactor
//        }
//       
//        
//
//        streamConfig.pixelFormat = kCVPixelFormatType_32BGRA
//        streamConfig.minimumFrameInterval = CMTime(value: 1, timescale: 30)
//        
//        // Increase the depth of the frame queue to ensure high fps at the expense of increasing
//        // the memory footprint of WindowServer.
//        streamConfig.queueDepth = 5
//        
//        return streamConfig
//    }
//    
//    
//    
//    
//    func updateAvailableContent(displays: [SCDisplay], apps: [SCRunningApplication], windows: [SCWindow]) {
//        self.availableDisplays = displays
//        self.availableApps = apps
//        self.availableWindows = windows
//    }
//    func updateExcludedApps(excludedApps: Set<String>) {
//        self.excludedApps = excludedApps
//    }
//    func updateSelectedWindow(selectedWindow: SCWindow) {
//        print("updating window")
//        self.selectedWindow = selectedWindow
//    }
//    func updateSelectedDisplay(display: SCDisplay) {
//        print("updating display")
//        self.selectedDisplay = display
//    }
//    
//    
//    
//    /// `Functions`
//    
//    func start() async {
//        // Exit early if already running.
//        guard !isRunning else { return }
//        
//        if !isSetup {
//            // Starting polling for available screen content.
//            isSetup = true
//        }
//        
//        do {
//            let config = streamConfiguration
//            let filter = contentFilter
//            // Update the running state.
//            isRunning = true
//            // Start the stream and await new video frames.
//            
//           
//            // TODO: Set all of the layers parameters here, like device, frame, bounds, pixelFormat
//            layer.frame = Previewer.shared.contentLayer.frame
////            capturePreview.contentsGravity = .resizeAspect
////            capturePreview.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
//            
//            layer.drawableSize = CGSize(width: streamConfiguration.width, height: streamConfiguration.height)
//            layer.pixelFormat = .bgra8Unorm
//            layer.framebufferOnly = true
//            
//            var width = streamConfiguration.width
//            let height = streamConfiguration.height
//            
//            
//            if let device = MetalService.shared.device {
//                print("Metal device found successfully. Settings the layers device.")
//                layer.device = device
//            } else {
//                fatalError("Unable to find metal device.")
//            }
//            
//            
//            for try await frame in captureEngine.startCapture(configuration: config, filter: filter) {
//                
//                guard let imageBuffer = frame.imageBuffer else { return }
//
//                
//                // 1. Get the Metal Texture and store it as a variable
//                model.mtlTexture = MetalService.shared.getMetalTextureFromCVPixelBuffer(imageBuffer: imageBuffer, width: width, height: height)
//                
//                // 2. Draw the Metal Texture to its previewer
//                guard let texture = model.mtlTexture else { return }
//                MetalService.shared.drawMetalTextureToLayer(texture: texture, metalLayer: layer)
//                
//            }
//        } catch {
//            logger.error("\(error.localizedDescription)")
//            // Unable to start the stream. Set the running state to false.
//            isRunning = false
//        }
//    }
//    
//
//    func stop() async {
//        guard isRunning else { return }
//        await captureEngine.stopCapture()
//        model.mtlTexture = nil
//        isRunning = false
//    }
//    
//
//    private func updateEngine() {
//        guard isRunning else { return }
//        print("updating engine")
//        Task {
//            let filter = contentFilter
//            await captureEngine.update(configuration: streamConfiguration, filter: filter)
//        }
//    }
//    
//    func startMonitoringAvailableContent() async {
////                print("starting to monitor available content")
//        await self.refreshAvailableContent()
//        contentRefreshTimer = Timer.publish(every: 2, on: .main, in: .common).autoconnect().sink { [weak self] _ in
//            guard let self = self else { return }
//            Task {
//                await self.refreshAvailableContent()
//            }
//        }
//    }
//    
//    func refreshAvailableContent() async {
//        do {
//            // Retrieve the available screen content to capture.
//            let availableContent = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
//            
//            await MainActor.run {
////                        print("monitoring available content")
//                availableDisplays = availableContent.displays
//                availableWindows = filterWindows(availableContent.windows)
//                availableApps = filterApplications(availableContent.applications)
//                
//                if let display = availableDisplays.first, selectedDisplay == nil {
//                    selectedDisplay = display
//                }
//            }
//        } catch {
//
//        }
//    }
//    
//    
//    private func filterWindows(_ windows: [SCWindow]) -> [SCWindow] {
//        // Sort the windows by app name.
//        windows.sorted { $0.owningApplication?.applicationName ?? "" < $1.owningApplication?.applicationName ?? "" }
//    }
//    
//    private func filterApplications(_ applications: [SCRunningApplication]) -> [SCRunningApplication] {
//        applications
//            .filter { $0.applicationName.isEmpty == false }
//            .sorted { $0.applicationName.lowercased() < $1.applicationName.lowercased() }
//    }
//
//    
//}
//
//
//
//
//
