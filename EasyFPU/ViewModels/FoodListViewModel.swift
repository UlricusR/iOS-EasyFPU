//
//  FoodListViewModel.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 15/08/2025.
//  Copyright © 2025 Ulrich Rüth. All rights reserved.
//

import Foundation

class FoodListViewModel: ObservableObject {
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
    
    @Published var searchString = ""
    @Published var showFavoritesOnly = false
    
    @Published var foodItems: [FoodItemViewModel] = []
    
    private(set) var category: FoodItemCategory
    private(set) var listType: FoodItemListType
    private(set) var foodItemListTitle: String
    private(set) var helpSheet: SheetState
    
    var filteredFoodItems: [FoodItemViewModel] {
        if searchString == "" {
            return showFavoritesOnly ?
            foodItems.map { $0 } .filter { $0.favorite } :
            foodItems
        } else {
            return showFavoritesOnly ?
            foodItems.map { $0 } .filter { $0.favorite && $0.name.lowercased().contains(searchString.lowercased()) } :
            foodItems.map { $0 } .filter { $0.name.lowercased().contains(searchString.lowercased()) }
        }
    }
    
    init(
        category: FoodItemCategory,
        listType: FoodItemListType,
        foodItemListTitle: String,
        helpSheet: SheetState
    ) {
        self.category = category
        self.listType = listType
        self.foodItemListTitle = foodItemListTitle
        self.helpSheet = helpSheet
        loadFoodItems()
    }
    
    func loadFoodItems() {
        foodItems = FoodItem.fetchAll(for: category).map { FoodItemViewModel(from: $0) }
    }
}

