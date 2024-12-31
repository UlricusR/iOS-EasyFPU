//
//  RecipeListView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 30/09/2024.
//  Copyright © 2024 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct RecipeListView: View {
    enum RecipeNavigationDestination: Hashable {
        case CreateRecipe
        case AddIngredients(recipe: ComposedFoodItemViewModel)
        case EditRecipe(recipe: ComposedFoodItemViewModel)
    }
    
    enum SheetState: Identifiable {
        case exportRecipe
        case recipeListHelp
        
        var id: SheetState { self }
    }
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var composedFoodItem: ComposedFoodItemViewModel
    var helpSheet: SheetState
    @State private var navigationPath = NavigationPath()
    @State private var searchString = ""
    @State private var showFavoritesOnly = false
    @State private var activeSheet: SheetState?
    
    @FetchRequest(
        entity: ComposedFoodItem.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \ComposedFoodItem.name, ascending: true)
        ]
    ) var composedFoodItems: FetchedResults<ComposedFoodItem>
    
    private var filteredComposedFoodItems: [ComposedFoodItemViewModel] {
        if searchString == "" {
            return showFavoritesOnly ? composedFoodItems.map { ComposedFoodItemViewModel(from: $0) } .filter { $0.favorite } : composedFoodItems.map { ComposedFoodItemViewModel(from: $0) }
        } else {
            return showFavoritesOnly ? composedFoodItems.map { ComposedFoodItemViewModel(from: $0) } .filter { $0.favorite && $0.name.lowercased().contains(searchString.lowercased()) } : composedFoodItems.map { ComposedFoodItemViewModel(from: $0) } .filter { $0.name.lowercased().contains(searchString.lowercased()) }
        }
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack {
                if composedFoodItems.isEmpty {
                    // No recipe yet, so display info and a call for action button
                    Image("cooking-book-color").padding()
                    Text("Oops! No recipe yet! Then let's go!").padding()
                    Button {
                        // Reset the shared ComposedViewVM
                        UserSettings.shared.composedProduct.clear()
                        
                        // Start new recipe
                        navigationPath.append(RecipeNavigationDestination.CreateRecipe)
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle")
                                .imageScale(.large)
                                .foregroundStyle(.green)
                                .bold()
                            Text("Start cooking or baking")
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(.yellow)
                        )
                    }
                    .accessibilityIdentifierLeaf("StartCookingButton")
                } else {
                    List {
                        ForEach(self.filteredComposedFoodItems) { composedFoodItem in
                            RecipeView(
                                navigationPath: $navigationPath,
                                composedFoodItemVM: composedFoodItem
                            )
                            .environment(\.managedObjectContext, self.managedObjectContext)
                            .accessibilityIdentifierBranch(String(composedFoodItem.name.prefix(10)))
                        }
                    }
                }
            }
            .navigationTitle("Recipes")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(action: {
                        withAnimation {
                            self.activeSheet = helpSheet
                        }
                    }) {
                        Image(systemName: "questionmark.circle")
                            .imageScale(.large)
                    }
                    .accessibilityIdentifierLeaf("HelpButton")
                    
                    Button(action: {
                        // Reset the shared ComposedViewVM
                        UserSettings.shared.composedProduct.clear()
                        
                        navigationPath.append(RecipeNavigationDestination.CreateRecipe)
                    }) {
                        Image(systemName: "plus.circle")
                            .foregroundStyle(.green)
                            .imageScale(.large)
                    }
                    .accessibilityIdentifierLeaf("AddRecipeButton")
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation {
                            self.showFavoritesOnly.toggle()
                        }
                    }) {
                        if self.showFavoritesOnly {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                                .imageScale(.large)
                        } else {
                            Image(systemName: "star")
                                .foregroundStyle(.blue)
                                .imageScale(.large)
                        }
                    }
                    .accessibilityIdentifierLeaf("FavoriteButton")
                }
            }
            .navigationDestination(for: FoodItemListView.FoodListNavigationDestination.self) { screen in
                switch screen {
                case let .AddFoodItem(category: category):
                    FoodMaintenanceListView.addFoodItem(
                        $navigationPath: $navigationPath,
                        category: category,
                        managedObjectContext: managedObjectContext,
                        navigationBarBackButtonHidden: true
                    )
                    .accessibilityIdentifierBranch("AddFoodItem")
                case let .EditFoodItem(category: category, foodItemVM: foodItemVM):
                    FoodMaintenanceListView.editFoodItem(
                        $navigationPath: $navigationPath,
                        category: category,
                        managedObjectContext: managedObjectContext,
                        navigationBarBackButtonHidden: true,
                        foodItemVM: foodItemVM
                    )
                    .accessibilityIdentifierBranch("EditFoodItem")
                case let .SelectFoodItem(category: category, draftFoodItem: foodItemVM, composedFoodItem: composedFoodItemVM):
                    FoodItemSelector(
                        navigationPath: $navigationPath,
                        draftFoodItem: foodItemVM,
                        composedFoodItem: composedFoodItemVM,
                        category: category
                    )
                    .accessibilityIdentifierBranch("SelectFoodItem")
                }
            }
            .navigationDestination(for: RecipeNavigationDestination.self) { screen in
                switch screen {
                case .CreateRecipe:
                    FoodItemComposerView(
                        composedFoodItemVM: UserSettings.shared.composedProduct,
                        navigationPath: $navigationPath
                    )
                    .environment(\.managedObjectContext, managedObjectContext)
                    .accessibilityIdentifierBranch("CreateRecipe")
                case let .AddIngredients(recipe: recipe):
                    FoodItemListView(
                        category: .ingredient,
                        listType: .selection,
                        foodItemListTitle: NSLocalizedString("Ingredients", comment: ""),
                        helpSheet: .ingredientSelectionListHelp,
                        navigationPath: $navigationPath,
                        composedFoodItem: recipe
                    )
                    .accessibilityIdentifierBranch("SelectIngredients")
                    .navigationBarBackButtonHidden()
                case let .EditRecipe(recipe: recipe):
                    if recipe.cdComposedFoodItem != nil {
                        FoodItemComposerView(
                            composedFoodItemVM: recipe,
                            navigationPath: $navigationPath
                        )
                        .environment(\.managedObjectContext, managedObjectContext)
                        .accessibilityIdentifierBranch("EditRecipe")
                    } else {
                        Text(NSLocalizedString("Fatal error: Couldn't find CoreData FoodItem, please inform the app developer", comment: ""))
                    }
                }
            }
            .searchable(text: self.$searchString)
            .sheet(item: $activeSheet) {
                sheetContent($0)
            }
        }
    }
    
    @ViewBuilder
    private func sheetContent(_ state: SheetState) -> some View {
        switch state {
        case .exportRecipe:
            if let path = self.composedFoodItem.exportToURL() {
                ActivityView(activityItems: [path], applicationActivities: nil)
            } else {
                Text(NSLocalizedString("Could not generate data export", comment: ""))
            }
        case .recipeListHelp:
            HelpView(helpScreen: .recipeList)
                .accessibilityIdentifierBranch("HelpRecipeList")
        }
    }
}
