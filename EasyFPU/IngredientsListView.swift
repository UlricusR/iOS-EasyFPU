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
    @Binding var showingMenu: Bool
    
    var body: some View {
        FoodItemListView(
            category: .ingredient,
            absorptionScheme: absorptionScheme,
            helpSheet: FoodItemListViewSheets.State.ingredientsListHelp,
            foodItemListTitle: NSLocalizedString("Ingredients", comment: ""),
            composedFoodItemTitle: NSLocalizedString("Composed product", comment: ""),
            showingMenu: $showingMenu
        )
    }
}
