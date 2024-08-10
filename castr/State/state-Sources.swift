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
        case .image:            addImageSource(name: sourceName)
        case .color:            addColorSource(name: sourceName)
        case .text:             addTextSource(name: sourceName)
        }
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
