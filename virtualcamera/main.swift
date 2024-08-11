//
//  main.swift
//  virtualcamera
//
//  Created by Harrison Hall on 8/11/24.
//

import Foundation
import CoreMediaIO

let providerSource = virtualcameraProviderSource(clientQueue: nil)
CMIOExtensionProvider.startService(provider: providerSource.provider)

CFRunLoopRun()
