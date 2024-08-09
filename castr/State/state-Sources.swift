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
        case .screenCapture:
            addScreenCaptureSource(name: sourceName)
        case .windowCapture:
            addWindowCaptureSource(name: sourceName)
        case .image:
            addImageSource(name: sourceName)
        case .color:
            addColorSource(name: sourceName)
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
            Task {
               await screenCaptureSource.start()
            }
        
      
        
//        Task {
//            await screenCaptureSource.initializeContent()
//        }
    }
    
    func addWindowCaptureSource(name: String) {
        let windowCaptureSource = WindowCaptureSourceModel(name: name)
        windowCaptureSource.scenes.append(selectedSceneId)
        sources.append(windowCaptureSource)
        selectedSourceId = windowCaptureSource.id
        addSourceIdToScene(sourceId: windowCaptureSource.id)
    }
    
    
    
    func addImageSource(name: String) {
        
    }
    
    
    func addColorSource(name: String) {
        // TODO: Create the new Source Model
        let colorSource = ColorSource(name: name)
    
        // TODO: Add the selectedSceneId to the source's scenes array
        colorSource.scenes.append(selectedSceneId)
    
        // TODO: Add the sourceId to the selected scene's sources array
        addSourceIdToScene(sourceId: colorSource.id)
    
        // TODO: Add the new source model the sources array
        sources.append(colorSource)
    
        // TODO: Set the selectedSourceId to the new source's id
        selectedSourceId = colorSource.id
    
        // TODO: Start the source
        colorSource.start()
    }
}
