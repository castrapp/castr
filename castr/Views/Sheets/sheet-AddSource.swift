//
//  sheet-AddSource.swift
//  castr
//
//  Created by Harrison Hall on 8/25/24.
//

import Foundation
import SwiftUI


struct AddSourceSheet: View {
    
    @ObservedObject var content = ContentModel.shared
    @ObservedObject var global = GlobalState.shared
    
    
    var body: some View {
        VStack(spacing: 0) {
            
            HeaderArea
  
            TabView(selection: $content.selectedAddSourceOption) {
    
                NewSource
          
                ExistingSource
                
            }
            .padding(.horizontal, 60)
            .fixedSize(horizontal: false, vertical: true)

            Spacer()
            
            Divider()
            
            CancelConfirmButtons
            
        }
        .frame(minWidth: 500, maxWidth: 500, minHeight: 550, alignment: .top)
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
            .disabled(true)
        }
        .padding(10)
        .tabItem { Text(AddSourceOption.newSource.displayName) }
        .tag(AddSourceOption.newSource)
    }
    
    
    var ExistingSource: some View {
        VStack(alignment: .leading) {
            Text("Existing Sources").foregroundStyle(.secondary)
            
            ScrollView {

            }
            .frame(maxWidth:.infinity, maxHeight: 150)
            ._groupBox()
        }
        .padding(10)
        .tabItem { Text(AddSourceOption.existingSource.displayName) }
        .tag(AddSourceOption.existingSource)
    }
    
    
    var CancelConfirmButtons: some View {
        HStack {
            Button("Cancel", action:  onCancel)
            .buttonStyle(.borderless)
            .controlSize(.large)
            
            Spacer()
            
            Button("Confirm", action: onConfirm)
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .frame(maxWidth: .infinity)
        .padding(22)
    }
    
    
    
    
    /// `Functions`

    func onConfirm() {
        
        // For a New Source
        if(content.selectedAddSourceOption == .newSource) {
            guard let newSourceSelection = content.newSourceSelection else { return }
            global.addSource(sourceType: newSourceSelection, name: newSourceSelection.name)
        }
        
        // For an existing Source
        else if(content.selectedAddSourceOption == .existingSource) {
            
        }
        
//        print("confirming")
        // Close the sheet and reset
        content.showAddSourceSheet = false
        content.newSourceSelection = nil
    }
    
    func onCancel() {
        print("canceling")
        content.showAddSourceSheet = false
    }
}
