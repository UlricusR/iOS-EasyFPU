//
//  FilteredFoodItemList.swift
//  EasyFPU
//  Related tutorial: https://youtu.be/O4043RVjCGU?si=xnmf9FtA9YUzb4IR
//
//  Created by Ulrich Rüth on 16/08/2025.
//  Copyright © 2025 Ulrich Rüth. All rights reserved.
//

import SwiftUI
import CoreData

struct FilteredFoodItemList: View {
    
    /// A nested view that displays the content of the food item list in case we are in selection mode
    /// (i.e., composedFoodItem != nil)
    private struct Content: View {
        @Binding var navigationPath: NavigationPath
        var foodItems: [FoodItem]
        @ObservedObject var composedFoodItem: ComposedFoodItem
        var category: FoodItemCategory
        @State private var userSettings = UserSettings.shared
        
        private var sortedFoodItems: [FoodItem] {
            return foodItems.sorted {
                if composedFoodItem.contains(foodItem: $0) && !composedFoodItem.contains(foodItem: $1) {
                    return true
                } else if !composedFoodItem.contains(foodItem: $0) && composedFoodItem.contains(foodItem: $1) {
                    return false
                } else {
                    return $0.name < $1.name
                }
            }
        }
        
        var body: some View {
            if userSettings.groupProductsByCategory && category == .product || userSettings.groupIngredientsByCategory && category == .ingredient {
                // Grouped list
                GroupedFoodList(
                    navigationPath: $navigationPath,
                    groupedFoodItems: FilteredFoodItemList.groupFoodItems(foodItems: sortedFoodItems),
                    composedFoodItem: composedFoodItem,
                    category: category
                )
            } else {
                // Un-grouped list
                UngroupedFoodList(
                    navigationPath: $navigationPath,
                    foodItems: sortedFoodItems,
                    composedFoodItem: composedFoodItem,
                    category: category
                )
            }
        }
    }
    
    /// A nested view that displays a grouped list of food items
    private struct GroupedFoodList: View {
        @Binding var navigationPath: NavigationPath
        var groupedFoodItems: [String: [FoodItem]]
        var composedFoodItem: ComposedFoodItem?
        var category: FoodItemCategory
        
        var body: some View {
            List {
                ForEach(groupedFoodItems.keys.sorted(), id: \.self) { key in
                    Section(header: Text(key)) {
                        ForEach(groupedFoodItems[key]!, id: \.id) { foodItem in
                            FoodItemView(
                                navigationPath: $navigationPath,
                                composedFoodItem: composedFoodItem,
                                foodItem: foodItem,
                                category: self.category,
                                showFoodCategory: false
                            )
                            .accessibilityIdentifierBranch(String(foodItem.name.prefix(10)))
                        }
                    }
                    .headerProminence(.increased) // Makes the section header more prominent
                }
            }
            .safeAreaPadding(EdgeInsets(top: 0, leading: 0, bottom: composedFoodItem != nil ? ActionButton.safeButtonSpace : 0, trailing: 0)) // Required to avoid the content to be hidden by the Finished button
        }
    }
    
    /// A nested view that displays an un-grouped list of food items
    private struct UngroupedFoodList: View {
        @Binding var navigationPath: NavigationPath
        var foodItems: [FoodItem]
        var composedFoodItem: ComposedFoodItem?
        var category: FoodItemCategory
        
        var body: some View {
            List(foodItems) { foodItem in
                FoodItemView(
                    navigationPath: $navigationPath,
                    composedFoodItem: composedFoodItem,
                    foodItem: foodItem,
                    category: self.category,
                    showFoodCategory: true
                )
                .accessibilityIdentifierBranch(String(foodItem.name.prefix(10)))
            }
            .safeAreaPadding(EdgeInsets(top: 0, leading: 0, bottom: composedFoodItem != nil ? ActionButton.safeButtonSpace : 0, trailing: 0)) // Required to avoid the content to be hidden by the Finished button
        }
    }

    
    @Binding var navigationPath: NavigationPath
    var composedFoodItem: ComposedFoodItem?
    @State private var userSettings = UserSettings.shared
    
    private var category: FoodItemCategory
    private var searchString: String
    
    @FetchRequest var fetchRequest: FetchedResults<FoodItem>
    
    private var ingredients: [Ingredient] {
        composedFoodItem == nil ? [] : composedFoodItem!.ingredients.allObjects as! [Ingredient]
    }
    
    private var sortedFoodItems: [FoodItem] {
        let foodItems = fetchRequest.compactMap { $0 } as! [FoodItem]
        return foodItems.sorted { $0.name < $1.name }
    }
    
    private var emptyStateImage: Image {
        switch category {
        case .product:
            Image("nachos")
        case .ingredient:
            Image("eggs-color")
        }
    }
    private var emptyStateMessage: Text {
        switch category {
        case .product:
            Text("Oops! There are no dishes in your list yet. Start by adding some!")
        case .ingredient:
            Text("Oops! There are no ingredients in your list yet. Start by adding some!")
        }
    }
    private var emptyStateButtonText: Text {
        switch category {
        case .product:
            Text("Add products")
        case .ingredient:
            Text("Add ingredients")
        }
    }
    
    var body: some View {
        if searchString.isEmpty && fetchRequest.isEmpty {
            // List is empty, so show a nice picture and an action button
            emptyStateImage.padding()
            emptyStateMessage.padding()
            Button {
                // Add new food item
                navigationPath.append(FoodItemListView.FoodListNavigationDestination.AddFoodItem(category: category))
            } label: {
                HStack {
                    Image(systemName: "plus.circle").imageScale(.large).foregroundStyle(.green)
                    emptyStateButtonText
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(ActionButton())
            .padding()
            .accessibilityIdentifierLeaf("AddFoodItemButton")
        } else {
            ZStack {
                if let composedFoodItem = composedFoodItem {
                    // We are in selection mode
                    Content(
                        navigationPath: $navigationPath,
                        foodItems: fetchRequest.compactMap { $0 } as! [FoodItem],
                        composedFoodItem: composedFoodItem,
                        category: category
                    )
                } else {
                    // We are in maintenance mode
                    if userSettings.groupProductsByCategory && category == .product || userSettings.groupIngredientsByCategory && category == .ingredient {
                        // Grouped list
                        GroupedFoodList(
                            navigationPath: $navigationPath,
                            groupedFoodItems: FilteredFoodItemList.groupFoodItems(foodItems: sortedFoodItems),
                            composedFoodItem: composedFoodItem,
                            category: category
                        )
                    } else {
                        // Un-grouped list
                        UngroupedFoodList(
                            navigationPath: $navigationPath,
                            foodItems: sortedFoodItems,
                            composedFoodItem: composedFoodItem,
                            category: category
                        )
                    }
                }
                
                // The overlaying finished button in case we have a selection type list
                // (i.e., composedFoodItem != nil)
                if composedFoodItem != nil { // We are in selection mode
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button {
                                // Return to previous view
                                navigationPath.removeLast()
                            } label: {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill").imageScale(.large).foregroundStyle(.green)
                                    Text("Finished")
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(ActionButton())
                            .accessibilityIdentifierLeaf("FinishedButton")
                            Spacer()
                        }
                        .padding()
                    }
                }
            }
        }
    }
    
    init(
        category: FoodItemCategory,
        navigationPath: Binding<NavigationPath>,
        searchString: String,
        showFavoritesOnly: Bool,
        composedFoodItem: ComposedFoodItem?
    ) {
        self.category = category
        self._navigationPath = navigationPath
        self.composedFoodItem = composedFoodItem
        self.searchString = searchString
        
        // Configure the fetch request based on the parameters
        let request = NSFetchRequest<FoodItem>(entityName: "FoodItem")
        request.includesSubentities = false // We do not want to fetch TempFoodItems here
        if showFavoritesOnly {
            if searchString.isEmpty {
                request.predicate = NSPredicate(format: "category == %@ AND favorite == true", category.rawValue)
            } else {
                request.predicate = NSPredicate(format: "category == %@ AND favorite == true AND name CONTAINS[cd] %@", category.rawValue, searchString)
            }
        } else {
            if searchString.isEmpty {
                request.predicate = NSPredicate(format: "category == %@", category.rawValue)
            } else {
                request.predicate = NSPredicate(format: "category == %@ AND name CONTAINS[cd] %@", category.rawValue, searchString)
            }
        }
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FoodItem.name, ascending: true)]
        
        _fetchRequest = FetchRequest<FoodItem>(fetchRequest: request)
    }
    
    static func groupFoodItems(foodItems: [FoodItem]) -> [String: [FoodItem]] {
        // Get the foodItems with an associated FoodCategory
        let categorizedFoodItems = foodItems.filter { $0.foodCategory != nil }
        var groupedCategorized = Dictionary(grouping: categorizedFoodItems) { $0.foodCategory!.name }
        
        // Append the uncategorized items to the grouped dictionary
        let uncategorizedFoodItems = foodItems.filter { $0.foodCategory == nil }
        if !uncategorizedFoodItems.isEmpty {
            groupedCategorized[NSLocalizedString("Uncategorized", comment: "")] = uncategorizedFoodItems
        }
        
        return groupedCategorized
    }
}
