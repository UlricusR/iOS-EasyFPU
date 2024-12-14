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
        case about
        
        var id: SheetState { self }
    }
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject private var bannerService: BannerService
    var absorptionScheme: AbsorptionSchemeViewModel
    @State private var navigationPath = NavigationPath()
    @State private var importing = false
    @State private var exporting = false
    @State private var isConfirming = false
    @State private var importData: ImportData?
    @State private var exportData = ExportJSONDocument()
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
                        importing = true
                    }
                    .fileImporter(
                        isPresented: $importing,
                        allowedContentTypes: [UTType.json]
                    ) { result in
                        switch result {
                        case .success(let file):
                            importJSON(file)
                        case .failure(let error):
                            bannerService.setBanner(banner: .error(message: error.localizedDescription, isPersistent: true))
                        }
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
                        var errorMessage = ""
                        if let jsonDocument = ExportJSONDocument(errorMessage: &errorMessage) {
                            self.exportData = jsonDocument
                            exporting = true
                        } else {
                            bannerService.setBanner(banner: .error(message: errorMessage, isPersistent: true))
                        }
                    }
                    .fileExporter(
                        isPresented: $exporting,
                        document: exportData,
                        contentType: UTType.json,
                        defaultFilename: createFileName()
                    ) { result in
                        switch result {
                        case .success(let file):
                            bannerService.setBanner(banner: .success(message: NSLocalizedString("Successfully exported food list to: ", comment: "") + file.lastPathComponent, isPersistent: false))
                        case .failure(let error):
                            bannerService.setBanner(banner: .error(message: error.localizedDescription, isPersistent: true))
                        }
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
         
            bannerService.setBanner(banner: .success(message: NSLocalizedString("Successfully imported food list", comment: ""), isPersistent: false))
        } else {
            // This should never happen
            bannerService.setBanner(banner: .error(message: NSLocalizedString("Failed to import food list", comment: ""), isPersistent: true))
        }
    }
    
    private func createFileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = formatter.string(from: Date())
        return "EasyFPU-export_\(timestamp)"
    }
}
