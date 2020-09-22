//
//  FoodListSheets.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 14.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

enum ActiveFoodListSheet {
    case addFoodItem, mealDetails, help
}

struct FoodListSheets: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    var activeSheet: ActiveFoodListSheet
    var helpScreen: HelpScreen
    @Binding var isPresented: Bool
    var draftFoodItem: FoodItemViewModel
    var absorptionScheme: AbsorptionScheme
    var meal: MealViewModel
    
    var body: some View {
        switch activeSheet {
        case .addFoodItem:
            return AnyView(
                FoodItemEditor(
                    isPresented: self.$isPresented,
                    navigationBarTitle: NSLocalizedString("New food item", comment: ""),
                    draftFoodItem: self.draftFoodItem
                ).environment(\.managedObjectContext, managedObjectContext)
            )
        case .mealDetails:
            return AnyView(
                MealDetail(isPresented: $isPresented, absorptionScheme: self.absorptionScheme, meal: self.meal)
            )
        case .help:
            return AnyView(
                HelpView(isPresented: $isPresented, helpScreen: helpScreen)
            )
        }
    }
}
