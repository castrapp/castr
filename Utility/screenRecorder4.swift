
import Foundation
import ScreenCaptureKit
import Combine
import OSLog
import SwiftUI



@MainActor
class ScreenRecorder4: NSObject, ObservableObject {
    
    /// The supported capture types.
    enum CaptureType {
        case display
        case window
    }
    
    private let logger = Logger()
    private var cancellables = Set<AnyCancellable>()

    
    @Published var isRunning = false
    @Published var captureType: CaptureType = .display { didSet { updateEngine() }}
    @Published var selectedDisplay: SCDisplay? { didSet {updateEngine() }}
    @Published var selectedWindow: SCWindow? { didSet { updateEngine() }}
    @Published var excludedApplications: [SCRunningApplication] = [SCRunningApplication]() { didSet { updateEngine() }}
    @Published var contentSize = CGSize(width: 1, height: 1)
    @Published var layer: CAMetalLayer
    @Published var model: ScreenCaptureSourceModel
    private var scaleFactor: Int { Int(NSScreen.main?.backingScaleFactor ?? 2) }
    private var contentRefreshTimer: AnyCancellable?
    private let captureEngine = CaptureEngine()
    private var isSetup = false
  

    init(model: ScreenCaptureSourceModel) {
        
        self.model = model
        self.layer = model.layer
        super.init()
        
        // Observe changes in selectedDisplay
//        model.$selectedDisplay.sink { [weak self] newDisplay in
//                availableDisplays
//        }
//        .store(in: &cancellables)
        
        
        if let device = MetalService.shared.device {
//            print("Metal device found successfully. Settings the layers device.")
            layer.device = device
        } else {
            fatalError("Unable to find metal device.")
        }
        
        print("screen capture initialized")
    }
    
   
    
    var contentFilter: SCContentFilter {
        var filter: SCContentFilter
        switch captureType {
        case .display:
            guard let display = selectedDisplay else { fatalError("No display selected.") }
       
            // Create a content filter with excluded apps.
            filter = SCContentFilter(display: display,
                                     excludingApplications: excludedApplications,
                                     exceptingWindows: [])
        case .window:
            guard let window = selectedWindow else { fatalError("No window selected.") }
            
            // Create a content filter that includes a single window.
            filter = SCContentFilter(desktopIndependentWindow: window)
        }

        return filter
    }
    
    var streamConfiguration: SCStreamConfiguration {
        
        let streamConfig = SCStreamConfiguration()
        
        // Configure audio capture.
        streamConfig.capturesAudio = false
        streamConfig.excludesCurrentProcessAudio = true
        
        // Configure the display content width and height.
        if captureType == .display, let display = selectedDisplay {
            streamConfig.width = display.width * scaleFactor
            streamConfig.height = display.height * scaleFactor
        }
        
        // Configure the window content width and height.
        if captureType == .window, let window = selectedWindow {
            streamConfig.width = Int(window.frame.width) * 2
            streamConfig.height = Int(window.frame.height) * 2
        }
        
        // Set the capture interval at 60 fps.
        streamConfig.pixelFormat = kCVPixelFormatType_32BGRA
        streamConfig.minimumFrameInterval = CMTime(value: 1, timescale: 60)
        
        // Increase the depth of the frame queue to ensure high fps at the expense of increasing
        // the memory footprint of WindowServer.
        streamConfig.queueDepth = 5
        
        return streamConfig
    }
    
    
    
    
    
    
    /// `Functions`
    
    func start() async {
        // Exit early if already running.
        guard !isRunning else { return }
        
        if !isSetup {
            // Starting polling for available screen content.
            isSetup = true
        }
        
        do {
            
            await refreshAvailableContent()
            
            let config = streamConfiguration
            let filter = contentFilter
            // Update the running state.
            isRunning = true
           
            layer.drawableSize = CGSize(width: streamConfiguration.width, height: streamConfiguration.height)
            layer.pixelFormat = .bgra8Unorm
            layer.framebufferOnly = true
           
            // TODO: Set all of the layers parameters here, like device, frame, bounds, pixelFormat
           
            
            var width = streamConfiguration.width
            let height = streamConfiguration.height
            
            print("starting screen capture")
            for try await frame in captureEngine.startCapture(configuration: config, filter: filter) {
                
                guard let imageBuffer = frame.imageBuffer else { return }

                
                // 1. Get the Metal Texture and store it as a variable
                model.mtlTexture = MetalService.shared.getMetalTextureFromCVPixelBuffer(imageBuffer: imageBuffer, width: width, height: height)
                
                // 2. Draw the Metal Texture to its previewer
                guard let texture = model.mtlTexture else { return }
                MetalService.shared.drawMetalTextureToLayer(texture: texture, metalLayer: layer)
                
            }
        } catch {
            logger.error("\(error.localizedDescription)")
            // Unable to start the stream. Set the running state to false.
            isRunning = false
        }
    }
    
    
    func stop() async {
        guard isRunning else { return }
        await captureEngine.stopCapture()
        isRunning = false
    }
    
    func updateEngine() {
        guard isRunning else { return }
        Task {
            let filter = contentFilter
            await captureEngine.update(configuration: streamConfiguration, filter: filter)
        }
    }
    
    
    func updateEngineWithExcluded(newFilter: SCContentFilter) {
        guard isRunning else { return }
        Task {
            await captureEngine.update(configuration: streamConfiguration, filter: newFilter)
        }
    }

    

    func refreshAvailableContent() async {
        do {
            // Retrieve the available screen content to capture.
            let availableContent = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)

            
            if !model.selectedDisplay.isEmpty {
                selectedDisplay = availableContent.displays.first { $0.displayName == model.selectedDisplay }
            } else  {
                selectedDisplay = availableContent.displays.first
            }
            
        } catch {
            fatalError("Cannot Refresh available content")
        }
    }
    
 

 
    

}

