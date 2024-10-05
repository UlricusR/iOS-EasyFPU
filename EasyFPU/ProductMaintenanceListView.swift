//
//  ProductsListView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 01.11.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct ProductMaintenanceListView: View {
    var body: some View {
        FoodItemListView(
            category: .product,
            listType: FoodItemListView.FoodItemListType.maintenance,
            composedFoodItem: UserSettings.shared.composedMeal,
            helpSheet: FoodItemListViewSheets.State.productMaintenanceListHelp,
            foodItemListTitle: NSLocalizedString("My Products", comment: ""),
            emptyStateImage: Image("nachos"),
            emptyStateMessage: Text("Oops! There are no dishes in your list yet. Start by adding some!"),
            emptyStateButtonText: Text("Add products")
        )
    }
}
