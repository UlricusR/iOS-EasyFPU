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
    @Environment(\.managedObjectContext) var managedObjectContext
    var draftAbsorptionScheme: AbsorptionSchemeViewModel
    @State private var foodItemVMsToBeImported: [FoodItemViewModel]?
    @State private var composedFoodItemVMsToBeImported: [ComposedFoodItemViewModel]?
    @State private var activeSheet: MenuViewSheets.State?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showActionSheet = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Settings")) {
                    // Absorption Scheme
                    Button(action: {
                        activeSheet = .editAbsorptionScheme
                    }) {
                        Text("App Settings")
                    }
                }
                
                Section(header: Text("Import/Export")) {
                    // Import
                    Button(action: {
                        activeSheet = .pickFileToImport
                    }) {
                        Text("Import from JSON")
                    }
                    
                    // Export
                    Button(action: {
                        activeSheet = .pickExportDirectory
                    }) {
                        Text("Export to JSON")
                    }
                }
                
                Section(header: Text("Info")) {
                    // About
                    Button(action: {
                        activeSheet = .about
                    }) {
                        Text("About")
                    }
                    
                    // Disclaimer
                    Button(action: {
                        if !UserSettings.set(UserSettings.UserDefaultsType.bool(false, UserSettings.UserDefaultsBoolKey.disclaimerAccepted), errorMessage: &alertMessage) {
                            self.showingAlert = true
                        }
                        
                        // Display disclaimer
                        UserSettings.shared.disclaimerAccepted = false
                    }) {
                        Text("Disclaimer")
                    }
                    
                    // Web help
                    Button(action: {
                        UIApplication.shared.open(URL(string: NSLocalizedString("Home-Link", comment: ""))!)
                    }) {
                        Text("Help on the Web")
                    }
                }
            }
            .navigationBarTitle("Settings")
        }
        .actionSheet(isPresented: self.$showActionSheet) {
            ActionSheet(title: Text("Import food list"), message: Text("Please select"), buttons: [
                .default(Text("Replace")) {
                    self.importFoodItems(replaceExisting: true)
                },
                .default(Text("Append")) {
                    self.importFoodItems(replaceExisting: false)
                },
                .cancel()
            ])
        }
        .sheet(item: $activeSheet) {
            sheetContent($0)
        }
        .alert(isPresented: self.$showingAlert) {
            Alert(
                title: Text("Notice"),
                message: Text(self.alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    @ViewBuilder
    private func sheetContent(_ state: MenuViewSheets.State) -> some View {
        switch state {
        case .editAbsorptionScheme:
            SettingsEditor(draftAbsorptionScheme: self.draftAbsorptionScheme)
                    .environment(\.managedObjectContext, managedObjectContext)
        case .pickFileToImport:
            FilePickerView(callback: self.importJSON, documentTypes: [UTType.json])
        case .pickExportDirectory:
            FilePickerView(callback: self.exportJSON, documentTypes: [UTType.folder])
        case .about:
            AboutView()
        }
    }
    
    private func importJSON(_ url: URL) {
        if DataHelper.importFoodItems(url, foodItemVMsToBeImported: &foodItemVMsToBeImported, composedFoodItemVMsToBeImported: &composedFoodItemVMsToBeImported, errorMessage: &alertMessage) {
            self.showActionSheet = true
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
        if replaceExisting {
            DataHelper.deleteAllFood()
        }
        
        if foodItemVMsToBeImported != nil {
            for foodItemVMToBeImported in foodItemVMsToBeImported! {
                foodItemVMToBeImported.save()
            }
        }
        
        if composedFoodItemVMsToBeImported != nil {
            for composedFoodItemVMToBeImported in composedFoodItemVMsToBeImported! {
                _ = composedFoodItemVMToBeImported.save()
            }
        }
         
        if foodItemVMsToBeImported != nil || composedFoodItemVMsToBeImported != nil {
            alertMessage = NSLocalizedString("Successfully imported food list", comment: "")
            showingAlert = true
        } else {
            alertMessage = NSLocalizedString("Could not import food list", comment: "")
            showingAlert = true
        }
    }
}
