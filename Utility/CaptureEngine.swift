
import Foundation
import AVFAudio
import ScreenCaptureKit
import OSLog
import Combine

/// A structure that contains the video data to render.
struct CapturedFrame {
    static let invalid = CapturedFrame(imageBuffer: nil, contentRect: .zero, contentScale: 0, scaleFactor: 0)

    let imageBuffer: CVPixelBuffer?
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
    
    func stopCapture(completionHandler: ((Error?) -> Void)? = nil) {
        print("The stream was stopped at the time of: ", Date().timeIntervalSince1970)
        
        guard let stream = stream else {
            completionHandler?(nil)
            return
        }
        
        stream.stopCapture { error in
            if let error = error {
                print("Error stopping capture: \(error.localizedDescription)")
                self.continuation?.finish(throwing: error)
            } else {
                self.continuation?.finish()
            }
            
            completionHandler?(error)
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
    
    var capturedFrameHandler: ((CapturedFrame) -> Void)?

    // Store the  startCapture continuation, so you can cancel it if an error occurs.
    private var continuation: AsyncThrowingStream<CapturedFrame, Error>.Continuation?
    
    init(continuation: AsyncThrowingStream<CapturedFrame, Error>.Continuation?) {
        self.continuation = continuation
        super.init()

    }

    /// - Tag: DidOutputSampleBuffer
    func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of outputType: SCStreamOutputType) {

        // Return early if the sample buffer is invalid.
        guard sampleBuffer.isValid else { return }
        
        // Create a CapturedFrame structure for a video sample buffer.
        guard let frame = createFrame(for: sampleBuffer) else { return }
        capturedFrameHandler?(frame)

    }
    
    /// Create a `CapturedFrame` for the video sample buffer.
    private func createFrame(for sampleBuffer: CMSampleBuffer) -> CapturedFrame? {
    
        
        // Retrieve the array of metadata attachments from the sample buffer.
        guard let attachmentsArray = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer,
                                                                             createIfNecessary: false) as? [[SCStreamFrameInfo: Any]],
              let attachments = attachmentsArray.first else { return nil }
        
        // Validate the status of the frame. If it isn't `.complete`, return nil.
        guard let statusRawValue = attachments[SCStreamFrameInfo.status] as? Int,
              let status = SCFrameStatus(rawValue: statusRawValue),
              status == .complete else { return nil }
        
        // Get the pixel buffer that contains the image data.
        guard let pixelBuffer = sampleBuffer.imageBuffer else {
            print("NO IMAGE BUFFER IS PRESENT")
            return nil
        }
        
        // Get the backing IOSurface.
        guard let surfaceRef = CVPixelBufferGetIOSurface(pixelBuffer)?.takeUnretainedValue() else { return nil }
        let surface = unsafeBitCast(surfaceRef, to: IOSurface.self)
        
        // Retrieve the content rectangle, scale, and scale factor.
        guard let contentRectDict = attachments[.contentRect],
              let contentRect = CGRect(dictionaryRepresentation: contentRectDict as! CFDictionary),
              let contentScale = attachments[.contentScale] as? CGFloat,
              let scaleFactor = attachments[.scaleFactor] as? CGFloat else { return nil }

        // Create a new frame with the relevant data.
        let frame = CapturedFrame(imageBuffer: pixelBuffer,
                                  contentRect: contentRect,
                                  contentScale: contentScale,
                                  scaleFactor: scaleFactor)
        
//        print("frame made at: ", Date().timeIntervalSince1970)
        return frame
    }
    
   
    func stream(_ stream: SCStream, didStopWithError error: Error) {
       print("The stream was stopped with an ERROR at the time of: ", Date().timeIntervalSince1970)
       continuation?.finish(throwing: error)
   }
}
