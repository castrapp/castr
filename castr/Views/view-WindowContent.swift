//
//  ContentView.swift
//  castr
//
//  Created by Harrison Hall on 8/3/24.
//




import Foundation
import SwiftUI

struct ContentView: View {
    
    @ObservedObject var content = ContentModel.shared
    @ObservedObject var global = GlobalState.shared
    let previewer = Previewer.shared
    let layout = Layout.shared
    @State var counter: Double = 0
    
    var mainSection = Main.shared
    

    var body: some View {
        HSplitView {
            
            leftSidebar
        
            mainSection
            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .border(Color.red)
          
            rightSidebar
        }
        .sheet(isPresented: $content.showAddSourceSheet) {
            if(!global.selectedSceneId.isEmpty) {
                AddSourceSheet()
            }
        }
        .sheet(isPresented: $content.showInitialPermissionsSheet) {
            initialPermissionsSheet
        }
        
    }
    
    
    
    
    /// `Left Sidebar`
    var leftSidebar: some View {
        VStack {
            Scenes()
            Sources()
        }
        .frame(minWidth: 300, maxWidth: 300, maxHeight: .infinity)
        .background(MaterialView(material: .sidebar))
    }
    
   
    
    /// `Right Sidebar`
    var rightSidebar: some View {
        VStack{
            Button("Start extension") {
                CameraViewModel.shared.start()
                GlobalState.shared.streamToVirtualCamera = true
            }
            Button("Reinstall extension") {
                SystemExtensionManager.shared.installExtension(extensionIdentifier: "harrisonhall.castr.virtualcamera") { success, error in
                    if success {
                        print("Castr Virtual Camera installed successfully")
                    } else {
                        if let error = error {
                            print("Failed to install Castr Virtual Camera: \(error.localizedDescription)")
                        } else {
                            print("Failed to install Castr Virtual Camera")
                        }
                    }
                }
            }
            Button("Set Just Property") {
                CameraViewModel.shared.setJustProperty2()
            }
            Button("Print scenes sources") {
                guard let currentScene = GlobalState.shared.getSelectedScene() else { return }
                print("sources are: ", currentScene.sources)
            }
            Button("Print sublayers") {
                print("sublayers are: ", previewer.contentLayer.sublayers)
            }
   
           

  
           
            Button("flip horizontally") {
                guard let selectedSource = LayoutState.shared.selectedSourceLayer else { return }
                selectedSource.setAffineTransform(CGAffineTransform(scaleX: -1.0, y: 1.0))
//                Main.shared.onSelectlayer.setAffineTransform(CGAffineTransform(scaleX: -1.0, y: 1.0))
                Main.shared.onSelectlayer.setAffineTransform(CGAffineTransform(scaleX: -1.0, y: 1.0))
            }
            Controls()
            SourceConfiguration()
        }
        .frame(minWidth: 300, maxWidth: 300, maxHeight: .infinity)
        .background(MaterialView(material: .sidebar))
    }
    

    
    
    
    
    
    /// `Request Initial Permissions Sheet`
    var initialPermissionsSheet: some View {
        VStack(spacing: 0) {
            Text("Permissions")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.vertical, 40)
            
            
           
            VStack(alignment: .leading, spacing: 10) {
                
                HStack(spacing: 16) {
                    Image(systemName: "rectangle.inset.filled.badge.record")
                    .font(.system(size: 32))
                    .padding(.leading, 6)
                    .padding(.trailing, 2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Screen Recording")
                            .font(.system(size: 14, weight: .bold))
                        
                        Text("This allows Castr to record the contents of your screen and system audio, even while using other applications. Castr requires this permission to be able to capture your screen.")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    }
                }
               
                Divider()
                
                HStack {
                    Spacer()
                    Text("Click to enable this permission.")
                        .foregroundStyle(.secondary)
                        .font(.system(size: 12))
                }
                
            }
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
            ._groupBox()
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 30)
            
            
            
            Spacer()
            
            Divider()
            
            HStack {
                Button("Another time") {
                    print("canceling")
                    content.showAddSourceSheet = false
                }
                .buttonStyle(.borderless)
                .controlSize(.large)
                
                Spacer()
                
                Button("Confirm") {
//                    print("confirming")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .frame(maxWidth: .infinity)
            .padding(22)
            
        }
        .frame(maxWidth: 700, minHeight: 500, alignment: .top)
    }

}





/// `Scences`

struct Scenes: View {
    @ObservedObject var app = App.shared
    @ObservedObject var global = GlobalState.shared
    
    var body: some View {
        VStack(spacing: 0) {
            Header
            
            Divider()._panelDivider()
            
            SceneList
            
            ControlGroup {
                Menu {
                        Button("Option 1", action: { print("Option 1 selected") })
                        Button("Option 2", action: { print("Option 2 selected") })
                        Button("Option 3", action: { print("Option 3 selected") })
                    } label: {
                    }
            }
            
            Spacer().frame(maxWidth: .infinity, maxHeight: 1).background(Color(nsColor: .quaternaryLabelColor))
            
            AddRemoveButtons
        }
        ._groupBox(padding: 10)
    }
    
    
    
    
    /// `Components`
    
    var Header: some View {
        HStack {
            Text("Scenes")._panelHeaderText()
        }
        .frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
    }
    
    var SceneList: some View {
        List(selection: $global.selectedSceneId) {
            ForEach(global.scenes, id: \.id) { scene in
                HStack {
                    Image(systemName: "square.3.layers.3d")
                    .font(.system(size: 20))
                    
                    VStack(alignment: .leading) {
                        Text(scene.name)
                        Text("0 Sources")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    }
                   
                }
                .frame(height: 32)
                
            }
            .onMove(perform: move)
        }
        .listStyle(SidebarListStyle()) // Sidebar style for macOS
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var AddRemoveButtons: some View {
        PanelFooter(
            onAdd: {
                print("Adding Scene")
                GlobalState.shared.addScene()
            },
            onDelete: {
                print("Deleting Delete")
                GlobalState.shared.deleteSelectedScene()
            }
        )
    }
    

    func move(from source: IndexSet, to destination: Int) {
        global.scenes.move(fromOffsets: source, toOffset: destination)
    }
 
}







/// `Sources`

struct Sources: View {
    
    @ObservedObject var content = ContentModel.shared
    @ObservedObject var global = GlobalState.shared
    @State private var showPopover = false
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            HStack {
                Text("Sources")._panelHeaderText()
            }
            .frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
            
            Divider()._panelDivider()
            
            
            List(selection: $global.selectedSourceId) {
                ForEach(global.currentSources, id: \.id) { source in
                
                    HStack {
                        source.type.imageThumbnail(active: source.isActive)
                        VStack(alignment: .leading) {
                            Text(source.name)
                            Text(source.type.name)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        }
                        
                    }
                    .frame(height: 32)
                }
                .onMove(perform: move)
            }
            .listStyle(SidebarListStyle()) // Sidebar style for macOS
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            
            Spacer().frame(maxWidth: .infinity, maxHeight: 1).background(Color(nsColor: .quaternaryLabelColor))
            
            HStack(spacing: 0) {
                addButton
                Spacer().frame(maxWidth: 1, maxHeight: .infinity).background(Color(nsColor: .quaternaryLabelColor)).padding(.vertical, 8)
                deleteButton
                Spacer()
    //            Menu("Options") {
    //            }
    //            .fixedSize()
            }
            .frame(maxWidth: .infinity, maxHeight: 32, alignment: .leading)
            .background(WindowBackgroundShapeStyle.windowBackground.opacity(0.5))
        }
        ._groupBox(padding: 10)
    }
    
    
    var addButton: some View {
        
        ZStack {
            Image(systemName: "plus")
            .font(.system(size: 12))
        }
        .frame(maxWidth: 26, maxHeight: .infinity)
        ._panelButton {
            if(!global.selectedSceneId.isEmpty) {
                showPopover = true
            }
        }
        .padding(4)
        .popover(isPresented: $showPopover, arrowEdge: .bottom) {
            
            
            Button("Screen Capture Source"){
                print("adding Screen Capture source")
                content.showAddSourceSheet = true
                content.newSourceSelection = .screenCapture
                showPopover = false
            }
            
            Button("Color Source"){
                print("adding color source")
                content.showAddSourceSheet = true
                content.newSourceSelection = .color
                showPopover = false
            }
            
            Button("Image Source"){
                print("adding image source")
                content.showAddSourceSheet = true
                content.newSourceSelection = .image
                showPopover = false
            }
            
        }
    }
    
    
    var deleteButton: some View {
        ZStack {
            Image(systemName: "minus")
            .font(.system(size: 12))
        }
        .frame(maxWidth: 26, maxHeight: .infinity)
        ._panelButton {
            GlobalState.shared.deleteSelectedSource()
        }
        .padding(4)
    }
    
    
    func move(from source: IndexSet, to destination: Int) {
        guard let currentScene = global.getSelectedScene() else { return }
        
        print("source is: ", source)
        print("destination is: ", destination)
        
        currentScene.sources.move(fromOffsets: source, toOffset: destination)
        
        Previewer.shared.contentLayer.sublayers?.move(fromOffsets: source, toOffset: destination)
        
        global.updateCurrentSources()
    }
 
    
    
}










/// `Controls`

struct Controls: View {
    @ObservedObject var output = OutputService.shared
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            HStack {
                Text("Controls")._panelHeaderText()
            }
            .frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
            
            Divider()._panelDivider()
            
            HStack {
                Text(output.isStreamingToVirtualCamera ? "Stop Virtual Camera" : "Start Virtual Camera")
                
                Spacer()
                
                Toggle("", isOn: $output.isStreamingToVirtualCamera)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle())
            }
            .frame(maxWidth: .infinity, maxHeight: 30, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            
            Spacer().panelSubSeparatorStyle()
            
            HStack {
                Text(output.isRecording ? "Stop Recording" : "Start Recording")
                
                Spacer()
                
                Toggle("", isOn: $output.isRecording)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle())
            }
            .frame(maxWidth: .infinity, maxHeight: 30, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
        }
        ._groupBox(padding: 10)
    }
}




/// `Source Configuration`

struct SourceConfiguration: View {
    @ObservedObject var global = GlobalState.shared
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            Header
            
            Divider()._panelDivider()
            
//            SourceConfig
            if !global.selectedSourceId.isEmpty {
                if let source = global.getCurrentSource() {
                    if source.type == .screenCapture {
                        ScreenCaptureConfiguration(model: source as! ScreenCaptureSourceModel)
                    }
                }
            }
        
        }
        ._groupBox(padding: 10)
    }
    
    
    /// `Components`
    
    var Header: some View {
        HStack {
            Text("Source Configuration")._panelHeaderText()
        }
        .frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
    }

    // TODO: FIX THIS
//    var SourceConfig: some View {
//        if let source = global.sources.first(where: { $0.id == global.selectedSourceId }) {
//            switch source.type {
//            case .screenCapture:
//                AnyView(ScreenCaptureConfiguration(model: source as! ScreenCaptureSourceModel))
//            case .windowCapture:
//                AnyView(WindowCaptureConfiguration(model: source as! WindowCaptureSourceModel))
//            case .video:
//                AnyView(VideoConfiguration(model: source as! VideoSourceModel))
//            case .image:
//                AnyView(ImageConfiguration(model: source as! ImageSourceModel))
//            case .color:
//                AnyView(ColorConfiguration(model: source as! ColorSourceModel))
//            case .text:
//                AnyView(TextConfiguration(model: source as! TextSourceModel))
//            }
//        } else {
//            AnyView(Text("No source selected"))
//        }
//    }
}






struct PanelFooter: View {
    
    var onAdd: () -> Void?
    var onDelete: () -> Void?
    
    init(onAdd: @escaping () -> Void, onDelete: @escaping () -> Void) {
        self.onAdd = onAdd
        self.onDelete = onDelete
    }
    
    var body: some View {
        HStack(spacing: 0) {
            
            addButton
           
            Spacer().frame(maxWidth: 1, maxHeight: .infinity).background(Color(nsColor: .quaternaryLabelColor)).padding(.vertical, 8)
            
            deleteButton
        
            Spacer()
            
//            Menu("Options") {
//            }
//            .fixedSize()
        }
        .frame(maxWidth: .infinity, maxHeight: 32, alignment: .leading)
        .background(WindowBackgroundShapeStyle.windowBackground.opacity(0.5))
    }
    
    
    
    var addButton: some View {
        
        ZStack {
            Image(systemName: "plus")
            .font(.system(size: 12))
        }
        .frame(maxWidth: 26, maxHeight: .infinity)
        ._panelButton {
            onAdd()
        }
        .padding(4)
    }
    
    
    var deleteButton: some View {
        ZStack {
            Image(systemName: "minus")
            .font(.system(size: 12))
        }
        .frame(maxWidth: 26, maxHeight: .infinity)
        ._panelButton {
           onDelete()
        }
        .padding(4)
    }
    
}
