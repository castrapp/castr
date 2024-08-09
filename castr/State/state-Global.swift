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
    
    
    
    
    /// `Layout Properties`
    @Published var isRightPanelOpen = true;
    @Published var isLeftPanelOpen = true;
    
    @Published var rightPanelMaxWidth = CGFloat(270);
    @Published var leftPanelMaxWidth = CGFloat(242);
    
    
    
    
    /// `Scenes Properties`
    @Published var scenes:[SceneModel]  = [];
    @Published var selectedSceneId: String = "" {
        didSet {
            print("selected Scene Id has changed: ", selectedSceneId)
            // Iterate through local scenes
        }
    }
    
    
    
    
    /// `Sources Properties`
    @Published var sources:[SourceModel] = []
    @Published var selectedSourceId: String = ""
}
