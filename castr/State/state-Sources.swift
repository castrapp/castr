//
//  state-Sources.swift
//  castr
//
//  Created by Harrison Hall on 8/4/24.
//

import Foundation

class SourcesState: ObservableObject {
    
    static let shared = SourcesState()
    
    var scenesState = ScenesState.shared
    var previewManager = PreviewerManager.shared
    
    @Published var globalSources:[SourceModel] = []
    @Published var localSources:[SourceModel] = []
    @Published var selectedSourceId: String = ""
    var localSourcesModificationToken: Date { localSources.map { $0.lastModified }.max() ?? Date.distantPast}
    
    private init() {}
    
    func addSource(sourceType: SourceType, name: String) {
        guard !scenesState.selectedSceneId.isEmpty else {
            print("Error: No scene selected. Please select a scene before adding a source.")
            return
        }
        
        switch sourceType {
            case .screenCapture:    addScreenCaptureSource(name: name)
            case .windowCapture:    addWindowCaptureSource(name: name)
        }
    }
    
    private func addScreenCaptureSource(name: String) {
        let newSourceId = UUID().uuidString
        globalSources.append(
            ScreenCaptureSourceModel(
                type: .screenCapture,
                id: newSourceId,
                name: name.isEmpty ? "Screen Capture" : name,
                isActive: false,
                isSelected: false,
                display: "",
                excludedApps: []
            )
        )
        
        setSelectedSource(sourceId: newSourceId)
        
        scenesState.addSourceIdToScene(sourceId: newSourceId)
        
        updateLocalSources()
        
        Task {
            await previewManager.addScreenCapture()
        }
     
    }
    
    private func addWindowCaptureSource(name: String) {
        let newSourceId = UUID().uuidString
        globalSources.append(
            WindowCaptureSourceModel(
                type: .windowCapture,
                id: newSourceId,
                name: name.isEmpty ? "Window Capture" : name,
                isActive: false,
                isSelected: false,
                window: ""
            )
        )
        
        setSelectedSource(sourceId: newSourceId)
        
        scenesState.addSourceIdToScene(sourceId: newSourceId)
        
        updateLocalSources()
    }
    
    func updateLocalSources() {
        // Find the selected scene
        guard let selectedScene = scenesState.scenes.first(where: { $0.id == scenesState.selectedSceneId }) else {
            // If no scene is selected, clear local sources
            localSources = []
            return
        }
        
        // Update local sources based on the selected scene's sources
        localSources = selectedScene.sources.compactMap { sourceId in
            // Find the corresponding source in globalSources
            globalSources.first { $0.id == sourceId }
        }
    }
    
    func setSelectedSource(sourceId: String) {
        globalSources.indices.forEach { index in
            globalSources[index].isSelected = (globalSources[index].id == sourceId)
        }
        
        selectedSourceId = sourceId
    }
    
    func deleteSelectedSource(sourceId: String? = nil) {
        let idToDelete = sourceId ?? selectedSourceId
        
        
        
    }
}
