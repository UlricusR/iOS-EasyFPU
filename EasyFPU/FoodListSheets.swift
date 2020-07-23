//
//  FoodListSheets.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 14.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

enum ActiveFoodListSheet {
    case editFoodItem, selectFoodItem, showMealDetails
}

struct FoodListSheets: View {
    @EnvironmentObject var userData: UserData
    @Environment(\.managedObjectContext) var managedObjectContext
    var activeSheet: ActiveFoodListSheet
    @Binding var isPresented: Bool
    @Binding var draftFoodItem: FoodItemViewModel
    var meal: Meal
    @Binding var editedFoodItem: FoodItem?
    
    var body: some View {
        switch activeSheet {
        case .editFoodItem:
            return AnyView(
                FoodItemEditor(
                    isPresented: self.$isPresented,
                    draftFoodItem: self.$draftFoodItem,
                    editedFoodItem: self.$editedFoodItem
                ).environment(\.managedObjectContext, managedObjectContext)
            )
        case .selectFoodItem:
            return AnyView(
                FoodItemSelector(isPresented: self.$isPresented, amountAsString: String(editedFoodItem!.amount), editedFoodItem: editedFoodItem!)
            )
        case .showMealDetails:
            return AnyView(
                MealDetail(isPresented: self.$isPresented, meal: self.meal).environmentObject(self.userData)
            )
        }
    }
}
