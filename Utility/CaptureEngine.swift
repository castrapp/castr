
import Foundation
import AVFAudio
import ScreenCaptureKit
import OSLog
import Combine

/// A structure that contains the video data to render.
struct CapturedFrame {
    static let invalid = CapturedFrame(surface: nil, contentRect: .zero, contentScale: 0, scaleFactor: 0)

    let surface: IOSurface?
    let contentRect: CGRect
    let contentScale: CGFloat
    let scaleFactor: CGFloat
    var size: CGSize { contentRect.size }
}

/// An object that wraps an instance of `SCStream`, and returns its results as an `AsyncThrowingStream`.
class CaptureEngine: NSObject, @unchecked Sendable {
    
    private let logger = Logger()

    var stream: SCStream?
    private var streamOutput: CaptureEngineStreamOutput?
    private let videoSampleBufferQueue = DispatchQueue(label: "com.example.apple-samplecode.VideoSampleBufferQueue")
    
    
    // Store the the startCapture continuation, so that you can cancel it when you call stopCapture().
    private var continuation: AsyncThrowingStream<CapturedFrame, Error>.Continuation?
    
    /// - Tag: StartCapture
    func startCapture(configuration: SCStreamConfiguration, filter: SCContentFilter) -> AsyncThrowingStream<CapturedFrame, Error> {
        AsyncThrowingStream<CapturedFrame, Error> { continuation in
            // The stream output object. Avoid reassigning it to a new object every time startCapture is called.
            let streamOutput = CaptureEngineStreamOutput(continuation: continuation)
            self.streamOutput = streamOutput
            streamOutput.capturedFrameHandler = { continuation.yield($0) }

            do {
                stream = SCStream(filter: filter, configuration: configuration, delegate: streamOutput)
                
                // Add a stream output to capture screen content.
                try stream?.addStreamOutput(streamOutput, type: .screen, sampleHandlerQueue: videoSampleBufferQueue)

                stream?.startCapture()
            } catch {
                continuation.finish(throwing: error)
            }
        }
    }
    
    func stopCapture() async {
        print("The stream was stopped at the time of: ", Date().timeIntervalSince1970)
        do {
            try await stream?.stopCapture()
            continuation?.finish()
        } catch {
            continuation?.finish(throwing: error)
        }
    }
    
    /// - Tag: UpdateStreamConfiguration
    func update(configuration: SCStreamConfiguration, filter: SCContentFilter) async {
        do {
            try await stream?.updateConfiguration(configuration)
            try await stream?.updateContentFilter(filter)
        } catch {
            logger.error("Failed to update the stream session: \(String(describing: error))")
        }
    }
}

/// A class that handles output from an SCStream, and handles stream errors.
private class CaptureEngineStreamOutput: NSObject, SCStreamOutput, SCStreamDelegate {
    
    var pcmBufferHandler: ((AVAudioPCMBuffer) -> Void)?
    var capturedFrameHandler: ((CapturedFrame) -> Void)?
    var buffer: CMSampleBuffer?
    var timer: Timer?
    
    // Store the  startCapture continuation, so you can cancel it if an error occurs.
    private var continuation: AsyncThrowingStream<CapturedFrame, Error>.Continuation?
    
    init(continuation: AsyncThrowingStream<CapturedFrame, Error>.Continuation?) {
        self.continuation = continuation
        super.init()
//        enqueue()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func enqueue () {
          timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
              // TODO: Implement a send function right here:
              if(GlobalState.shared.streamToVirtualCamera) {
                  
                  guard
                    let self = self,
                    let sinkQueue = CameraViewModel.shared.sinkQueue,
                    let sampleBuffer = buffer
                  else { return }
                  
                  if let stripedSampleBuffer = stripMetadata(from: sampleBuffer) {
                      
                      print("Stripped sample buffer, now sending it")
                      let pointerRef = UnsafeMutableRawPointer(Unmanaged.passRetained(stripedSampleBuffer).toOpaque())
                      let result = CMSimpleQueueEnqueue(sinkQueue, element: pointerRef)
                      
                  } else {
                      
                      let pointerRef = UnsafeMutableRawPointer(Unmanaged.passRetained(sampleBuffer).toOpaque())
                      let result = CMSimpleQueueEnqueue(sinkQueue, element: pointerRef)
                      
                      print("Failed to strip sample buffer, but still sending it")
                  }
                  buffer = nil
              }
              print("DISTRIBUTED FRAMES TO ALL OUTPUT")
          }
      }
    
    /// - Tag: DidOutputSampleBuffer
    func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of outputType: SCStreamOutputType) {
        
        print("the sample buffer is: ", sampleBuffer)
        print("are delayed frames on?: ", GlobalState.shared.delayFrames)
        if(GlobalState.shared.delayFrames) { return }
        
        print("New frame at: ", Date().timeIntervalSince1970)
        // Return early if the sample buffer is invalid.
        guard sampleBuffer.isValid else { return }
        
//        buffer = sampleBuffer
        
        
        
        // TODO: Implement a send function right here:
        if(GlobalState.shared.streamToVirtualCamera) {
            
            guard
              let sinkQueue = CameraViewModel.shared.sinkQueue
            else { return }
            
            if let stripedSampleBuffer = stripMetadata(from: sampleBuffer) {
                
                print("Stripped sample buffer, now sending it")
                let pointerRef = UnsafeMutableRawPointer(Unmanaged.passRetained(stripedSampleBuffer).toOpaque())
                let result = CMSimpleQueueEnqueue(sinkQueue, element: pointerRef)
                
            } else {
                
                let pointerRef = UnsafeMutableRawPointer(Unmanaged.passRetained(sampleBuffer).toOpaque())
                let result = CMSimpleQueueEnqueue(sinkQueue, element: pointerRef)
                
                print("Failed to strip sample buffer, but still sending it")
            }
//            buffer = nil
        }

        
        
        
        
        
        // Create a CapturedFrame structure for a video sample buffer.
        guard let frame = createFrame(for: sampleBuffer) else { return }
        capturedFrameHandler?(frame)
        
       
        
    }
    
    /// Create a `CapturedFrame` for the video sample buffer.
    private func createFrame(for sampleBuffer: CMSampleBuffer) -> CapturedFrame? {
        
        // Get the pixel buffer that contains the image data.
        guard let pixelBuffer = sampleBuffer.imageBuffer else {
            print("NO IMAGE BUFFER IS PRESENT")
            return nil
        }
        
        // Retrieve the array of metadata attachments from the sample buffer.
        guard let attachmentsArray = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer,
                                                                             createIfNecessary: false) as? [[SCStreamFrameInfo: Any]],
              let attachments = attachmentsArray.first else { return nil }
        
        // Validate the status of the frame. If it isn't `.complete`, return nil.
        guard let statusRawValue = attachments[SCStreamFrameInfo.status] as? Int,
              let status = SCFrameStatus(rawValue: statusRawValue),
              status == .complete else { return nil }
        
       
        
        // Get the backing IOSurface.
        guard let surfaceRef = CVPixelBufferGetIOSurface(pixelBuffer)?.takeUnretainedValue() else { return nil }
        let surface = unsafeBitCast(surfaceRef, to: IOSurface.self)
        
        // Retrieve the content rectangle, scale, and scale factor.
        guard let contentRectDict = attachments[.contentRect],
              let contentRect = CGRect(dictionaryRepresentation: contentRectDict as! CFDictionary),
              let contentScale = attachments[.contentScale] as? CGFloat,
              let scaleFactor = attachments[.scaleFactor] as? CGFloat else { return nil }
        
        // Create a new frame with the relevant data.
        let frame = CapturedFrame(surface: surface,
                                  contentRect: contentRect,
                                  contentScale: contentScale,
                                  scaleFactor: scaleFactor)
        
        return frame
    }
    
    
    
    func stripMetadata(from sampleBuffer: CMSampleBuffer) -> CMSampleBuffer? {
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Failed to get image buffer from sample buffer: ", sampleBuffer)
            print("The failed sample buffers image buffer is: ", sampleBuffer.imageBuffer)
            return nil
        }
        
        guard let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) else {
            print("Failed to get Format Description from sample buffer")
            return nil
        }
        
        var timingInfo = CMSampleTimingInfo()
        CMSampleBufferGetSampleTimingInfo(sampleBuffer, at: 0, timingInfoOut: &timingInfo)
        
        var newSampleBuffer: CMSampleBuffer?
        let status = CMSampleBufferCreateForImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: imageBuffer,
            dataReady: true,
            makeDataReadyCallback: nil,
            refcon: nil,
            formatDescription: formatDescription,
            sampleTiming: &timingInfo,
            sampleBufferOut: &newSampleBuffer
        )
        
        if status != noErr {
            print("Failed to create new sample buffer: \(status)")
            return nil
        }
        
        
        return newSampleBuffer
    }
    
   
    
    func stream(_ stream: SCStream, didStopWithError error: Error) {
        print("The stream was stopped with an ERROR at the time of: ", Date().timeIntervalSince1970)
        continuation?.finish(throwing: error)
    }
}
