//
//  view-VideoConfiguration.swift
//  castr
//
//  Created by Harrison Hall on 8/25/24.
//

import Foundation
import SwiftUI

struct VideoConfiguration: View {
    @ObservedObject var model: VideoSourceModel

    var body: some View {
        VStack {
            Text("Video Configuration")
                .font(.headline)
            
            // Add your video configuration UI elements here
            // For example:
            // Picker for selecting camera
            // Toggle for enabling/disabling video
            // Sliders for adjusting video properties
            
            // This is just a placeholder. Replace with actual configuration options.
            Text("Configure video settings here")
                .foregroundColor(.secondary)
        }
        .padding()
    }
}
