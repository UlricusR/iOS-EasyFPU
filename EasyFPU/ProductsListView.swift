//
//  ProductsListView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 01.11.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct ProductsListView: View {
    @ObservedObject var absorptionScheme: AbsorptionScheme
    @Binding var showingMenu: Bool
    @Binding var selectedTab: Int
    
    static let composedFoodItemName = "Total meal"
    
    var body: some View {
        FoodItemListView(
            category: .product,
            composedFoodItem: UserSettings.shared.composedMeal,
            absorptionScheme: absorptionScheme,
            helpSheet: FoodItemListViewSheets.State.productsListHelp,
            foodItemListTitle: NSLocalizedString("Products", comment: ""),
            showingMenu: $showingMenu,
            selectedTab: $selectedTab
        )
    }
}
