//
//  IngredientsListView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 01.11.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct IngredientsListView: View {
    @ObservedObject var absorptionScheme: AbsorptionScheme
    @Binding var selectedTab: Int
    
    static let composedFoodItemName = "Composed product"
    
    var body: some View {
        FoodItemListView(
            category: .ingredient,
            composedFoodItem: UserSettings.shared.composedProduct,
            absorptionScheme: absorptionScheme,
            helpSheet: FoodItemListViewSheets.State.ingredientsListHelp,
            foodItemListTitle: NSLocalizedString("Ingredients", comment: ""),
            selectedTab: $selectedTab
        )
    }
}
