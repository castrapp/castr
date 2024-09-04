//
//  view-ScreenCapture.swift
//  castr
//
//  Created by Harrison Hall on 8/4/24.
//

import Foundation
import SwiftUI
import ScreenCaptureKit
import Combine


struct ScreenCaptureConfiguration: View {
    @ObservedObject var model: ScreenCaptureSourceModel
    @FocusState var isTextFieldFocused: Bool
    
    @State var availableDisplays = [SCDisplay]()
    @State var availableApps = [SCRunningApplication]() {
        didSet {
            print("available apps have changed", availableApps)
        }
    }
    @State var availableWindows = [SCWindow]()
    @State var selectedDisplay: SCDisplay?
    @State var selectedApp: String = ""
    @State var contentRefreshTimer: AnyCancellable?
    
    var body: some View {
        ScrollView {
        VStack(spacing: 0) {
            HStack {
                Text("Active")
                
                Spacer()
                
                Toggle(isOn: $model.isActive) {}
                .labelsHidden() // Hides the label for the Toggle
                .fixedSize(horizontal: true, vertical: true)
            }
            .frame(maxWidth: .infinity, maxHeight: 30, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            
            Spacer().panelSubSeparatorStyle()
            
            HStack {
                Text("Name")
                
                Spacer()
                
                TextField("Source Name", text: $model.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .fixedSize(horizontal: true, vertical: true)
                    .disabled(true)
                    .focused($isTextFieldFocused)
                    .onAppear {
                        DispatchQueue.main.async {
                            isTextFieldFocused = false
                        }
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: 30, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            
            Spacer().panelSubSeparatorStyle()
            
            HStack {
                Text("Display")
                
                Spacer()
                
                Picker("Display", selection: $selectedDisplay) {
                    ForEach(availableDisplays, id: \.self) { display in
                        Text(display.displayName)
                            .tag(SCDisplay?.some(display))
                    }
                }
                .labelsHidden()
                .fixedSize(horizontal: true, vertical: true)
                .onChange(of: selectedDisplay) { newValue in
                    print("selected display has changed: ", selectedDisplay)
                    guard let newValue = newValue else { return }
                    if newValue.displayName != model.selectedDisplay {
                        model.selectedDisplay = newValue.displayName
                        model.screenRecorder?.selectedDisplay = newValue
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 30, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            
            Spacer().panelSubSeparatorStyle()
            
            VStack(alignment: .leading, spacing: 0) {
                Text("Pick and choose which applications and windows you would like to display.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 10)
                    .padding(.horizontal, 10)
                
                Text("Apps")
                    .padding(.bottom, 8)
                    .padding(.horizontal, 10)
//                
//                                ScrollView {
//                                    VStack(spacing: 0) {
//                                        ForEach(availableApps, id: \.self) { app in
//                                            Text(app.applicationName)
//                                        }
//                                    }
//                                }
                //                .frame(maxWidth: .infinity, maxHeight: .infinity)
                VStack {
//                        List(selection: $selectedApp) {
                            ForEach(availableApps, id: \.bundleIdentifier) { app in
                                
                                HStack {
                                    Button(action: {onAppIconPress(bundleId: app.bundleIdentifier)}) {
                                        Image(systemName:
                                                model.excludedApps.contains(app.bundleIdentifier)
                                              ? "rectangle.on.rectangle.slash.circle.fill"
                                              : "rectangle.on.rectangle.circle.fill"
                                        )
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .symbolRenderingMode(
                                            model.excludedApps.contains(app.bundleIdentifier)
                                            ? .hierarchical
                                            : .palette
                                        )
                                        .foregroundStyle(Color.primary, Color.accentColor)
                                        //                                    .symbolEffect(.bounce, value: model.excludedApps.contains(app.bundleIdentifier))
                                        .frame(minWidth: 30, maxWidth: 30, minHeight: 30, maxHeight: 30)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .fixedSize()
                                    //                            .border(Color.red)
                                    
                                    VStack(alignment: .leading) {
                                        Text(app.applicationName)
                                        //                                Text(source.type.name)
                                        //                                .font(.system(size: 12))
                                        //                                .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if let appIcon = getAppIcon(bundleId: app.bundleIdentifier) {
                                        Image(nsImage: appIcon)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 30, height: 30)
                                    } else {
                                        Image(systemName: "app.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 30, height: 30)
                                    }
                                }
                                .frame(height: 32)
                                
                            }
//                        }
//                        .listStyle(SidebarListStyle()) // Sidebar style for macOS
//                        .frame(minWidth: 100)
//                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(minWidth: 100)
//                    .border(Color.blue)
                    .padding(.horizontal, 10)
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
        .onAppear {
            Task { @MainActor in
                await refreshAvailableContent()
                if let display = availableDisplays.first { $0.displayName == model.selectedDisplay } {
                    selectedDisplay = display
                } else {
                    selectedDisplay = availableDisplays.first
                }
                await monitorAvailableContent()
            }
          
        }
        .onDisappear {
            contentRefreshTimer?.cancel()
            print("Stopped monitoring and deallocated resources")
        }
    }
    
    func onAppIconPress(bundleId: String) {
        print("app toggled is: ", bundleId)
        let result = model.excludedApps.contains(bundleId)
        print("result is: ", result)
        
        if result {
            model.excludedApps.remove(bundleId)
        } else {
            model.excludedApps.insert(bundleId)
        }
        let excludedApps = getExlcudedApps()
        Task { @MainActor in
            model.screenRecorder?.excludedApplications = excludedApps
        }
        
        
    }
    
    func getAppIcon(bundleId: String) -> NSImage? {
        guard let path = NSWorkspace.shared.absolutePathForApplication(withBundleIdentifier: bundleId) else {
            return nil
        }
        return NSWorkspace.shared.icon(forFile: path)
    }
    
    @MainActor
    func monitorAvailableContent() async {
        print("Starting to monitor available content")
        await self.refreshAvailableContent()
        contentRefreshTimer = Timer.publish(every: 2, on: .main, in: .common).autoconnect().sink { _ in
            Task {
                await self.refreshAvailableContent()
            }
        }
    }
    
    @MainActor
    func refreshAvailableContent() async {
        do {
            // Retrieve the available screen content to capture.
            let availableContent = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
        
            availableDisplays = availableContent.displays
            availableWindows = filterWindows(availableContent.windows)
            availableApps = filterApplications(availableContent.applications)

            
            if selectedDisplay == nil {
                selectedDisplay = availableDisplays.first
            }
        } catch {
            fatalError("Cannot Refresh available content")
        }
    }
    
    func filterWindows(_ windows: [SCWindow]) -> [SCWindow] {
        // Sort the windows by app name.
        windows.sorted { $0.owningApplication?.applicationName ?? "" < $1.owningApplication?.applicationName ?? "" }
    }
    
    func filterApplications(_ applications: [SCRunningApplication]) -> [SCRunningApplication] {
        applications
            .filter { $0.applicationName.isEmpty == false }
            .sorted { $0.applicationName.lowercased() < $1.applicationName.lowercased() }
    }
    
    
     func getExlcudedApps() ->  [SCRunningApplication] {
         var excludedApps: [SCRunningApplication] = [SCRunningApplication]()
         guard let display = selectedDisplay else { fatalError("No display selected.") }
        
        // Initialize appsToExclude
        var appsToExclude: [SCRunningApplication] = []

        // Iterate through each bundle ID in model.excludedApps
        for bundleID in model.excludedApps {
            // Find the matching app in availableApps
            if let matchingApp = availableApps.first(where: { $0.bundleIdentifier == bundleID }) {
                excludedApps.append(matchingApp)
            }
        }

        print("Apps to exclude are: ", appsToExclude)
        
        return excludedApps
    }



}
