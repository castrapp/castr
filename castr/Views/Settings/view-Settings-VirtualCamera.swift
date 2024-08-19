//
//  view-Settings-VirtualCamera.swift
//  castr
//
//  Created by Harrison Hall on 8/11/24.
//

import Foundation
import SwiftUI
import SystemExtensions

struct VirtualCameraSettings: View {
    
    var body: some View {
        
        VStack {
            Text("Virtual Camera Settings")
//            
//            CustomGroupBox {
//                HStack {
//                    Text("Installed")
//                    Spacer()
//                    Text("Yes")
//                }
//                .frame(maxWidth: .infinity)
////                .frame(height: 40)
////                .border(Color.red, width: 1)
//                .padding(10)
//
//                Spacer().panelSubSeparatorStyle()
//                
//                HStack {
//                    Button("Uninstall") {
//                        print("Uninstalling Virtual Camera")
//                    }
//                    Button("Install") {
//                        print("Installing Virtual Camera")
//                        SystemExtensionManager.shared.installExtension(extensionIdentifier: "harrisonhall.castr.virtualcamera") { success, error in
//                            if success {
//                                print("Extension installed successfully")
//                            } else {
//                                if let error = error {
//                                    print("Failed to install extension: \(error.localizedDescription)")
//                                } else {
//                                    print("Failed to install extension")
//                                }
//                            }
//                        }
//                    }
//                }
//                .frame(maxWidth: .infinity, alignment: .trailing)
//                .padding(10)
//          
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .padding(20)
//            .fixedSize(horizontal: false, vertical: true)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(20)
//        .border(Color.red, width: 1)
    }
}
