import Cocoa
import CoreMedia
import AVFoundation

class LayerToSampleBufferConverter {
    static let shared = LayerToSampleBufferConverter()
    
    private var displayLink: CVDisplayLink?
    private var startTime: CFTimeInterval = 0
    private var rootLayer: CALayer?
    private var completion: ((CMSampleBuffer) -> Void)?
    
    private init() {}
    
    func setRootLayer(_ layer: CALayer) {
        self.rootLayer = layer
    }
    
    func start(completion: @escaping (CMSampleBuffer) -> Void) {
        guard rootLayer != nil else {
            print("Root layer not set. Call setRootLayer() before starting.")
            return
        }
        
        self.completion = completion
        startTime = CACurrentMediaTime()
        
        CVDisplayLinkCreateWithActiveCGDisplays(&displayLink)
        if let displayLink = displayLink {
            CVDisplayLinkSetOutputCallback(displayLink, displayLinkCallback, Unmanaged.passUnretained(self).toOpaque())
            CVDisplayLinkStart(displayLink)
        }
    }
    
    func stop() {
        if let displayLink = displayLink {
            CVDisplayLinkStop(displayLink)
        }
        displayLink = nil
        completion = nil
        print("stopped CMSampleBuffer Converter")
    }
    
    func update() {
        guard let layer = rootLayer, let completion = completion else { return }
        
        if let pixelBuffer = pixelBuffer(from: layer) {
            let timestamp = CMTime(seconds: CACurrentMediaTime() - startTime, preferredTimescale: 600)
            if let sampleBuffer = sampleBuffer(from: pixelBuffer, timestamp: timestamp) {
                completion(sampleBuffer)
            }
        }
    }
    
    func pixelBuffer(from layer: CALayer) -> CVPixelBuffer? {
        let width = Int(layer.bounds.width)
        let height = Int(layer.bounds.height)
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, nil, &pixelBuffer)
        
        guard status == kCVReturnSuccess, let unwrappedPixelBuffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(unwrappedPixelBuffer, [])
        defer { CVPixelBufferUnlockBaseAddress(unwrappedPixelBuffer, []) }
        
        guard let context = CGContext(data: CVPixelBufferGetBaseAddress(unwrappedPixelBuffer),
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(unwrappedPixelBuffer),
                                      space: CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue) else {
            return nil
        }
        
        context.clear(CGRect(x: 0, y: 0, width: width, height: height))
        layer.render(in: context)
        
        return unwrappedPixelBuffer
    }
    
    func sampleBuffer(from pixelBuffer: CVPixelBuffer, timestamp: CMTime) -> CMSampleBuffer? {
        var sampleBuffer: CMSampleBuffer?
        var timingInfo = CMSampleTimingInfo(duration: CMTime.invalid, presentationTimeStamp: timestamp, decodeTimeStamp: CMTime.invalid)
        
        var videoInfo: CMVideoFormatDescription?
        CMVideoFormatDescriptionCreateForImageBuffer(allocator: nil, imageBuffer: pixelBuffer, formatDescriptionOut: &videoInfo)
        
        guard let unwrappedVideoInfo = videoInfo else {
            return nil
        }
        
        CMSampleBufferCreateForImageBuffer(allocator: kCFAllocatorDefault,
                                           imageBuffer: pixelBuffer,
                                           dataReady: true,
                                           makeDataReadyCallback: nil,
                                           refcon: nil,
                                           formatDescription: unwrappedVideoInfo,
                                           sampleTiming: &timingInfo,
                                           sampleBufferOut: &sampleBuffer)
        
        return sampleBuffer
    }
}

func displayLinkCallback(_ displayLink: CVDisplayLink, _ inNow: UnsafePointer<CVTimeStamp>, _ inOutputTime: UnsafePointer<CVTimeStamp>, _ flagsIn: CVOptionFlags, _ flagsOut: UnsafeMutablePointer<CVOptionFlags>, _ displayLinkContext: UnsafeMutableRawPointer?) -> CVReturn {
    let converter = Unmanaged<LayerToSampleBufferConverter>.fromOpaque(displayLinkContext!).takeUnretainedValue()
    DispatchQueue.main.async {
        converter.update()
    }
    return kCVReturnSuccess
}
