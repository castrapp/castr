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
    
    // TODO: Whenever the sceneId changes, we nede to iterate through the list
    // TODO: of sources, all of them, and do 2 checks:
    //
    //              • If there 'scenes' array DOES CONTAIN the selectedSceneId then:
    //                then call 'start' or something.
    //
    //              • If there 'scenes' array DOES NOT CONTAIN the selectedSceneId then:
    //                then call 'stop' or something.
    
    var body: some View {
        previewer
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(CGSize(width: 1728, height: 1117), contentMode: .fit)
        .border(.quaternary, width: 1)
        .background(.ultraThickMaterial)
        .padding(.horizontal, 10)
        .onChange(of: globalState.selectedSourceId) { newSourceId in
            
            // (PsuedoCode implementation)
            //
            // for each source of globalState.sources {
            //      if source.scenes.contains(globalState.selectedSourceId) {
            //          source.start()
            //      } else {
            //          source.stop()
            //      }
            // }
        }
    }
}
