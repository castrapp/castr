//
//  view-PreviewPanel.swift
//  castr
//
//  Created by Harrison Hall on 8/4/24.
//

import Foundation
import SwiftUI


struct PreviewPanel: View {
    
    @ObservedObject var globalState = GlobalState.shared
    let previewer = Previewer.shared
    

    
    var body: some View {
        previewer
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(CGSize(width: 1728, height: 1117), contentMode: .fit)
        .border(.quaternary, width: 1)
        .background(.ultraThickMaterial)
        .padding(.horizontal, 10)
    }
}
