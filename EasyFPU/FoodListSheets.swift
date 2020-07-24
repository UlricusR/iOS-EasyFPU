//
//  FoodListSheets.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 14.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

enum ActiveFoodListSheet {
    case addFoodItem, showMealDetails
}

struct FoodListSheets: View {
    @EnvironmentObject var userData: UserData
    @Environment(\.managedObjectContext) var managedObjectContext
    var activeSheet: ActiveFoodListSheet
    @Binding var isPresented: Bool
    var draftFoodItem: FoodItemViewModel
    var meal: Meal
    
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
        case .showMealDetails:
            return AnyView(
                MealDetail(isPresented: self.$isPresented, meal: self.meal).environmentObject(self.userData)
            )
        }
    }
}
