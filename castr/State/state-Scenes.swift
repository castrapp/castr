//
//  state-Scenes.swift
//  castr
//
//  Created by Harrison Hall on 8/4/24.
//

import Foundation


extension GlobalState {
    
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
    
    func deleteSelectedScene(sceneId: String? = nil) {
        let idToDelete = sceneId ?? selectedSceneId
        
        // Get the index of the scene to be deleted
        guard let indexToDelete = scenes.firstIndex(where: { $0.id == idToDelete }) else { return }
        
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
        
        sources.removeAll()
//        currentSources.removeAll()
    }
    
    func addSourceIdToScene(sourceId: String) {
        guard let scene = getSelectedScene() else { return }
//        scene.sources.insert(sourceId, at: 0)
        scene.sources.append(sourceId) 
    }
    
    
    func getSelectedScene() -> SceneModel? {
        return scenes.first { $0.id == selectedSceneId } ?? nil
    }
    
}
