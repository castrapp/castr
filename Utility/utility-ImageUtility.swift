//
//  utility-ImageUtility.swift
//  castr
//
//  Created by Harrison Hall on 8/26/24.
//

import Foundation
import AppKit
import IOSurface


//@MainActor
//class ImageRenderManager: ObservableObject {
//    
//    
//    var image: NSImage
//    var model: ImageSourceModel
//    var previewLayer: CAMetalLayer
//    
//    
//    init(
//        model: ImageSourceModel,
//        image: model.image,
//        
//        previewLayer: CAMetalLayer
//    ) {
//        self.image = image
//        self.model = model
//        self.previewLayer = previewLayer
//        
//        start()
//    }
//    
//    
//    func start() {
//        guard
//            let cgImage = nSImageToCGImage(from: image),
//            let ioSurface = createIOSurface(from: cgImage)
//        else { return }
//        
//        
//        print("Successfully converted NSImage to IOSurface: ", )
//    }
//    
//    func stop() {
//        model.mtlTexture = nil
//    }
//}



//
//
//func nSImageToCGImage(from nsImage: NSImage) -> CGImage? {
//    guard let imageData = nsImage.tiffRepresentation,
//          let bitmapImage = NSBitmapImageRep(data: imageData) else {
//        return nil
//    }
//    print("Converted NSImage to CGImage: ", bitmapImage.cgImage)
//    return bitmapImage.cgImage
//}
//
//
//func createIOSurface(from cgImage: CGImage) -> IOSurface? {
//    let width = cgImage.width
//    let height = cgImage.height
//    let bytesPerPixel = 4 // Assuming a 32-bit pixel format like BGRA
//    let unalignedBytesPerRow = width * bytesPerPixel
//    let alignment = 16
//    let alignedBytesPerRow = (unalignedBytesPerRow + alignment - 1) / alignment * alignment
//    
//    let surfaceProperties: [IOSurfacePropertyKey: Any] = [
//        .width: width,
//        .height: height,
//        .bytesPerRow: alignedBytesPerRow,
//        .pixelFormat: kCVPixelFormatType_32BGRA
//    ]
//    
//    guard let surface = IOSurface(properties: surfaceProperties) else {
//        return nil
//    }
//    
//    return surface
//}
//
//func drawImageToIOSurface(cgImage: CGImage, surface: IOSurface) {
//    let width = cgImage.width
//    let height = cgImage.height
//    let bytesPerPixel = 4 // Assuming a 32-bit pixel format like BGRA
//    let unalignedBytesPerRow = width * bytesPerPixel
//    let alignment = 16
//    let alignedBytesPerRow = (unalignedBytesPerRow + alignment - 1) / alignment * alignment
//    
//    IOSurfaceLock(surface, [], nil)
//    
//    if let context = CGContext(data: IOSurfaceGetBaseAddress(surface),
//                               width: width,
//                               height: height,
//                               bitsPerComponent: cgImage.bitsPerComponent,
//                               bytesPerRow: alignedBytesPerRow,
//                               space: cgImage.colorSpace!,
//                               bitmapInfo: cgImage.bitmapInfo.rawValue) {
//        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
//    }
//    
//    IOSurfaceUnlock(surface, [], nil)
//}
//
//
//func createPixelBuffer(from ioSurface: IOSurface) -> CVPixelBuffer? {
//    var unmanagedPixelBuffer: Unmanaged<CVPixelBuffer>?
//    
//    let pixelBufferAttributes: [CFString: Any] = [
//        kCVPixelBufferIOSurfacePropertiesKey: [:]
//    ]
//
//    let result = CVPixelBufferCreateWithIOSurface(
//        kCFAllocatorDefault,
//        ioSurface,
//        pixelBufferAttributes as CFDictionary,
//        &unmanagedPixelBuffer
//    )
//
//    guard result == kCVReturnSuccess else {
//        print("Error: Unable to create CVPixelBuffer from IOSurface.")
//        return nil
//    }
//
//    // Convert Unmanaged<CVPixelBuffer> to CVPixelBuffer
//    return unmanagedPixelBuffer?.takeRetainedValue()
//}




let device = MTLCreateSystemDefaultDevice()!
let commandQueue = device.makeCommandQueue()!


