//
//  IngredientsListView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 01.11.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct IngredientSelectionListView: View {
    @ObservedObject var composedFoodItemVM: ComposedFoodItemViewModel
    
    var body: some View {
        FoodItemListView(
            category: .ingredient,
            listType: FoodItemListView.FoodItemListType.selection,
            composedFoodItem: composedFoodItemVM,
            helpSheet: FoodItemListViewSheets.State.ingredientSelectionListHelp,
            foodItemListTitle: NSLocalizedString("Ingredients", comment: "")
        )
    }
}
