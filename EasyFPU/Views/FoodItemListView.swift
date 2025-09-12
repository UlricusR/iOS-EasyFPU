//
//  FoodItemListView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 01.11.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct FoodItemListView: View {
    enum FoodListNavigationDestination: Hashable {
        case AddFoodItem(category: FoodItemCategory)
        case EditFoodItem(category: FoodItemCategory, foodItem: FoodItem)
        case SelectFoodItem(category: FoodItemCategory, ingredient: Ingredient, composedFoodItem: ComposedFoodItem)
    }
    
    enum FoodItemListType {
        case maintenance
        case selection
    }
    
    enum SheetState: Identifiable {
        case productSelectionListHelp
        case productMaintenanceListHelp
        case ingredientSelectionListHelp
        case ingredientMaintenanceListHelp
        
        var id: SheetState { self }
    }
    
    var category: FoodItemCategory
    var listType: FoodItemListType
    var foodItemListTitle: String
    var helpSheet: SheetState
    @Binding var navigationPath: NavigationPath
    @State var userSettings = UserSettings.shared
    @ObservedObject var composedFoodItem: ComposedFoodItem
    
    @State private var searchString = ""
    @State private var showFavoritesOnly = false
    @State private var activeSheet: SheetState?
    
    var body: some View {
        VStack {
            // The food list
            FilteredFoodItemList(
                category: category,
                listType: listType,
                navigationPath: $navigationPath,
                composedFoodItem: composedFoodItem,
                searchString: searchString,
                showFavoritesOnly: showFavoritesOnly
            )
        }
        .navigationTitle(foodItemListTitle)
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
                    // Add new food item
                    navigationPath.append(FoodItemListView.FoodListNavigationDestination.AddFoodItem(category: category))
                }) {
                    Image(systemName: "plus.circle")
                        .imageScale(.large)
                        .foregroundStyle(.green)
                }
                .accessibilityIdentifierLeaf("AddFoodItemButton")
            }
            
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                // The grouping button
                Button(action: {
                    withAnimation {
                        var errorMessage = ""
                        if category == .product {
                            self.userSettings.groupProductsByCategory.toggle()
                            _ = UserSettings.set(UserSettings.UserDefaultsType.bool(userSettings.groupProductsByCategory, UserSettings.UserDefaultsBoolKey.groupProductsByCategory), errorMessage: &errorMessage)
                        } else if category == .ingredient {
                            self.userSettings.groupIngredientsByCategory.toggle()
                            _ = UserSettings.set(UserSettings.UserDefaultsType.bool(userSettings.groupIngredientsByCategory, UserSettings.UserDefaultsBoolKey.groupIngredientsByCategory), errorMessage: &errorMessage)
                        }
                    }
                }) {
                    if category == .product && self.userSettings.groupProductsByCategory ||
                        category == .ingredient && self.userSettings.groupIngredientsByCategory {
                        Image(systemName: "square.grid.3x1.below.line.grid.1x2.fill")
                            .foregroundStyle(Color.blue)
                            .imageScale(.large)
                    } else {
                        Image(systemName: "square.grid.3x1.below.line.grid.1x2")
                            .foregroundStyle(Color.blue)
                            .imageScale(.large)
                    }
                }
                
                // The favorite button
                Button(action: {
                    withAnimation {
                        self.showFavoritesOnly.toggle()
                    }
                }) {
                    if self.showFavoritesOnly {
                        Image(systemName: "star.fill")
                            .foregroundStyle(Color.yellow)
                            .imageScale(.large)
                    } else {
                        Image(systemName: "star")
                            .foregroundStyle(Color.blue)
                            .imageScale(.large)
                    }
                }
                .accessibilityIdentifierLeaf("FavoriteButton")
            }
        }
        .searchable(text: self.$searchString)
        .sheet(item: $activeSheet) {
            sheetContent($0)
        }
    }
    
    @ViewBuilder
    private func sheetContent(_ state: SheetState) -> some View {
        switch state {
        case .productMaintenanceListHelp:
            HelpView(helpScreen: .productMaintenanceList)
                .accessibilityIdentifierBranch("HelpProductMaintenanceList")
        case .productSelectionListHelp:
            HelpView(helpScreen: .productSelectionList)
                .accessibilityIdentifierBranch("HelpProductSelectionList")
        case .ingredientMaintenanceListHelp:
            HelpView(helpScreen: .ingredientMaintenanceList)
                .accessibilityIdentifierBranch("HelpIngredientMaintenanceList")
        case .ingredientSelectionListHelp:
            HelpView(helpScreen: .ingredientSelectionList)
                .accessibilityIdentifierBranch("HelpIngredientSelectionList")
        }
    }
}

struct FoodItemListView_Previews: PreviewProvider {
    @State private static var navigationPath = NavigationPath()
    static var previews: some View {
        FoodItemListView(
            category: .product,
            listType: .selection,
            foodItemListTitle: "My Products",
            helpSheet: .productSelectionListHelp,
            navigationPath: $navigationPath,
            composedFoodItem: TempComposedFoodItem.new(name: "Sample")
        )
    }
}
