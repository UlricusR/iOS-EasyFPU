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
    @ObservedObject var composedFoodItemVM: ComposedFoodItemViewModel
    @ObservedObject var foodItemVM: FoodItemViewModel
    var category: FoodItemCategory
    @Binding var selectedTab: Int
    @State var activeSheet: FoodItemViewSheets.State?
    
    var body: some View {
        VStack {
            // First line: amount, name, favorite
            HStack {
                if let foodItemIndex = composedFoodItemVM.foodItems.firstIndex(of: foodItemVM) {
                    Image(systemName: "xmark.circle").foregroundColor(.red)
                    Text("\(composedFoodItemVM.foodItems[foodItemIndex].amount)").font(.headline).foregroundColor(.accentColor)
                    Text("g").font(.headline).foregroundColor(.accentColor)
                } else {
                    Image(systemName: "plus.circle").foregroundColor(.green)
                }
                Text(foodItemVM.name).font(.headline).foregroundColor(composedFoodItemVM.foodItems.contains(foodItemVM) ? .accentColor : .none)
                if foodItemVM.favorite { Image(systemName: "star.fill").foregroundColor(.yellow).imageScale(.small) }
                Spacer()
            }
            
            // Second line: Nutritional values per 100g
            HStack {
                Text("Nutritional values per 100g:").font(.caption).foregroundColor(.gray)

                Spacer()

                Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: foodItemVM.caloriesPer100g))!).font(.caption).foregroundColor(.gray)
                Text("kcal").font(.caption).foregroundColor(.gray)

                Text("|").foregroundColor(.gray)

                VStack(alignment: .leading) {
                    HStack {
                        Text(DataHelper.doubleFormatter(numberOfDigits: 2).string(from: NSNumber(value: foodItemVM.carbsPer100g))!).font(.caption).foregroundColor(.gray)
                        Text("g Carbs").font(.caption).foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Thereof").font(.caption).foregroundColor(.gray)
                        Text(DataHelper.doubleFormatter(numberOfDigits: 2).string(from: NSNumber(value: foodItemVM.sugarsPer100g))!).font(.caption).foregroundColor(.gray)
                        Text("g Sugars").font(.caption).foregroundColor(.gray)
                    }
                }
            }
        }
        .onTapGesture {
            if composedFoodItemVM.foodItems.contains(foodItemVM) {
                composedFoodItemVM.remove(foodItem: foodItemVM)
            } else {
                activeSheet = .selectFoodItem
            }
        }
        .contextMenu(menuItems: {
            // Editing the food item
            Button(action: {
                if foodItemVM.composedFoodItemVM == nil { // This is a regular FoodItem, so open FoodItemEditor
                    activeSheet = .editFoodItem
                } else { // This is a ComposedFoodItem
                    // Prepare the composed product by filling it with the selected ComposedFoodItem
                    UserSettings.shared.composedProduct = foodItemVM.composedFoodItemVM!
                    
                    // Switch to Ingredients tab
                    selectedTab = MainView.Tab.ingredients.rawValue
                }
            }) {
                Text("Edit")
            }
            
            // Duplicating the food item
            Button(action: {
                foodItemVM.duplicate()
            }) {
                Text("Duplicate")
            }
            
            // Sharing the food item
            Button(action: {
                activeSheet = .exportFoodItem
            }) {
                Text("Share")
            }
            
            // Moving the food item to another category
            Button(action: {
                composedFoodItemVM.remove(foodItem: foodItemVM)
                foodItemVM.changeCategory(to: foodItemVM.category == .product ? .ingredient : .product)
            }) {
                Text(NSLocalizedString("Move to \(foodItemVM.category == .product ? FoodItemCategory.ingredient.rawValue : FoodItemCategory.product.rawValue) List", comment: ""))
            }.disabled(!foodItemVM.canChangeCategory())
            
            // Delete the food item
            Button(action: {
                if let foodItemToBeDeleted = foodItemVM.cdFoodItem {
                    FoodItem.delete(foodItemToBeDeleted)
                }
            }) {
                Text("Delete")
            }.disabled(!foodItemVM.canBeDeleted())
        })
        .sheet(item: $activeSheet) {
            sheetContent($0)
        }
    }
    
    @ViewBuilder
    private func sheetContent(_ state: FoodItemViewSheets.State) -> some View {
        switch state {
        case .editFoodItem:
            if self.foodItemVM.cdFoodItem != nil {
                FoodItemEditor(
                    navigationBarTitle: NSLocalizedString("Edit food item", comment: ""),
                    draftFoodItemVM: self.foodItemVM,
                    editedFoodItem: self.foodItemVM.cdFoodItem!,
                    category: category
                ).environment(\.managedObjectContext, managedObjectContext)
            } else {
                Text(NSLocalizedString("Fatal error: Couldn't find CoreData FoodItem, please inform the app developer", comment: ""))
            }
        case .selectFoodItem:
            FoodItemSelector(draftFoodItem: self.foodItemVM, editedFoodItem: self.foodItemVM.cdFoodItem!, composedFoodItem: composedFoodItemVM, category: self.category)
        case .exportFoodItem:
            if let path = foodItemVM.exportToURL() {
                ActivityView(activityItems: [path], applicationActivities: nil)
            } else {
                Text(NSLocalizedString("Could not generate data export", comment: ""))
            }
        }
    }
}
