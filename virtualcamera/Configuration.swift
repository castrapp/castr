

import Foundation
import AVFoundation
import CoreMediaIO
import IOKit.audio
import os.log
import Cocoa
import os

let textColor = NSColor.white
let fontSize = 24.0
let textFont = NSFont.systemFont(ofSize: fontSize)
let CMIOExtensionPropertyCustomPropertyData_just: CMIOExtensionProperty = CMIOExtensionProperty(rawValue: "4cc_just_glob_0000")
let kWhiteStripeHeight: Int = 10



let kFrameRate: Int = 30
let cameraName = "Castr Virtual Camera"
let fixedCamWidth: Int32 = 3456
let fixedCamHeight: Int32 = 2234
//let fixedCamWidth: Int32 = 1728
//let fixedCamHeight: Int32 = 1118
let pixelFormat: OSType = kCVPixelFormatType_32BGRA
//let pixelFormat: OSType = kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange

// Color space and other properties
let colorPrimaries = kCVImageBufferColorPrimaries_ITU_R_709_2
let transferFunction = kCVImageBufferTransferFunction_ITU_R_709_2
let yCbCrMatrix = kCVImageBufferYCbCrMatrix_ITU_R_709_2
