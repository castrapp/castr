//
//  main.swift
//  virtualcamera
//
//  Created by Harrison Hall on 8/11/24.
//

import Foundation
import CoreMediaIO
import OSLog

let providerSource = virtualcameraProviderSource(clientQueue: nil)
let logger = Logger(subsystem: "harrisonhall.castr.virtualcamera", category: "VirtualCamera")
CMIOExtensionProvider.startService(provider: providerSource.provider)
logger.info("RUNNING THE MAIN FILE")

CFRunLoopRun()



