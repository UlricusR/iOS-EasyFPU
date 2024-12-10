//
//  MenuView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 06.08.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers

struct MenuView: View {
    enum SettingsNavigationPath: Hashable {
        case EditTherapySettings
        case EditAppSettings
    }
    
    enum SheetState: Identifiable {
        case pickFileToImport
        case pickExportDirectory
        case about
        
        var id: SheetState { self }
    }
    
    @Environment(\.managedObjectContext) var managedObjectContext
    var absorptionScheme: AbsorptionSchemeViewModel
    @State private var navigationPath = NavigationPath()
    @State private var isConfirming = false
    @State private var importData: ImportData?
    @State private var activeSheet: SheetState?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            Form {
                Section(header: Text("Settings")) {
                    // Therapy Settings
                    Button("Therapy Settings") {
                        navigationPath.append(SettingsNavigationPath.EditTherapySettings)
                    }
                    .accessibilityIdentifierLeaf("TherapySettingsButton")
                    
                    // App Settings
                    Button("App Settings") {
                        navigationPath.append(SettingsNavigationPath.EditAppSettings)
                    }
                    .accessibilityIdentifierLeaf("AppSettingsButton")
                }
                
                Section(header: Text("Import/Export")) {
                    // Import
                    Button("Import from JSON") {
                        activeSheet = .pickFileToImport
                    }
                    .confirmationDialog(
                        "Import food list",
                        isPresented: $isConfirming,
                        titleVisibility: .visible
                    ) {
                        Button("Replace") {
                            self.importFoodItems(replaceExisting: true)
                        }
                        Button("Append") {
                            self.importFoodItems(replaceExisting: false)
                        }
                        Button("Cancel", role: .cancel) {
                            isConfirming.toggle()
                        }
                    } message: {
                        Text("Please select")
                    }
                    .accessibilityIdentifierLeaf("ImportFromJSONButton")
                    
                    // Export
                    Button("Export to JSON") {
                        activeSheet = .pickExportDirectory
                    }
                    .accessibilityIdentifierLeaf("ExportToJSONButton")
                }
                
                Section(header: Text("Info")) {
                    // About
                    Button("About") {
                        activeSheet = .about
                    }
                    .accessibilityIdentifierLeaf("AboutButton")
                    
                    // Disclaimer
                    Button("Disclaimer") {
                        if !UserSettings.set(UserSettings.UserDefaultsType.bool(false, UserSettings.UserDefaultsBoolKey.disclaimerAccepted), errorMessage: &alertMessage) {
                            self.showingAlert = true
                        }
                        
                        // Display disclaimer
                        UserSettings.shared.disclaimerAccepted = false
                    }
                    .accessibilityIdentifierLeaf("DisclaimerButton")
                    
                    // Web help
                    Button("Help on the Web") {
                        UIApplication.shared.open(URL(string: NSLocalizedString("Home-Link", comment: ""))!)
                    }
                    .accessibilityIdentifierLeaf("HelpOnWebButton")
                }
            }
            .navigationTitle("Settings")
            .navigationDestination(for: SettingsNavigationPath.self) { screen in
                switch screen {
                case .EditTherapySettings:
                    TherapySettingsEditor(
                        navigationPath: $navigationPath,
                        absorptionScheme: self.absorptionScheme
                    )
                    .accessibilityIdentifierBranch("TherapySettingsEditor")
                case .EditAppSettings:
                    AppSettingsEditor(
                        navigationPath: $navigationPath
                    )
                    .accessibilityIdentifierBranch("AppSettingsEditor")
                }
            }
        }
        .sheet(item: $activeSheet) {
            sheetContent($0)
        }
        .alert("Notice", isPresented: self.$showingAlert, actions: {}, message: { Text(self.alertMessage) })
    }
    
    @ViewBuilder
    private func sheetContent(_ state: SheetState) -> some View {
        switch state {
        case .pickFileToImport:
            FilePickerView(callback: self.importJSON, documentTypes: [UTType.json])
                .accessibilityIdentifierBranch("FilePickerForImport")
        case .pickExportDirectory:
            FilePickerView(callback: self.exportJSON, documentTypes: [UTType.folder])
                .accessibilityIdentifierBranch("FilePickerForExport")
        case .about:
            AboutView()
                .accessibilityIdentifierBranch("About")
        }
    }
    
    private func importJSON(_ url: URL) {
        if let importData = DataHelper.importFoodItems(url, errorMessage: &alertMessage) {
            self.importData = importData
            
            if DataHelper.hasData() {
                // There are already data, so ask user what to do with it
                self.isConfirming = true
            } else {
                // Import the data
                importFoodItems(replaceExisting: false)
            }
        } else {
            // Some error happened
            showingAlert = true
        }
    }
    
    private func exportJSON(_ url: URL) {
        // Make sure we can access file
        guard url.startAccessingSecurityScopedResource() else {
            debugPrint("Failed to access \(url)")
            alertMessage = NSLocalizedString("Failed to access ", comment: "") + url.absoluteString
            showingAlert = true
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        // Write file
        var fileName = ""
        if DataHelper.exportFoodItems(url, fileName: &fileName) {
            alertMessage = NSLocalizedString("Successfully exported food list to: ", comment: "") + fileName
            showingAlert = true
        } else {
            alertMessage = NSLocalizedString("Failed to export food list to: ", comment: "") + fileName
            showingAlert = true
        }
    }
    
    private func importFoodItems(replaceExisting: Bool) {
        if let importData {
            if replaceExisting {
                DataHelper.deleteAllFood()
            }
        
            for foodItemVMToBeImported in importData.foodItemVMsToBeImported {
                foodItemVMToBeImported.save()
            }
            
            if importData.composedFoodItemVMsToBeImported != nil {
                for composedFoodItemVMToBeImported in importData.composedFoodItemVMsToBeImported! {
                    _ = composedFoodItemVMToBeImported.save()
                }
            }
         
            alertMessage = NSLocalizedString("Successfully imported food list", comment: "")
            showingAlert = true
        } else {
            // This should never happen
            alertMessage = NSLocalizedString("Failed to import food list", comment: "")
            showingAlert = true
        }
    }
}
