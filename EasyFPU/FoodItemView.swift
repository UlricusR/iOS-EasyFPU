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
    @ObservedObject var sheet = FoodItemViewSheets()
    
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
                self.foodItem.amountAsString = "0"
                self.foodItem.cdFoodItem?.amount = 0
                try? AppDelegate.viewContext.save()
            } else {
                self.sheet.state = .selectFoodItem
            }
        }
        .onLongPressGesture {
            // Edit food item
            self.sheet.state = .editFoodItem
        }
        .sheet(isPresented: $sheet.isShowing, content: sheetContent)
    }
    
    @ViewBuilder
    private func sheetContent() -> some View {
        if sheet.state != nil {
            switch sheet.state! {
            case .editFoodItem:
                if self.foodItem.cdFoodItem != nil {
                    FoodItemEditor(
                        isPresented: $sheet.isShowing,
                        navigationBarTitle: NSLocalizedString("Edit food item", comment: ""),
                        draftFoodItem: self.foodItem,
                        editedFoodItem: self.foodItem.cdFoodItem!
                    ).environment(\.managedObjectContext, managedObjectContext)
                } else {
                    Text(NSLocalizedString("Fatal error: Couldn't find CoreData FoodItem, please inform the app developer", comment: ""))
                }
            case .selectFoodItem:
                FoodItemSelector(isPresented: $sheet.isShowing, draftFoodItem: self.foodItem, editedFoodItem: self.foodItem.cdFoodItem!)
            }
        } else {
            EmptyView()
        }
    }
}
