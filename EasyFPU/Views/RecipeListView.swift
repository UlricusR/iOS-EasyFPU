//
//  RecipeListView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 30/09/2024.
//  Copyright © 2024 Ulrich Rüth. All rights reserved.
//

import SwiftUI
import CoreData

struct RecipeListView: View {
    enum RecipeNavigationDestination: Hashable {
        case CreateRecipe
        case AddIngredients(recipe: ComposedFoodItem, tempContext: NSManagedObjectContext?)
        case EditRecipe(recipe: ComposedFoodItem)
    }
    
    enum SheetState: Identifiable {
        case recipeListHelp
        
        var id: SheetState { self }
    }
    
    static let recipeDefaultName = NSLocalizedString("Composed product", comment: "")
    
    @Environment(\.managedObjectContext) var managedObjectContext
    var helpSheet: SheetState
    @State private var navigationPath = NavigationPath()
    @State private var searchString = ""
    @State private var showFavoritesOnly = false
    @State private var activeSheet: SheetState?
    
    @FetchRequest(fetchRequest: ComposedFoodItem.createFetchRequest())
    var composedFoodItems: FetchedResults<ComposedFoodItem>
    
    private var filteredComposedFoodItems: [ComposedFoodItem] {
        if searchString == "" {
            return showFavoritesOnly ? composedFoodItems.map { $0 } .filter { $0.favorite } : composedFoodItems.map { $0 }
        } else {
            return showFavoritesOnly ? composedFoodItems.map { $0 } .filter { $0.favorite && $0.name.lowercased().contains(searchString.lowercased()) } : composedFoodItems.map {
                $0 } .filter { $0.name.lowercased().contains(searchString.lowercased()) }
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
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(ActionButton())
                    .padding()
                    .accessibilityIdentifierLeaf("StartCookingButton")
                } else {
                    List {
                        ForEach(self.filteredComposedFoodItems, id: \.self) { composedFoodItem in
                            RecipeView(
                                navigationPath: $navigationPath,
                                composedFoodItem: composedFoodItem
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
                case let .EditFoodItem(category: category, foodItem: foodItem):
                    FoodMaintenanceListView.editFoodItem(
                        $navigationPath: $navigationPath,
                        category: category,
                        managedObjectContext: managedObjectContext,
                        navigationBarBackButtonHidden: true,
                        foodItem: foodItem
                    )
                    .accessibilityIdentifierBranch("EditFoodItem")
                case let .SelectFoodItem(category: category, ingredient: ingredient, composedFoodItem: composedFoodItem):
                    FoodItemSelector(
                        navigationPath: $navigationPath,
                        ingredient: ingredient,
                        composedFoodItem: composedFoodItem,
                        category: category
                    )
                    .accessibilityIdentifierBranch("SelectFoodItem")
                }
            }
            .navigationDestination(for: RecipeNavigationDestination.self) { screen in
                switch screen {
                case .CreateRecipe:
                    RecipeEditor(
                        navigationPath: $navigationPath
                    )
                    .environment(\.managedObjectContext, managedObjectContext)
                    .navigationBarBackButtonHidden()
                    .accessibilityIdentifierBranch("CreateRecipe")
                case let .AddIngredients(recipe: recipe, tempContext: tempContext):
                    FoodItemListView(
                        category: .ingredient,
                        listType: .selection(composedFoodItem: recipe, tempContext: tempContext),
                        foodItemListTitle: NSLocalizedString("Ingredients", comment: ""),
                        helpSheet: .ingredientSelectionListHelp,
                        navigationPath: $navigationPath
                    )
                    .accessibilityIdentifierBranch("SelectIngredients")
                    .navigationBarBackButtonHidden()
                case let .EditRecipe(recipe: recipe):
                    RecipeEditor(
                        navigationPath: $navigationPath,
                        composedFoodItem: recipe
                    )
                    .environment(\.managedObjectContext, managedObjectContext)
                    .navigationBarBackButtonHidden()
                    .accessibilityIdentifierBranch("EditRecipe")
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
        case .recipeListHelp:
            HelpView(helpScreen: .recipeList)
                .accessibilityIdentifierBranch("HelpRecipeList")
        }
    }
}

struct RecipeListView_Previews: PreviewProvider {
    @State private static var navigationPath = NavigationPath()
    static var previews: some View {
        RecipeListView(
            helpSheet: .recipeListHelp
        )
    }
}
