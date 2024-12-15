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
        switch self {
        case let .success(message: message):
            return Text(NSLocalizedString(message, comment: ""))
        case let .notice(message: message):
            return Text(NSLocalizedString(message, comment: ""))
        case let .warning(message: message):
            return Text(NSLocalizedString(message, comment: ""))
        case let .error(message: message):
            return Text(NSLocalizedString(message, comment: ""))
        case let .fatalError(message: message):
            return Text("\(NSLocalizedString(message, comment: "")) - \(NSLocalizedString("This should not have happened, please inform the developer team.", comment: ""))")
        }
    }
}

struct MainView: View {
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
                .accessibilityIdentifierBranch("MainView")
            )
        }
    }
}
