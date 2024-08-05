//
//  state-Scenes.swift
//  castr
//
//  Created by Harrison Hall on 8/4/24.
//

import Foundation


class ScenesState: ObservableObject {
    
    static let shared = ScenesState()
    
    @Published var scenes:[SceneModel]  = [];
    @Published var selectedSceneId: String = ""
    
    private init() {}
    
    func addScene(name: String) {
        let newSceneId = UUID().uuidString
        scenes.append(
            SceneModel(
                id: newSceneId,
                name: name.isEmpty ? "Scene \(scenes.count + 1)" : name,
                isActive: false,
                isSelected: false,
                sources: []
            )
        )
        setSelectedSceneId(sceneId: newSceneId)
    }
    
    func setSelectedSceneId(sceneId: String) {
        // Set the isSelected Property of the selected scene
        scenes.indices.forEach { index in
            scenes[index].isSelected = (scenes[index].id == sceneId)
        }
        
        // Set the selectedSceneId to the one passed in
        selectedSceneId = sceneId
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
        
        // Update isSelected for the newly selected scene
        setSelectedSceneId(sceneId: selectedSceneId)
    }
    
    func addSourceIdToScene(sourceId: String) {
        guard let index = scenes.firstIndex(where: { $0.id == selectedSceneId }) else { return }
        scenes[index].sources.append(sourceId)
    }
    
}
