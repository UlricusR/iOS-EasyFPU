//
//  FoodListSheets.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 14.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

enum ActiveFoodListSheet {
    case editFoodItem, selectFoodItem
}

struct FoodListSheets: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    var activeSheet: ActiveFoodListSheet
    @Binding var isPresented: Bool
    
    var body: some View {
        if activeSheet == .editFoodItem {
            return AnyView(
                FoodItemEditor(isPresented: self.$isPresented, draftFoodItem: FoodItemViewModel(name: "", favorite: false, caloriesPer100g: "", carbsPer100g: ""))
                .environment(\.managedObjectContext, self.managedObjectContext)
            )
        } else if activeSheet == .selectFoodItem {
            return AnyView(Text("Select Food Item"))
        } else {
            return AnyView(EmptyView()) // Should never happen
        }
    }
}
