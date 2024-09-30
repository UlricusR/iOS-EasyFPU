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
    var absorptionScheme: AbsorptionScheme
    @State private var foodItemVMsToBeImported: [FoodItemViewModel]?
    @State private var activeSheet: MenuViewSheets.State?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showActionSheet = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                // Absorption Scheme
                Button(action: {
                    activeSheet = .editAbsorptionScheme
                }) {
                    Text("App Settings")
                }
                .padding(.top, 50)
                
                // Import
                Button(action: {
                    activeSheet = .pickFileToImport
                }) {
                    Text("Import from JSON")
                }
                .padding(.top, 40)
                
                // Export
                Button(action: {
                    activeSheet = .pickExportDirectory
                }) {
                    Text("Export to JSON")
                }
                .padding(.top, 15)
                
                // About
                Button(action: {
                    activeSheet = .about
                }) {
                    Text("About")
                }
                .padding(.top, 40)
                
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
                .padding(.top, 15)
                
                // Web help
                Button(action: {
                    UIApplication.shared.open(URL(string: NSLocalizedString("Home-Link", comment: ""))!)
                }) {
                    Text("Help on the Web")
                }
                .padding(.top, 15)
                
                Spacer()
            }
            .navigationBarTitle("Settings")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .actionSheet(isPresented: self.$showActionSheet) {
            ActionSheet(title: Text("Import food list"), message: Text("Please select"), buttons: [
                .default(Text("Replace")) {
                    FoodItem.deleteAll()
                    self.importFoodItems()
                },
                .default(Text("Append")) {
                    self.importFoodItems()
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
            SettingsEditor(draftAbsorptionScheme: self.draftAbsorptionScheme, editedAbsorptionScheme: absorptionScheme)
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
        if DataHelper.importFoodItems(url, foodItemVMsToBeImported: &foodItemVMsToBeImported, errorMessage: &alertMessage) {
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
    
    private func importFoodItems() {
        if foodItemVMsToBeImported != nil {
            var foodItemsNotImported = [String]()
            for foodItemVMToBeImported in foodItemVMsToBeImported! {
                var foodItemNotImported = ""
                if FoodItem.create(from: foodItemVMToBeImported, foodItemNotCreated: &foodItemNotImported) == nil {
                    // There seems to be a duplicate
                    foodItemsNotImported.append(foodItemNotImported)
                }
            }
            
            if foodItemsNotImported.isEmpty {
                alertMessage = NSLocalizedString("Successfully imported food list", comment: "")
            } else {
                alertMessage = NSLocalizedString("The following food items already exist and were not imported: ", comment: "")
                var counter = 0
                while counter < foodItemsNotImported.count {
                    if counter < 5 {
                        if counter > 0 {
                            alertMessage.append(", ")
                        }
                        alertMessage.append(foodItemsNotImported[counter])
                    } else if counter == 5 {
                        alertMessage.append(", ... (\(foodItemsNotImported.count - counter) ")
                        alertMessage.append(NSLocalizedString("more", comment: ""))
                        alertMessage.append(")")
                        break
                    }
                    counter = counter + 1
                }
            }
            showingAlert = true
        } else {
            alertMessage = NSLocalizedString("Could not import food list", comment: "")
            showingAlert = true
        }
    }
}
