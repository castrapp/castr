//
//  state - Global.swift
//  castr
//
//  Created by Harrison Hall on 8/8/24.
//

import Foundation

class GlobalState: ObservableObject {
    
    static let shared = GlobalState()
    
    private init() {}
    
    
    @Published var delayFrames = false
    
    
    
    /// `Layout Properties`
    @Published var isRightPanelOpen = true;
    @Published var isLeftPanelOpen = true;
    
    @Published var rightPanelMaxWidth = CGFloat(270);
    @Published var leftPanelMaxWidth = CGFloat(242);
    
    
    
    
    /// `Scenes Properties`
    @Published var scenes:[SceneModel]  = [];
    @Published var selectedSceneId: String = "" {
        didSet {
            selectedSourceId = ""
            updateCurrentSources()
            for source in currentSources {
                // TODO: Call the start method
            }
        }
    }
    
    
    
    
    /// `Sources Properties`
    @Published var sources:[SourceModel] = [] 
    @Published var currentSources:[SourceModel] = []
    @Published var currentSource: SourceModel?
    @Published var selectedSourceId: String = "" {
        didSet {
            if selectedSourceId.isEmpty {
                LayoutState.shared.selectedSourceLayer = nil
            } else {
                LayoutState.shared.selectedSourceLayer = sources.first { $0.id == selectedSourceId }?.layer
            }
        }
    }
    @Published var streamToVirtualCamera: Bool = false
    @Published var selectedSourceLayer: CustomMetalLayer? = nil {
        didSet {
//            print("selected source is: ", selectedSourceLayer)
        }
    }
    
}
