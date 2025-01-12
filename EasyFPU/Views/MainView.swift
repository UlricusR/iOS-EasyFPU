//
//  MainView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 28.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

enum SimpleAlertType {
    case success(message: String)
    case notice(message: String)
    case warning(message: String)
    case error(message: String)
    case fatalError(message: String)
    
    func title() -> String {
        switch self {
        case .success(_):
            return NSLocalizedString("Success", comment: "")
        case .notice(_):
            return NSLocalizedString("Notice", comment: "")
        case .warning(_):
            return NSLocalizedString("Warning", comment: "")
        case .error(_):
            return NSLocalizedString("Error", comment: "")
        case .fatalError(_):
            return NSLocalizedString("Fatal Error", comment: "")
        }
    }
    
    func button() -> some View {
        Button("OK", role: .cancel) {}
    }
    
    func message() -> some View {
        Text(verbatim: messageAsString())
    }
    
    func messageAsString() -> String {
        switch self {
        case let .success(message: message):
            return NSLocalizedString(message, comment: "")
        case let .notice(message: message):
            return NSLocalizedString(message, comment: "")
        case let .warning(message: message):
            return NSLocalizedString(message, comment: "")
        case let .error(message: message):
            return NSLocalizedString(message, comment: "")
        case let .fatalError(message: message):
            return "\(NSLocalizedString(message, comment: "")) - \(NSLocalizedString("This should not have happened, please inform the developer team.", comment: ""))"
        }
    }
}

struct MainView: View {
    enum Tab: Int {
        case eat = 0, cook, products, ingredients, settings
    }
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var userSettings = UserSettings.shared
    @FetchRequest(
        entity: AbsorptionBlock.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \AbsorptionBlock.absorptionTime, ascending: true)
        ]
    ) var absorptionBlocks: FetchedResults<AbsorptionBlock>
    @ObservedObject var absorptionScheme = AbsorptionSchemeViewModel()
    @State private var activeAlert: SimpleAlertType?
    @State private var showingAlert = false
    @State private var isConfirming = false
    @State private var importData: ImportData?
    
    var body: some View {
        debugPrint(CoreDataStack.persistentContainer.persistentStoreDescriptions) // The location of the .sqlite file
        if !userSettings.disclaimerAccepted {
            return AnyView(
                DisclaimerView()
                    .accessibilityIdentifierBranch("Disclaimer")
            )
        } else {
            return AnyView(
                TabView {
                    // The meal composer
                    ComposedFoodItemEvaluationView(
                        absorptionScheme: absorptionScheme,
                        composedFoodItemVM: UserSettings.shared.composedMeal
                    )
                    .tag(Tab.eat.rawValue)
                    .tabItem{
                        Image(systemName: "fork.knife")
                        Text("Eat")
                    }
                    .environment(\.managedObjectContext, managedObjectContext)
                    .accessibilityIdentifierBranch("CalculateMeal")
                    
                    // The recipe list
                    RecipeListView(
                        composedFoodItem: UserSettings.shared.composedMeal,
                        helpSheet: RecipeListView.SheetState.recipeListHelp
                    )
                    .tag(Tab.cook.rawValue)
                    .tabItem{
                        Image(systemName: "frying.pan")
                        Text("Cook")
                    }
                    .environment(\.managedObjectContext, managedObjectContext)
                    .accessibilityIdentifierBranch("CookAndBake")
                    
                    // The product maintenance list
                    FoodMaintenanceListView(
                        category: .product,
                        listType: .maintenance,
                        listTitle: NSLocalizedString("My Products", comment: ""),
                        helpSheet: .productMaintenanceListHelp,
                        composedFoodItem: UserSettings.shared.composedMeal
                    )
                    .tag(Tab.products.rawValue)
                    .tabItem{
                        Image(systemName: "birthday.cake")
                        Text("Products")
                    }
                    .environment(\.managedObjectContext, managedObjectContext)
                    .accessibilityIdentifierBranch("MaintainProducts")
                    
                    // The ingredient maintenance list
                    FoodMaintenanceListView(
                        category: .ingredient,
                        listType: .maintenance,
                        listTitle: NSLocalizedString("My Ingredients", comment: ""),
                        helpSheet: .ingredientMaintenanceListHelp,
                        composedFoodItem: UserSettings.shared.composedProduct
                    )
                    .tag(Tab.ingredients.rawValue)
                    .tabItem{
                        Image(systemName: "carrot")
                        Text("Ingredients")
                    }
                    .environment(\.managedObjectContext, managedObjectContext)
                    .accessibilityIdentifierBranch("MaintainIngredients")
                    
                    // The settings
                    MenuView(
                        absorptionScheme: absorptionScheme
                    )
                    .tag(Tab.settings.rawValue)
                    .tabItem{
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                    .environment(\.managedObjectContext, managedObjectContext)
                    .accessibilityIdentifierBranch("Settings")
                }
                .onAppear {
                    if self.absorptionScheme.absorptionBlocks.isEmpty {
                        // Absorption scheme hasn't been loaded yet
                        var errorMessage = ""
                        if !self.absorptionScheme.initAbsorptionBlocks(with: absorptionBlocks, errorMessage: &errorMessage) {
                            activeAlert = .fatalError(message: errorMessage)
                            showingAlert = true
                        }
                    }
                }
                .onOpenURL { url in
                    importFoodData(from: url)
                }
                .confirmationDialog(
                    "Import food list",
                    isPresented: $isConfirming,
                    titleVisibility: .visible
                ) {
                    Button("Replace") {
                        if let importData {
                            DataHelper.deleteAllFood()
                            importData.save()
                        }
                    }
                    Button("Append") {
                        if let importData {
                            importData.save()
                        }
                    }
                    Button("Cancel", role: .cancel) {
                        isConfirming.toggle()
                    }
                } message: {
                    Text("Please select")
                }
                .accessibilityIdentifierBranch("MainView")
            )
        }
    }
    
    private func importFoodData(from url: URL) {
        // Import Food Item
        do {
            // Verify the URL’s extension is fooditem, since EasyFPU only supports files with that extension
            guard url.pathExtension == "fooddata" else {
                throw ImportExportError.wrongFileExtension
            }
            
            var errorMessage = ""
            
            // Make sure we can access file
            guard url.startAccessingSecurityScopedResource() else {
                throw ImportExportError.noFileAccess
            }
            defer { url.stopAccessingSecurityScopedResource() }
            
            let jsonData = try Data(contentsOf: url)
            if let importData = DataHelper.decodeFoodData(jsonData: jsonData, errorMessage: &errorMessage) {
                self.importData = importData
                let itemCount = importData.countItems()
                if itemCount == (1, 0) || itemCount == (0, 1) {
                    // These are single items, we just append them
                    importData.save()
                } else {
                    isConfirming = true
                }
            } else {
                activeAlert = .error(message: errorMessage)
                showingAlert = true
            }
        } catch ImportExportError.wrongFileExtension {
            activeAlert = .error(message: "Error: File must have extension fooddata")
            showingAlert = true
        } catch ImportExportError.noFileAccess {
            activeAlert = .error(message: "\(NSLocalizedString("Failed to access", comment: "")) \(url)")
            showingAlert = true
        } catch {
            activeAlert = .error(message: error.localizedDescription)
            showingAlert = true
        }
    }
}
