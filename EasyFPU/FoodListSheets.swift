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
    @Binding var draftFoodItem: FoodItemViewModel
    @Binding var editedFoodItem: FoodItem?
    
    var body: some View {
        if activeSheet == .editFoodItem {
            return AnyView(
                FoodItemEditor(
                    isPresented: self.$isPresented,
                    draftFoodItem: self.$draftFoodItem,
                    editedFoodItem: self.$editedFoodItem
                ).environment(\.managedObjectContext, managedObjectContext)
            )
        } else if activeSheet == .selectFoodItem {
            return AnyView(
                FoodItemSelector(isPresented: self.$isPresented, amountAsString: String(editedFoodItem!.amount), editedFoodItem: editedFoodItem!)
            )
        } else {
            return AnyView(EmptyView()) // Should never happen
        }
    }
}
