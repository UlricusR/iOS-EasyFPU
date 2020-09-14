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
    var absorptionScheme: AbsorptionScheme
    @ObservedObject var foodItem: FoodItemViewModel
    @State private var showingSheet = false
    @State var activeSheet = ActiveFoodItemViewSheet.selectFoodItem
    
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

                Text(DataHelper.doubleFormatter(numberOfDigits: 2).string(from: NSNumber(value: foodItem.carbsPer100g))!).font(.caption).foregroundColor(.gray)
                Text("g Carbs").font(.caption).foregroundColor(.gray)
            }
        }
        .onTapGesture {
            if self.foodItem.amount > 0 {
                self.foodItem.amountAsString = "0"
                self.foodItem.cdFoodItem?.amount = 0
                try? AppDelegate.viewContext.save()
            } else {
                self.activeSheet = .selectFoodItem
                self.showingSheet = true
            }
        }
        .onLongPressGesture {
            // Edit food item
            self.activeSheet = .editFoodItem
            self.showingSheet = true
        }
        .sheet(isPresented: $showingSheet) {
            if self.foodItem.cdFoodItem != nil {
                FoodItemViewSheets(activeSheet: self.activeSheet, isPresented: self.$showingSheet, draftFoodItem: self.foodItem, editedFoodItem: self.foodItem.cdFoodItem!)
                    .environment(\.managedObjectContext, self.managedObjectContext)
            } else {
                Text(NSLocalizedString("Fatal error: Couldn't find CoreData FoodItem, please inform the app developer", comment: ""))
            }
        }
    }
}
