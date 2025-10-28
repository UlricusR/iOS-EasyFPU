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
        case EditCategories
        case EditTherapySettings
        case EditAppSettings
        case About
    }
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @State private var navigationPath = NavigationPath()
    @State private var importing = false
    @State private var exporting = false
    @State private var isConfirming = false
    @State private var importData: ImportData?
    @State private var exportData = FoodDataDocument()
    @State private var showingAlert = false
    @State private var activeAlert: SimpleAlertType?
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            Form {
                Section(header: Text("Settings")) {
                    // Category Editor
                    Button("Categories") {
                        navigationPath.append(SettingsNavigationPath.EditCategories)
                    }
                    .accessibilityIdentifierLeaf("EditCategoriesButton")
                    
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
                            activeAlert = .error(message: error.localizedDescription)
                            showingAlert = true
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
                        let allFoodData = DataHelper.getAllFoodData()
                        let allFoodItems = allFoodData[0] as! [FoodItemPersistence]
                        let allComposedFoodItems = allFoodData[1] as! [ComposedFoodItemPersistence]
                        if let jsonDocument = FoodDataDocument(
                            foodItems: allFoodItems,
                            composedFoodItems: allComposedFoodItems,
                            errorMessage: &errorMessage
                        ) {
                            self.exportData = jsonDocument
                            exporting = true
                        } else {
                            activeAlert = .error(message: errorMessage)
                            showingAlert = true
                        }
                    }
                    .fileExporter(
                        isPresented: $exporting,
                        document: exportData,
                        contentType: .foodDataType,
                        defaultFilename: createFileName()
                    ) { result in
                        switch result {
                        case .success(let file):
                            activeAlert = .success(message: NSLocalizedString("Successfully exported food list to: ", comment: "") + file.lastPathComponent)
                            showingAlert = true
                        case .failure(let error):
                            activeAlert = .error(message: error.localizedDescription)
                            showingAlert = true
                        }
                    }
                    .accessibilityIdentifierLeaf("ExportToJSONButton")
                }
                
                Section(header: Text("Info")) {
                    // About
                    Button("About") {
                        navigationPath.append(SettingsNavigationPath.About)
                    }
                    .accessibilityIdentifierLeaf("AboutButton")
                    
                    // Disclaimer
                    Button("Disclaimer") {
                        var errorMessage = ""
                        if !UserSettings.set(UserSettings.UserDefaultsType.bool(false, UserSettings.UserDefaultsBoolKey.disclaimerAccepted), errorMessage: &errorMessage) {
                            activeAlert = .fatalError(message: errorMessage)
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
                case .EditCategories:
                    CategoryEditor()
                    .environment(\.managedObjectContext, managedObjectContext)
                    .accessibilityIdentifierBranch("CategoryEditor")
                case .EditTherapySettings:
                    TherapySettingsEditor()
                    .accessibilityIdentifierBranch("TherapySettingsEditor")
                case .EditAppSettings:
                    AppSettingsEditor()
                    .accessibilityIdentifierBranch("AppSettingsEditor")
                case .About:
                    AboutView()
                        .accessibilityIdentifierBranch("About")
                }
            }
        }
        .alert(
            activeAlert?.title() ?? "Notice",
            isPresented: $showingAlert,
            presenting: activeAlert
        ) { activeAlert in
            activeAlert.button()
        } message: { activeAlert in
            activeAlert.message()
        }
    }
    
    private func importJSON(_ url: URL) {
        var alertMessage = ""
        if let importData = DataHelper.importFoodData(url, errorMessage: &alertMessage) {
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
            activeAlert = .error(message: alertMessage)
            showingAlert = true
        }
    }
    
    private func importFoodItems(replaceExisting: Bool) {
        if let importData {
            if replaceExisting {
                DataHelper.deleteAllFood()
            }
        
            if importData.foodItemVMsToBeImported != nil {
                for foodItemVMToBeImported in importData.foodItemVMsToBeImported! {
                    foodItemVMToBeImported.save()
                }
            }
            
            if importData.composedFoodItemVMsToBeImported != nil {
                for composedFoodItemVMToBeImported in importData.composedFoodItemVMsToBeImported! {
                    _ = composedFoodItemVMToBeImported.save()
                }
            }

            activeAlert = .success(message: "Successfully imported food list")
            showingAlert = true
        } else {
            // This should never happen
            activeAlert = .fatalError(message: "Failed to import food list")
            showingAlert = true
        }
    }
    
    private func createFileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = formatter.string(from: Date())
        return "EasyFPU-export_\(timestamp)"
    }
}
