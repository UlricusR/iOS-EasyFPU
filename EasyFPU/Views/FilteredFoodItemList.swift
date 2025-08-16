//
//  FilteredFoodItemList.swift
//  EasyFPU
//  Related tutorial: https://www.hackingwithswift.com/quick-start/swiftui/how-to-filter-a-list-using-a-fetchrequest
//
//  Created by Ulrich Rüth on 16/08/2025.
//  Copyright © 2025 Ulrich Rüth. All rights reserved.
//

import SwiftUI
import CoreData

struct FilteredFoodItemList: View {
    @Binding var navigationPath: NavigationPath
    @ObservedObject private var composedFoodItem: ComposedFoodItemViewModel
    @ObservedObject private var userSettings = UserSettings.shared
    
    private var category: FoodItemCategory
    private var listType: FoodItemListView.FoodItemListType
    
    @FetchRequest var fetchRequest: FetchedResults<FoodItem>
    
    private var sortedFoodItemVMs: [FoodItemViewModel] {
        let foodItemVMs = fetchRequest.map { FoodItemViewModel(from: $0) }
        return foodItemVMs.sorted {
            if listType == .selection {
                if composedFoodItem.foodItemVMs.contains($0) && !composedFoodItem.foodItemVMs.contains($1) {
                    return true
                } else if !composedFoodItem.foodItemVMs.contains($0) && composedFoodItem.foodItemVMs.contains($1) {
                    return false
                } else {
                    return $0.name < $1.name
                }
            } else {
                return $0.name < $1.name
            }
        }
    }
    
    private var groupedFoodItemVMs: [String: [FoodItemViewModel]] {
        let foodItemVMs = sortedFoodItemVMs
        
        // Get the foodItemVMs with an associated FoodCategory
        let categorizedFoodItemVMs = foodItemVMs.filter { $0.foodCategory != nil }
        var groupedCategorized = Dictionary(grouping: categorizedFoodItemVMs) { $0.foodCategory!.name }
        
        // Append the uncategorized items to the grouped dictionary
        let uncategorizedFoodItemVMs = foodItemVMs.filter { $0.foodCategory == nil }
        if !uncategorizedFoodItemVMs.isEmpty {
            groupedCategorized[NSLocalizedString("Uncategorized", comment: "")] = uncategorizedFoodItemVMs
        }
        
        return groupedCategorized
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
        if fetchRequest.isEmpty {
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
                if userSettings.groupProductsByCategory && category == .product || userSettings.groupIngredientsByCategory && category == .ingredient {
                    // Grouped list
                    List {
                        ForEach(groupedFoodItemVMs.keys.sorted(), id: \.self) { key in
                            Section(header: Text(key)) {
                                ForEach(groupedFoodItemVMs[key]!, id: \.id) { foodItem in
                                    FoodItemView(navigationPath: $navigationPath, composedFoodItemVM: composedFoodItem, foodItemVM: foodItem, category: self.category, listType: listType, showFoodCategory: false)
                                        .accessibilityIdentifierBranch(String(foodItem.name.prefix(10)))
                                }
                            }
                        }
                    }
                    .safeAreaPadding(EdgeInsets(top: 0, leading: 0, bottom: listType == .selection ? ActionButton.safeButtonSpace : 0, trailing: 0)) // Required to avoid the content to be hidden by the Finished button
                } else {
                    // Un-grouped list
                    List(sortedFoodItemVMs) { foodItem in
                        FoodItemView(navigationPath: $navigationPath, composedFoodItemVM: composedFoodItem, foodItemVM: foodItem, category: self.category, listType: listType, showFoodCategory: true)
                            .accessibilityIdentifierBranch(String(foodItem.name.prefix(10)))
                    }
                    .safeAreaPadding(EdgeInsets(top: 0, leading: 0, bottom: listType == .selection ? ActionButton.safeButtonSpace : 0, trailing: 0)) // Required to avoid the content to be hidden by the Finished button
                }
                
                // The overlaying finished button in case we have a selection type list
                if listType == .selection {
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
        listType: FoodItemListView.FoodItemListType,
        navigationPath: Binding<NavigationPath>,
        composedFoodItem: ComposedFoodItemViewModel,
        searchString: String,
        showFavoritesOnly: Bool
    ) {
        self.category = category
        self.listType = listType
        self._navigationPath = navigationPath
        self.composedFoodItem = composedFoodItem
        
        // Configure the fetch request based on the parameters
        let request = NSFetchRequest<FoodItem>(entityName: "FoodItem")
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
}
