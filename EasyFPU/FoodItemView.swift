//
//  FoodItemView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 13.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct FoodItemView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    var composedFoodItem: ComposedFoodItemViewModel
    @ObservedObject var foodItem: FoodItemViewModel
    var category: FoodItemCategory
    @State var activeSheet: FoodItemViewSheets.State?
    
    var body: some View {
        VStack {
            // First line: amount, name, favorite
            HStack {
                if foodItem.amount > 0 {
                    Image(systemName: "xmark.circle").foregroundColor(.red)
                    Text(String(foodItem.amount)).font(.headline).foregroundColor(.accentColor)
                    Text("g").font(.headline).foregroundColor(.accentColor)
                } else {
                    Image(systemName: "plus.circle").foregroundColor(.green)
                }
                Text(foodItem.name).font(.headline).foregroundColor(foodItem.amount > 0 ? .accentColor : .none)
                if foodItem.favorite { Image(systemName: "star.fill").foregroundColor(.yellow).imageScale(.small) }
                Spacer()
            }
            
            // Second line: Nutritional values per 100g
            HStack {
                Text("Nutritional values per 100g:").font(.caption).foregroundColor(.gray)

                Spacer()

                Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: foodItem.caloriesPer100g))!).font(.caption).foregroundColor(.gray)
                Text("kcal").font(.caption).foregroundColor(.gray)

                Text("|").foregroundColor(.gray)

                VStack(alignment: .leading) {
                    HStack {
                        Text(DataHelper.doubleFormatter(numberOfDigits: 2).string(from: NSNumber(value: foodItem.carbsPer100g))!).font(.caption).foregroundColor(.gray)
                        Text("g Carbs").font(.caption).foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Thereof").font(.caption).foregroundColor(.gray)
                        Text(DataHelper.doubleFormatter(numberOfDigits: 2).string(from: NSNumber(value: foodItem.sugarsPer100g))!).font(.caption).foregroundColor(.gray)
                        Text("g Sugars").font(.caption).foregroundColor(.gray)
                    }
                }
            }
        }
        .onTapGesture {
            if self.foodItem.amount > 0 {
                composedFoodItem.remove(foodItem: foodItem)
            } else {
                activeSheet = .selectFoodItem
            }
        }
        .onLongPressGesture {
            // Edit food item
            activeSheet = .editFoodItem
        }
        .sheet(item: $activeSheet) {
            sheetContent($0)
        }
    }
    
    @ViewBuilder
    private func sheetContent(_ state: FoodItemViewSheets.State) -> some View {
        switch state {
        case .editFoodItem:
            if self.foodItem.cdFoodItem != nil {
                FoodItemEditor(
                    navigationBarTitle: NSLocalizedString("Edit food item", comment: ""),
                    draftFoodItem: self.foodItem,
                    editedFoodItem: self.foodItem.cdFoodItem!,
                    category: category
                ).environment(\.managedObjectContext, managedObjectContext)
            } else {
                Text(NSLocalizedString("Fatal error: Couldn't find CoreData FoodItem, please inform the app developer", comment: ""))
            }
        case .selectFoodItem:
            FoodItemSelector(draftFoodItem: self.foodItem, editedFoodItem: self.foodItem.cdFoodItem!)
        }
    }
}
