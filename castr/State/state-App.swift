//
//  state-App.swift
//  castr
//
//  Created by Harrison Hall on 8/24/24.
//

import Foundation

class App: ObservableObject {
    
    static let shared = App()
    
    private init() {}
    
    
    /// `Window Properties`
    @Published var defaultWindowPadding = CGFloat(0)
    @Published var trafficLightPadding = CGFloat(0)
    @Published var rightPanelWidth = CGFloat(400)
    @Published var leftPanelWidth = CGFloat(400)
    
    

    /// `Scenes Properties`
    @Published var scenes:[SceneModel]  = [];
    @Published var selectedSceneId: String = "" {
        didSet {
            print("new selected scene Id is: ", selectedSceneId)
        }
    }
}





extension App {
    
    func addScene(name: String? = nil) {
        let newSceneId = UUID().uuidString
        let sceneName = name ?? "Scene \(scenes.count + 1)"
        scenes.append(
            SceneModel(
                id: newSceneId,
                name: sceneName,
                isActive: false,
                sources: []
            )
        )
        selectedSceneId = newSceneId
    }
    
    func deleteSelectedScene() {
        
        // Get the index of the scene to be deleted
        guard let indexToDelete = scenes.firstIndex(where: { $0.id == selectedSceneId }) else { return }
        
        // Remove the scene
        scenes.remove(at: indexToDelete)
        
        // Update selectedSceneId based on remaining scenes
        if !scenes.isEmpty {
            if indexToDelete < scenes.count {
                // If there's a scene at the same index, select it
                selectedSceneId = scenes[indexToDelete].id
            } else {
                // Otherwise, select the last scene
                selectedSceneId = scenes.last!.id
            }
        } else {
            // If no scenes left, clear the selection
            selectedSceneId = ""
        }
        
//        sources.removeAll()
    }
}
