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
            InitialPermissionsSheet()
        }
        .onAppear {
            // Pre-check for initial permisisons
            let userDefaults = UserDefaults.standard

            // Check if the key "gotInitialPermissions" exists and its value
            if userDefaults.object(forKey: "gotInitialPermissions") == nil || !userDefaults.bool(forKey: "gotInitialPermissions") {
                //  If the key doesn't exist or is set to false, we assume this is the first time the user is opening the application
                content.showInitialPermissionsSheet = true
            } else {
                // The key exists and is set to true
                print("gotInitialPermissions is true.")
            }
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
            
        /// `Test Controls` (eventually get rid of these)
//            Button("Start extension") {
//                CameraViewModel.shared.start()
//                GlobalState.shared.streamToVirtualCamera = true
//            }
//            Button("Reinstall extension") {
//                SystemExtensionManager.shared.installExtension(extensionIdentifier: "harrisonhall.castr.virtualcamera") { success, error in
//                    if success {
//                        print("Castr Virtual Camera installed successfully")
//                    } else {
//                        if let error = error {
//                            print("Failed to install Castr Virtual Camera: \(error.localizedDescription)")
//                        } else {
//                            print("Failed to install Castr Virtual Camera")
//                        }
//                    }
//                }
//            }
//            Button("Set Just Property") {
//                CameraViewModel.shared.setJustProperty2()
//            }
//            Button("Print scenes sources") {
//                guard let currentScene = GlobalState.shared.getSelectedScene() else { return }
//                print("sources are: ", currentScene.sources)
//            }
//            Button("Print sublayers") {
//                print("sublayers are: ", previewer.contentLayer.sublayers)
//            }
//            Button("flip horizontally") {
//                guard let selectedSource = LayoutState.shared.selectedSourceLayer else { return }
//                selectedSource.setAffineTransform(CGAffineTransform(scaleX: -1.0, y: 1.0))
////                Main.shared.onSelectlayer.setAffineTransform(CGAffineTransform(scaleX: -1.0, y: 1.0))
//                Main.shared.onSelectlayer.setAffineTransform(CGAffineTransform(scaleX: -1.0, y: 1.0))
//            }
            
            
            Controls()
                .padding(10)
            SourceConfiguration()
        }
        .frame(minWidth: 300, maxWidth: 300, maxHeight: .infinity)
        .background(MaterialView(material: .sidebar))
        
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
            
            // TODO: Move this to the AddRemoveButtons and create "Options" menu dropdown
//            ControlGroup {
//                Menu {
//                        Button("Option 1", action: { print("Option 1 selected") })
//                        Button("Option 2", action: { print("Option 2 selected") })
//                        Button("Option 3", action: { print("Option 3 selected") })
//                    } label: {
//                    }
//            }
//            
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
                        
                        // TODO: Add in number of sources here
//                        Text("0 Sources")
//                        .font(.system(size: 12))
//                        .foregroundColor(.secondary)
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
                if global.scenes.count < 1 {
                    print("Adding Scene")
                    GlobalState.shared.addScene()

                }
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
    
//    @available(macOS 14.0, *)
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
//            .background(WindowBackgroundShapeStyle.windowBackground.opacity(0.5))
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
            if(!global.selectedSceneId.isEmpty && global.sources.count < 1) {
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
            .padding(10)
            
            // TODO: Eventually add in more sources
//            Button("Color Source"){
//                print("adding color source")
//                content.showAddSourceSheet = true
//                content.newSourceSelection = .color
//                showPopover = false
//            }
//            
//            Button("Image Source"){
//                print("adding image source")
//                content.showAddSourceSheet = true
//                content.newSourceSelection = .image
//                showPopover = false
//            }
            
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
    @State private var isHovered: Bool = false
    @State var isStarting: Bool = false
    @State var isStreaming: Bool = false
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            HStack {
                Text("Controls")._panelHeaderText()
            }
            .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .leading)
            
            Divider()._panelDivider()
               
            VirtualCameraControl()
            
            // TODO: Implement recording functionality
//            RecordingControl()
            
            Spacer().panelSubSeparatorStyle()
            
        }
//        ._groupBox(padding: 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
//        .background(Color(nsColor: .quaternarySystemFill))
//        .padding(10)
        
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(nsColor: .tertiaryLabelColor), lineWidth: 1)
        )
//        .padding(10)
        .fixedSize(horizontal: false, vertical: true)
    }

}



struct VirtualCameraControl: View {
    @State private var isHovered: Bool = false
    @State var isStarting: Bool = false
    @State var isStreaming: Bool = false
    @State var isVirtualCameraInstalled: Bool = false
    @ObservedObject var global = GlobalState.shared
    @State private var timer: Timer? = nil
    @State private var elapsedTime: TimeInterval = 0
    
    
    var body: some View {
        Button(action: onPress) {
            HStack {
                Image(systemName: isStreaming ? "video.circle.fill" : "video.slash.circle.fill")
                    .font(.system(size: 28))
                    .padding(.leading, 6)
                    .symbolRenderingMode(isStreaming ? .palette : .monochrome)
                    .foregroundStyle(isStreaming ? Color.white : Color.primary, isStreaming ? Color.blue : Color.primary)
                    .animation(.easeInOut(duration: 0.3), value: isStreaming)



                
                VStack(alignment: .leading) {
                    Text("Virtual Camera")
                        .fontWeight(.bold)
                        .font(.system(size: 12))
                        .foregroundColor(.primary)
                    if isHovered && !isStarting && !isStreaming && isVirtualCameraInstalled {
                        Text("Start")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    else if isHovered && !isStarting && !isStreaming && !isVirtualCameraInstalled{
                        HStack(spacing: 2) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 10))
                                .symbolRenderingMode(.multicolor)
                            Text("Virtual Camera not detected")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                    else if isStreaming && !isHovered {
                        Text("Streaming: \(formatTime(elapsedTime))")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
//                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    else if isStreaming && isHovered {
                        Text("Stop: \(formatTime(elapsedTime))")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
//                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                Spacer()
                if isHovered && !isStarting && !isStreaming  {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(Color(NSColor.secondaryLabelColor))
                        .padding(.trailing, 10)
                        .transition(.move(edge: .leading).combined(with: .opacity))
                }
            }
            .frame(maxWidth: .infinity, minHeight: 42, maxHeight: 42, alignment: .leading)
//            .overlay(
//                RoundedRectangle(cornerRadius: 6)
//                    .fill(Color(isHovered ? NSColor.quaternaryLabelColor : (isStarting ? NSColor.quaternaryLabelColor : NSColor.windowBackgroundColor))) // Use windowBackgroundColor as a fallback for quaternarySystemFill
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 6)
//                            .stroke(Color(isHovered ? NSColor.tertiaryLabelColor : NSColor.secondaryLabelColor), lineWidth: 1) // Apply border with curved corners
//                    )
//            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color( isHovered ? NSColor.quaternaryLabelColor : (isStarting ? NSColor.quaternaryLabelColor : NSColor.quinaryLabel)))
                    .overlay (
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color( isHovered ? NSColor.tertiaryLabelColor : NSColor.quinaryLabel), lineWidth: 1)
                    )
//                    .stroke(Color( isHovered ? NSColor.tertiaryLabelColor : NSColor.quinaryLabel), lineWidth: 1) // Apply border with curved corners
            )
            .onHover { hovering in
                
                isVirtualCameraInstalled = checkForCastrVirtualCamera()
                
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovered = hovering
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(10)
        
    }
    
    func onPress() {
        if !isVirtualCameraInstalled { return }
        print("button being pressed")
        if isStreaming {
            isStreaming = false
            OutputService.shared.isStreamingToVirtualCamera = false
            stopTimer()
        }
        else {
            isStreaming = true
            CameraViewModel.shared.start()
            OutputService.shared.isStreamingToVirtualCamera = true
            startTimer()
        }
    }
    
    
    func startTimer() {
       elapsedTime = 0
       timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
           elapsedTime += 1
       }
   }
       
   func stopTimer() {
       timer?.invalidate()
       timer = nil
   }
   
   func formatTime(_ interval: TimeInterval) -> String {
       let hours = Int(interval) / 3600
       let minutes = (Int(interval) % 3600) / 60
       let seconds = Int(interval) % 60
       return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
   }
}



struct RecordingControl: View {
    @State private var isHovered: Bool = false
    @State var isStarting: Bool = false
    @State var isStreaming: Bool = false
    @ObservedObject var global = GlobalState.shared
    @State private var timer: Timer? = nil
    @State private var elapsedTime: TimeInterval = 0
    
    
    var body: some View {
        Button(action: onPress) {
            HStack {
                Image(systemName: "record.circle.fill")
                    .font(.system(size: 28))
                    .padding(.leading, 6)
                    .symbolRenderingMode(isStreaming ? .palette : .monochrome)
                    .foregroundStyle(isStreaming ? Color.red : Color.primary, Color.primary)
                    .animation(.easeInOut(duration: 0.3), value: isStreaming)



                
                VStack(alignment: .leading) {
                    Text("Recording")
                        .fontWeight(.bold)
                        .font(.system(size: 12))
                        .foregroundColor(.primary)
                    if isHovered && !isStarting && !isStreaming {
                        Text("Start")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    else if isStarting && !isStreaming{
                        Text("Starting")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    else if isStreaming && !isHovered {
                        Text("Recording: \(formatTime(elapsedTime))")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
//                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    else if isStreaming && isHovered {
                        Text("Stop: \(formatTime(elapsedTime))")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
//                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                Spacer()
                if isHovered && !isStarting && !isStreaming  {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(Color(NSColor.secondaryLabelColor))
                        .padding(.trailing, 10)
                        .transition(.move(edge: .leading).combined(with: .opacity))
                }
                else if isStarting && !isStreaming {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(0.55)
                        .padding(.trailing, 6)
                        .transition(.move(edge: .leading).combined(with: .opacity))
                }
                
            }
            .frame(maxWidth: .infinity, minHeight: 42, maxHeight: 42, alignment: .leading)
            
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovered = hovering
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
//        .onChange(of: global.streamToVirtualCamera) { newValue in
//            if newValue {
//                isStarting = false
//                isStreaming = true
//                OutputService.shared.isStreamingToVirtualCamera = true
//            }
//
//            print("global.streamToVirtualCamera is now: ", newValue)
//        }
    }
    
    func onPress() {
        print("button being pressed")
        if isStreaming {
            isStreaming = false
            OutputService.shared.isRecording = false
            stopTimer()
        }
        else {
//            isStarting = false
            isStreaming = true
            OutputService.shared.isRecording = true
            startTimer()
        }
    }
    
    
    func startTimer() {
       elapsedTime = 0
       timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
           elapsedTime += 1
       }
   }
       
   func stopTimer() {
       timer?.invalidate()
       timer = nil
   }
   
   func formatTime(_ interval: TimeInterval) -> String {
       let hours = Int(interval) / 3600
       let minutes = (Int(interval) % 3600) / 60
       let seconds = Int(interval) % 60
       return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
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
            } else {
                VStack(spacing: 4) {
                    Text("Select a source to configure it.")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .border(Color.red)
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
//        .background(WindowBackgroundShapeStyle.windowBackground.opacity(0.5))
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
