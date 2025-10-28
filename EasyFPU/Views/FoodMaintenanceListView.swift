//
//  ProductsListView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 01.11.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI
import CoreData

struct FoodMaintenanceListView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    var category: FoodItemCategory
    var listType: FoodItemListView.FoodItemListType
    var listTitle: String
    var helpSheet: FoodItemListView.SheetState
    
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            FoodItemListView(
                category: category,
                listType: listType,
                foodItemListTitle: listTitle,
                helpSheet: helpSheet,
                navigationPath: $navigationPath
            )
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
        }
    }
    
    @ViewBuilder
    static func addFoodItem(
        @Binding navigationPath: NavigationPath,
        category: FoodItemCategory,
        managedObjectContext: NSManagedObjectContext,
        navigationBarBackButtonHidden: Bool
    ) -> some View {
        FoodItemEditor(
            navigationPath: $navigationPath,
            navigationTitle: NSLocalizedString("New \(category.rawValue)", comment: ""),
            category: category
        )
        .environment(\.managedObjectContext, managedObjectContext)
        .navigationBarBackButtonHidden(navigationBarBackButtonHidden)
        .accessibilityIdentifierBranch("AddFoodItem")
    }
    
    @ViewBuilder
    static func editFoodItem(
        @Binding navigationPath: NavigationPath,
        category: FoodItemCategory,
        managedObjectContext: NSManagedObjectContext,
        navigationBarBackButtonHidden: Bool,
        foodItem: FoodItem
    ) -> some View {
        FoodItemEditor(
            navigationPath: $navigationPath,
            navigationTitle: NSLocalizedString("Edit food item", comment: ""),
            foodItem: foodItem,
            category: category
        )
        .environment(\.managedObjectContext, managedObjectContext)
        .navigationBarBackButtonHidden(navigationBarBackButtonHidden)
        .accessibilityIdentifierBranch("EditFoodItem")
    }
}
