//
//  state-Preview.swift
//  castr
//
//  Created by Harrison Hall on 8/4/24.
//

import Foundation
import SwiftUI
import ScreenCaptureKit

@MainActor
class PreviewerManager: ObservableObject {
    
    static let shared = PreviewerManager()
    let previewer = Previewer.shared
    
    
    private init() {
        
    }
    
    func addScreenCapture() async {
        print("starting the screen capture")
        
        do {
            let captureEngine = CaptureEngine()
            let availableContent = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
            guard let mainDisplay = availableContent.displays.first else {
                print("Main display not found")
                return
            }
            
            let config = SCStreamConfiguration()
            let filter = SCContentFilter(display: mainDisplay, excludingWindows: [])
            
            for try await frame in  captureEngine.startCapture(configuration: config, filter: filter){
           
                    previewer.contentLayer.contents = frame.surface
                    previewer.contentLayer.contentsScale = frame.contentScale
                    previewer.contentLayer.contentsCenter = CGRect(x: 0, y: 0, width: 1, height: 1)
                    previewer.contentLayer.contentsGravity = .resizeAspect
                
//                print("rendering frame")
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
}
