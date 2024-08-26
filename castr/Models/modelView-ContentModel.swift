
import Foundation


class ContentModel: ObservableObject {
    
    static let shared = ContentModel()
    
    private init() {}
    
    @Published var showAddSourceSheet = false
    @Published var showInitialPermissionsSheet = false
    @Published var selectedAddSourceOption: AddSourceOption = .newSource
    @Published var newSourceName = ""
    
    @Published var newSourceSelection: SourceType?
    let addSourceOptions = ["Add New", "Choose Existing"]
    
    
    @Published var isVirtualCameraEnabled = false
    @Published var isRecordingEnabled = false
}




