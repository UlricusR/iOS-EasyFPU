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
            foodItemListTitle: NSLocalizedString("My Products", comment: "")
        )
    }
}
