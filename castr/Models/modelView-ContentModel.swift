
import Foundation


class ContentModel: ObservableObject {
    
    static let shared = ContentModel()
    
    private init() {}
    
    @Published var showAddSourceSheet = false
    @Published var showInitialPermissionsSheet = false
    @Published var selectedAddSourceOption: AddSourceOption = .newSource
    @Published var newSourceName = ""
    
    @Published var newSourceSelection: SourceType?
    // TODO: Implement "Choose Existing"
//    let addSourceOptions = ["Add New", "Choose Existing"]
    let addSourceOptions = ["Add New"]
    
    
    @Published var isVirtualCameraEnabled = false
    @Published var isRecordingEnabled = false
}




