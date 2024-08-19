import Foundation




import Foundation


extension GlobalState {
    
    func addSource(sourceType: SourceType, name: String) {
        guard !selectedSceneId.isEmpty else {
            print("Error: No scene selected. Please select a scene before adding a source.")
            return
        }
        
        let sourceName = name.isEmpty ? "Source" : name
        
        switch sourceType {
        case .screenCapture:    addScreenCaptureSource(name: sourceName)
        case .windowCapture:    addWindowCaptureSource(name: sourceName)
        case .video:            addVideoSource(name: sourceName)
        case .image:            addImageSource(name: sourceName)
        case .color:            addColorSource(name: sourceName)
        case .text:             addTextSource(name: sourceName)
        }
    }
    
    func deleteSelectedSource() {
        print("sources array before deleting: ", sources)
        guard !selectedSourceId.isEmpty else { return }
        
        // Find the index of the source to be deleted
        guard let indexToDelete = sources.firstIndex(where: { $0.id == selectedSourceId }) else { return }
        
        // Get the source to be deleted
        let sourceToDelete = sources[indexToDelete]
        
        // Remove the source from the sources array
        sources.remove(at: indexToDelete)
        
        // Remove the source ID from all scenes that contain it
        for i in 0..<scenes.count {
            scenes[i].sources.removeAll { $0 == selectedSourceId }
        }
        
        // Stop the source if it's a ScreenCaptureSourceModel
        if let screenCaptureSource = sourceToDelete as? ScreenCaptureSourceModel {
            Task { @MainActor in
                await screenCaptureSource.stop()
            }
        }
        
        // Clear the selected source ID
        selectedSourceId = ""
        
        print("sources array after deleting: ", sources)
    }
    

    func addScreenCaptureSource(name: String) {
        // TODO: Create the new Source Model
        let screenCaptureSource = ScreenCaptureSourceModel(name: name)
    
        // TODO: Add the selectedSceneId to the source's scenes array
        screenCaptureSource.scenes.append(selectedSceneId)
    
        // TODO: Add the sourceId to the selected scene's sources array
        addSourceIdToScene(sourceId: screenCaptureSource.id)
    
        // TODO: Add the new source model the sources array
        sources.append(screenCaptureSource)
    
        // TODO: Set the selectedSourceId to the new source's id
        selectedSourceId = screenCaptureSource.id
    
        // TODO: Start the source
        Task { @MainActor in
           await screenCaptureSource.start()
        }
    }
    
    
    func addWindowCaptureSource(name: String) {
        // TODO: Create the new Source Model
        let windowCaptureSource = WindowCaptureSourceModel(name: name)
    
        // TODO: Add the selectedSceneId to the source's scenes array
        windowCaptureSource.scenes.append(selectedSceneId)
    
        // TODO: Add the sourceId to the selected scene's sources array
        addSourceIdToScene(sourceId: windowCaptureSource.id)
    
        // TODO: Add the new source model the sources array
        sources.append(windowCaptureSource)
    
        // TODO: Set the selectedSourceId to the new source's id
        selectedSourceId = windowCaptureSource.id
    
        // TODO: Start the source
        Task { @MainActor in
           await windowCaptureSource.start()
        }
    }
    
    
    
    func addVideoSource(name: String) {
        // TODO: Create the new Source Model
        let videoSource = VideoSourceModel(name: name)
    
        // TODO: Add the selectedSceneId to the source's scenes array
        videoSource.scenes.append(selectedSceneId)
    
        // TODO: Add the sourceId to the selected scene's sources array
        addSourceIdToScene(sourceId: videoSource.id)
    
        // TODO: Add the new source model the sources array
        sources.append(videoSource)
    
        // TODO: Set the selectedSourceId to the new source's id
        selectedSourceId = videoSource.id
    
        // TODO: Start the source
        Task { @MainActor in
            await videoSource.start()
        }
    }
    
    
    
    func addImageSource(name: String) {
        // TODO: Create the new Source Model
        let imageSource = ImageSourceModel(name: name)
    
        // TODO: Add the selectedSceneId to the source's scenes array
        imageSource.scenes.append(selectedSceneId)
    
        // TODO: Add the sourceId to the selected scene's sources array
        addSourceIdToScene(sourceId: imageSource.id)
    
        // TODO: Add the new source model the sources array
        sources.append(imageSource)
    
        // TODO: Set the selectedSourceId to the new source's id
        selectedSourceId = imageSource.id
    
        // TODO: Start the source
        Task { @MainActor in
            await imageSource.start()
        }
    }
    
    
    func addColorSource(name: String) {
        // TODO: Create the new Source Model
        let colorSource = ColorSourceModel(name: name)
    
        // TODO: Add the selectedSceneId to the source's scenes array
        colorSource.scenes.append(selectedSceneId)
    
        // TODO: Add the sourceId to the selected scene's sources array
        addSourceIdToScene(sourceId: colorSource.id)
    
        // TODO: Add the new source model the sources array
        sources.append(colorSource)
    
        // TODO: Set the selectedSourceId to the new source's id
        selectedSourceId = colorSource.id
    
        // TODO: Start the source
        Task { @MainActor in
            await colorSource.start()
        }
    }
    
    
    func addTextSource(name: String) {
        // TODO: Create the new Source Model
        let textSource = TextSourceModel(name: name)
    
        // TODO: Add the selectedSceneId to the source's scenes array
        textSource.scenes.append(selectedSceneId)
    
        // TODO: Add the sourceId to the selected scene's sources array
        addSourceIdToScene(sourceId: textSource.id)
    
        // TODO: Add the new source model the sources array
        sources.append(textSource)
    
        // TODO: Set the selectedSourceId to the new source's id
        selectedSourceId = textSource.id
    
        // TODO: Start the source
        Task { @MainActor in
            await textSource.start()
        }
    }
}
