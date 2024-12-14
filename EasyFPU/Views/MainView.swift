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
    
    func title() -> String {
        switch self {
        case .success(_):
            return "Success"
        case .notice(_):
            return "Notice"
        case .warning(_):
            return "Warning"
        case .error(_):
            return "Error"
        }
    }
    
    func button() -> some View {
        Button("OK", role: .cancel) {}
    }
    
    func message() -> some View {
        switch self {
        case let .success(message: message):
            return Text(message)
        case let .notice(message: message):
            return Text(message)
        case let .warning(message: message):
            return Text(message)
        case let .error(message: message):
            return Text(message)
        }
    }
}

struct MainView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject private var bannerService: BannerService
    @ObservedObject var userSettings = UserSettings.shared
    @FetchRequest(
        entity: AbsorptionBlock.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \AbsorptionBlock.absorptionTime, ascending: true)
        ]
    ) var absorptionBlocks: FetchedResults<AbsorptionBlock>
    @ObservedObject var absorptionScheme = AbsorptionSchemeViewModel()
    @State private var errorMessage = ""
    
    var body: some View {
        debugPrint(CoreDataStack.persistentContainer.persistentStoreDescriptions) // The location of the .sqlite file
        if !userSettings.disclaimerAccepted {
            return AnyView(
                DisclaimerView()
                    .accessibilityIdentifierBranch("Disclaimer")
            )
        } else {
            return AnyView(
                ZStack {
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
                    
                    if let type = bannerService.bannerType {
                        BannerView(banner: type)
                    }
                }
                .environmentObject(bannerService)
                .onAppear {
                    if self.absorptionScheme.absorptionBlocks.isEmpty {
                        // Absorption scheme hasn't been loaded yet
                        if !self.absorptionScheme.initAbsorptionBlocks(with: absorptionBlocks, errorMessage: &errorMessage) {
                            bannerService.setBanner(banner: .error(message: errorMessage, isPersistent: true))
                        }
                    }
                }
                .accessibilityIdentifierBranch("MainView")
            )
        }
    }
}
