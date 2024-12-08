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
        case eat = 0, cook, products, ingredients, settings
    }
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject private var bannerService: BannerService
    @ObservedObject var userSettings = UserSettings.shared
    @FetchRequest(
        entity: AbsorptionBlock.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \AbsorptionBlock.absorptionTime, ascending: true)
        ]
    ) var absorptionBlocks: FetchedResults<AbsorptionBlock>
    @ObservedObject var absorptionScheme = AbsorptionScheme()
    @State private var selectedTab: Int = 0
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
                    TabView(selection: $selectedTab) {
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
                            draftAbsorptionScheme: AbsorptionSchemeViewModel(from: self.absorptionScheme)
                        )
                        .tag(Tab.settings.rawValue)
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
                        if self.absorptionBlocks.isEmpty {
                            // Absorption blocks are empty, so initialize with default absorption scheme
                            // and store default blocks back to core data
                            guard let defaultAbsorptionBlocks = DataHelper.loadDefaultAbsorptionBlocks(errorMessage: &self.errorMessage) else {
                                debugPrint("Error loading default absorption blocks: \(self.errorMessage)")
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
                .accessibilityIdentifierBranch("MainView")
            )
        }
    }
}
