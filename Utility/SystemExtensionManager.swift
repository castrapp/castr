import Foundation
import SystemExtensions
import ExtensionFoundation

class SystemExtensionManager: NSObject, OSSystemExtensionRequestDelegate {
    
    static let shared = SystemExtensionManager()
    
    private override init() {}
    
    private var currentCompletion: ((Bool, Error?) -> Void)?
    private var checkInstallCompletion: ((Bool) -> Void)?
    
    func installExtension(extensionIdentifier: String, completion: @escaping (Bool, Error?) -> Void) {
        print("Attempting to install")
        print("System extension identifier: ", extensionIdentifier)
        let activationRequest = OSSystemExtensionRequest.activationRequest(forExtensionWithIdentifier: extensionIdentifier, queue: .main)
        activationRequest.delegate = self
        self.currentCompletion = completion
        
        OSSystemExtensionManager.shared.submitRequest(activationRequest)
    }
    
    func uninstallExtension(extensionIdentifier: String, completion: @escaping (Bool, Error?) -> Void) {
        print("Attempting to uninstall")
        print("System extension identifier: ", extensionIdentifier)
        let deactivationRequest = OSSystemExtensionRequest.deactivationRequest(forExtensionWithIdentifier: extensionIdentifier, queue: .main)
        deactivationRequest.delegate = self
        
        self.currentCompletion = completion
        
        OSSystemExtensionManager.shared.submitRequest(deactivationRequest)
    }
    
    
 
    
    // MARK: - OSSystemExtensionRequestDelegate
    
    func request(_ request: OSSystemExtensionRequest, didFinishWithResult result: OSSystemExtensionRequest.Result) {
        print("Request finished with result: \(result)")
        currentCompletion?(true, nil)
        currentCompletion = nil
    }
    
    func request(_ request: OSSystemExtensionRequest, didFailWithError error: Error) {
        print("Request failed with error: \(error)")
        currentCompletion?(false, error)
        currentCompletion = nil
    }
    
    func requestNeedsUserApproval(_ request: OSSystemExtensionRequest) {
        print("Request needs user approval")
        // You might want to inform the user that their approval is required here
    }
    
    func request(_ request: OSSystemExtensionRequest, didCancelWithError error: Error) {
        print("Request was cancelled with error: \(error)")
        currentCompletion?(false, error)
        currentCompletion = nil
    }
    
    func request(_ request: OSSystemExtensionRequest, actionForReplacingExtension existing: OSSystemExtensionProperties, withExtension ext: OSSystemExtensionProperties) -> OSSystemExtensionRequest.ReplacementAction {
        // Decide what to do when replacing an existing extension with a new one
        // For now, simply replace the existing extension
        return .replace
    }
}
