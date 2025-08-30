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
    var composedFoodItem: ComposedFoodItemViewModel
    
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            FoodItemListView(
                category: category,
                listType: listType,
                foodItemListTitle: listTitle,
                helpSheet: helpSheet,
                navigationPath: $navigationPath,
                composedFoodItem: composedFoodItem
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
            editedCDFoodItem: FoodItem.new(category: category),
            isNewFoodItem: true,
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
        foodItemVM: FoodItemViewModel
    ) -> some View {
        if foodItemVM.cdFoodItem != nil {
            FoodItemEditor(
                navigationPath: $navigationPath,
                navigationTitle: NSLocalizedString("Edit food item", comment: ""),
                editedCDFoodItem: foodItemVM.cdFoodItem!,
                isNewFoodItem: false,
                category: category
            )
            .environment(\.managedObjectContext, managedObjectContext)
            .navigationBarBackButtonHidden(navigationBarBackButtonHidden)
            .accessibilityIdentifierBranch("EditFoodItem")
        } else {
            Text(NSLocalizedString("Fatal error: Couldn't find CoreData FoodItem, please inform the app developer", comment: ""))
        }
    }
}
