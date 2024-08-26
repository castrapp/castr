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


logger.warning("SETTING UP NOTIFICAITON RECIEVER")
logger.warning("SETTING UP NOTIFICAITON RECIEVER")
logger.warning("SETTING UP NOTIFICAITON RECIEVER")
logger.warning("SETTING UP NOTIFICAITON RECIEVER")
let notificationName = Notification.Name("com.yourcompany.yourapp.UserDefaultsDidChange")
// Observe the notification in another process
DistributedNotificationCenter.default().addObserver(
    forName: notificationName,
    object: nil,
    queue: .main) { notification in
        logger.warning("RECIEVED A NOTIFICATION: \(notification, privacy: .public)")
        logger.warning("RECIEVED A NOTIFICATION: \(notification, privacy: .public)")
        logger.warning("RECIEVED A NOTIFICATION: \(notification, privacy: .public)")
        logger.warning("RECIEVED A NOTIFICATION: \(notification, privacy: .public)")
}


CFRunLoopRun()
