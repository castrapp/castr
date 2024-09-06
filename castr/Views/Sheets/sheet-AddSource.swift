//
//  sheet-AddSource.swift
//  castr
//
//  Created by Harrison Hall on 8/25/24.
//

import Foundation
import SwiftUI
import ScreenCaptureKit

struct AddSourceSheet: View {
    
    @ObservedObject var content = ContentModel.shared
    @ObservedObject var global = GlobalState.shared
    
    @State var showScreenRecordingWarning = false
    @State var screenRecordingEnabled = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            HeaderArea
  
            TabView(selection: $content.selectedAddSourceOption) {
    
                NewSource
          
                // TODO: Implement "Choose Existing"
//                ExistingSource
                
            }
            .padding(.horizontal, 60)
            .fixedSize(horizontal: false, vertical: true)
            
            if showScreenRecordingWarning {
                HStack(spacing: 2) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 10))
                        .symbolRenderingMode(.multicolor)
                    Text("Screen Recording Permission not enabled. Please check settings.")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 10)
            }
           

            Spacer()
            
            Divider()
            
            CancelConfirmButtons
            
        }
        .frame(minWidth: 500, maxWidth: 500, minHeight: 550, alignment: .top)
        .onAppear {
            print("checking for screen recording")
            requestScreenRecording()
        }
    }
    
    
    
    
    /// `Components`
    
    var HeaderArea: some View {
        VStack(spacing: 0) {
            Image(systemName: content.newSourceSelection?.imageName ?? "questionmark.circle.fill")
                .font(.system(size: 50))
                .padding(.top, 60)
                .padding(.bottom, 6)
            
            Text("Add a new source")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 6)
            
            Text(content.newSourceSelection?.name ?? "")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .padding(.bottom, 40)
        }
    }

    var NewSource: some View {
        VStack(alignment: .leading) {
            Text("Name").foregroundStyle(.secondary)
            TextField(
                "Name",
                text: $content.newSourceName
            )
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .disabled(!screenRecordingEnabled)
            .onSubmit { onConfirm() }
        }
        .padding(10)
        .tabItem { Text(AddSourceOption.newSource.displayName) }
        .tag(AddSourceOption.newSource)
    }
    
    
    // TODO: Implement "Choose Existing"
//    var ExistingSource: some View {
//        VStack(alignment: .leading) {
//            Text("Existing Sources").foregroundStyle(.secondary)
//            
//            ScrollView {
//
//            }
//            .frame(maxWidth:.infinity, maxHeight: 150)
//            ._groupBox()
//        }
//        .padding(10)
//        .tabItem { Text(AddSourceOption.existingSource.displayName) }
//        .tag(AddSourceOption.existingSource)
//    }
    
    
    var CancelConfirmButtons: some View {
        HStack {
            Button("Cancel", action:  onCancel)
            .buttonStyle(.borderless)
            .controlSize(.large)
            
            Spacer()
            
            Button("Confirm", action: onConfirm)
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!screenRecordingEnabled)
        }
        .frame(maxWidth: .infinity)
        .padding(22)
    }
    
    
    
    
    /// `Functions`

    func onConfirm() {
        
        // For a New Source
        if(content.selectedAddSourceOption == .newSource) {
            guard let newSourceSelection = content.newSourceSelection else { return }
            let newName = content.newSourceName.isEmpty ? newSourceSelection.name : content.newSourceName
            global.addSource(sourceType: newSourceSelection, name: newName)
        }
        
        // TODO: Implement "Choose Existing"
        // For an existing Source
//        else if(content.selectedAddSourceOption == .existingSource) {
//            
//        }
        
//        print("confirming")
        // Close the sheet and reset
        content.showAddSourceSheet = false
        content.newSourceSelection = nil
    }
    
    func onCancel() {
        print("canceling")
        content.showAddSourceSheet = false
    }
    
    private func requestScreenRecording() {
        Task {
            do {
                // If the app doesn't have screen recording permission, this call generates an exception.
                try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
                screenRecordingEnabled = true
                print("screen recoridng works boss")
            } catch {
                screenRecordingEnabled = false
                withAnimation(.easeInOut(duration: 0.25)) {
                    showScreenRecordingWarning = true
                }
                
               
            }
        }
    }
}
