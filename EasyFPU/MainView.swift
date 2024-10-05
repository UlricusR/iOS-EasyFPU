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
    @ObservedObject var userSettings = UserSettings.shared
    @FetchRequest(
        entity: AbsorptionBlock.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \AbsorptionBlock.absorptionTime, ascending: true)
        ]
    ) var absorptionBlocks: FetchedResults<AbsorptionBlock>
    @ObservedObject var absorptionScheme = AbsorptionScheme()
    @State private var selectedTab: Int = 0
    @State private var showingAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        debugPrint(AppDelegate.persistentContainer.persistentStoreDescriptions) // The location of the .sqlite file
        if !userSettings.disclaimerAccepted {
            return AnyView(
                DisclaimerView()
            )
        } else {
            return AnyView(
                TabView(selection: $selectedTab) {
                    ComposedFoodItemEvaluationView(absorptionScheme: absorptionScheme, composedFoodItemVM: UserSettings.shared.composedMeal)
                        .tag(Tab.eat.rawValue)
                        .tabItem{
                            Image(systemName: "fork.knife")
                            Text("Eat")
                        }
                        .environment(\.managedObjectContext, managedObjectContext)
                    
                    RecipeListView(composedFoodItem: UserSettings.shared.composedMeal, helpSheet: RecipeListViewSheets.State.recipeListHelp)
                        .tag(Tab.cook.rawValue)
                        .tabItem{
                            Image(systemName: "frying.pan")
                            Text("Cook")
                        }
                        .environment(\.managedObjectContext, managedObjectContext)
                    
                    ProductMaintenanceListView()
                        .tag(Tab.products.rawValue)
                        .tabItem{
                            Image(systemName: "birthday.cake")
                            Text("Products")
                        }
                        .environment(\.managedObjectContext, managedObjectContext)
                    
                    IngredientMaintenanceListView()
                        .tag(Tab.ingredients.rawValue)
                        .tabItem{
                            Image(systemName: "carrot")
                            Text("Ingredients")
                        }
                        .environment(\.managedObjectContext, managedObjectContext)
                    
                    MenuView(draftAbsorptionScheme: AbsorptionSchemeViewModel(from: self.absorptionScheme), absorptionScheme: self.absorptionScheme)
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
}
