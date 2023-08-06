//
//  MainView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 28.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct MainView: View {
    enum Tab: Int {
        case products = 0, ingredients, settings
    }
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var userSettings = UserSettings.shared
    @FetchRequest(
        entity: AbsorptionBlock.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \AbsorptionBlock.absorptionTime, ascending: true)
        ]
    ) var absorptionBlocks: FetchedResults<AbsorptionBlock>
    @ObservedObject var absorptionScheme = AbsorptionScheme()
    @State private var foodItemVMsToBeImported: [FoodItemViewModel]?
    @State private var showActionSheet = false
    @State private var selectedTab: Int = 0
    @State private var showingAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        if !userSettings.disclaimerAccepted {
            return AnyView(
                DisclaimerView()
            )
        } else {
            return AnyView(
                TabView(selection: $selectedTab) {
                    ProductsListView(absorptionScheme: absorptionScheme, selectedTab: $selectedTab)
                        .tag(Tab.products.rawValue)
                        .tabItem{
                            Image(systemName: "birthday.cake")
                            Text("Products")
                        }
                        .environment(\.managedObjectContext, managedObjectContext)
                    
                    IngredientsListView(absorptionScheme: absorptionScheme, selectedTab: $selectedTab)
                        .tag(Tab.ingredients.rawValue)
                        .tabItem{
                            Image(systemName: "carrot")
                            Text("Ingredients")
                        }
                        .environment(\.managedObjectContext, managedObjectContext)
                    
                    MenuView(draftAbsorptionScheme: AbsorptionSchemeViewModel(from: self.absorptionScheme), absorptionScheme: self.absorptionScheme, filePicked: self.importJSON, exportDirectory: self.exportJSON)
                        .tag(Tab.settings.rawValue)
                        .tabItem{
                            Image(systemName: "gear")
                            Text("Settings")
                        }
                        .environment(\.managedObjectContext, managedObjectContext)
                }
                .alert(isPresented: self.$showingAlert) {
                    Alert(
                        title: Text("Notice"),
                        message: Text(self.errorMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
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
                .onAppear {
                    if self.absorptionScheme.absorptionBlocks.isEmpty {
                        // Absorption scheme hasn't been loaded yet
                        if self.absorptionBlocks.isEmpty {
                            // Absorption blocks are empty, so initialize with default absorption scheme
                            // and store default blocks back to core data
                            guard let defaultAbsorptionBlocks = DataHelper.loadDefaultAbsorptionBlocks(errorMessage: &self.errorMessage) else {
                                self.showingAlert = true
                                return
                            }
                            
                            // Create absorption blocks from default
                            AbsorptionScheme.create(from: defaultAbsorptionBlocks, for: self.absorptionScheme)
                        } else {
                            // Store absorption blocks loaded from core data
                            self.absorptionScheme.absorptionBlocks = self.absorptionBlocks.sorted()
                        }
                    }
                }
            )
        }
    }
    
    private func importJSON(_ url: URL) {
        debugPrint("Trying to import following file: \(url)")
        
        // Make sure we can access file
        guard url.startAccessingSecurityScopedResource() else {
            debugPrint("Failed to access \(url)")
            errorMessage = "Failed to access \(url)"
            showingAlert = true
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        // Read data
        var jsonData: Data
        do {
            jsonData = try Data(contentsOf: url)
        } catch {
            debugPrint(error.localizedDescription)
            errorMessage = error.localizedDescription
            showingAlert = true
            return
        }
        
        // Decode JSON
        let decoder = JSONDecoder()
        
        do {
            self.foodItemVMsToBeImported = try decoder.decode([FoodItemViewModel].self, from: jsonData)
            self.showActionSheet = true
        } catch DecodingError.keyNotFound(let key, let context) {
            errorMessage = NSLocalizedString("Failed to decode due to missing key ", comment: "") + key.stringValue + " - " + context.debugDescription
            showingAlert = true
        } catch DecodingError.typeMismatch(_, let context) {
            errorMessage = NSLocalizedString("Failed to decode due to type mismatch - ", comment: "") + context.debugDescription
            showingAlert = true
        } catch DecodingError.valueNotFound(let type, let context) {
            errorMessage = NSLocalizedString("Failed to decode due to missing value - ", comment: "") + "\(type)" + " - " + context.debugDescription
            showingAlert = true
        } catch DecodingError.dataCorrupted(_) {
            errorMessage = NSLocalizedString("Failed to decode because it appears to be invalid JSON", comment: "")
            showingAlert = true
        } catch {
            errorMessage = NSLocalizedString("Failed to decode - ", comment: "") + error.localizedDescription
            showingAlert = true
        }
    }
    
    private func exportJSON(_ url: URL) {
        // Make sure we can access file
        guard url.startAccessingSecurityScopedResource() else {
            debugPrint("Failed to access \(url)")
            errorMessage = "Failed to access \(url)"
            showingAlert = true
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        // Write file
        var fileName = ""
        if DataHelper.exportFoodItems(url, fileName: &fileName) {
            errorMessage = NSLocalizedString("Successfully exported food list to: ", comment: "") + fileName
            showingAlert = true
        } else {
            errorMessage = NSLocalizedString("Failed to export food list to: ", comment: "") + fileName
            showingAlert = true
        }
    }
    
    private func importFoodItems() {
        if foodItemVMsToBeImported != nil {
            for foodItemVMToBeImported in foodItemVMsToBeImported! {
                let cdFoodItem = FoodItem.create(from: foodItemVMToBeImported)
                
                // Check if it is associated to a ComposedFoodItemVM
                if let composedFoodItemVM = foodItemVMToBeImported.composedFoodItemVM {
                    cdFoodItem.composedFoodItem = ComposedFoodItem.duplicate(composedFoodItemVM, for: cdFoodItem)
                }
            }
            errorMessage = "Successfully imported food list"
            showingAlert = true
        } else {
            errorMessage = "Could not import food list"
            showingAlert = true
        }
    }
}
