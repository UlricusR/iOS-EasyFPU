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
    @ObservedObject var composedFoodItem: ComposedFoodItemViewModel
    @ObservedObject var foodItem: FoodItemViewModel
    var category: FoodItemCategory
    @Binding var selectedTab: Int
    @Binding var editedComposedFoodItem: ComposedFoodItem?
    @State var activeSheet: FoodItemViewSheets.State?
    @State var showingActionSheet: Bool = false
    @State var loadedIngredients = [Ingredient]()
    @State var missingFoodItems = [String]()
    
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
        .contextMenu(menuItems: {
            // Editing the food item
            Button(action: {
                if foodItem.cdComposedFoodItem == nil { // This is a regular FoodItem, so open FoodItemEditor
                    activeSheet = .editFoodItem
                } else { // This is a ComposedFoodItem
                    editComposedFoodItem(foodItem.cdComposedFoodItem!)
                }
            }) {
                Text("Edit")
            }
            
            // Duplicating the food item
            Button(action: {
                foodItem.duplicate()
            }) {
                Text("Duplicate")
            }
            
            // TODO: Sharing the food item
            /*Button(action: {
                
            }) {
                Text("Share")
            }*/
            
            // Moving the food item to another category
            Button(action: {
                composedFoodItem.remove(foodItem: foodItem)
                foodItem.changeCategory(to: foodItem.category == .product ? .ingredient : .product)
            }) {
                Text(NSLocalizedString("Move to \(foodItem.category == .product ? FoodItemCategory.ingredient.rawValue : FoodItemCategory.product.rawValue) List", comment: ""))
            }
            
            // Delete the food item
            Button(action: {
                if let foodItemToBeDeleted = foodItem.cdFoodItem {
                    FoodItem.delete(foodItemToBeDeleted)
                }
            }) {
                Text("Delete")
            }
        })
        .sheet(item: $activeSheet) {
            sheetContent($0)
        }
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(
                title: Text("Missing Ingredients"),
                message: Text(
                    NSLocalizedString("The following ingredients are no longer available: ", comment: "") +
                        missingFoodItems.joined(separator: ", ") +
                    NSLocalizedString(". Do you want to create them or remove them from your product?", comment: "")
                ),
                buttons: [
                    .default(Text("Create missing ingredients")) {
                        FoodItem.setFoodItems(from: loadedIngredients, syncStrategy: FoodItem.IngredientsSyncStrategy.createMissingFoodItems)
                    },
                    .default(Text("Remove from product")) {
                        FoodItem.setFoodItems(from: loadedIngredients, syncStrategy: FoodItem.IngredientsSyncStrategy.removeNonExistingIngredients)
                    }
                ]
            )
        }
    }
    
    private func editComposedFoodItem(_ composedFoodItem: ComposedFoodItem) {
        editedComposedFoodItem = composedFoodItem
        
        // Switch to Ingredients tab
        selectedTab = MainView.Tab.ingredients.rawValue
        
        // Load ingredients
        if let ingredients = composedFoodItem.ingredients {
            loadedIngredients = ingredients.allObjects as! [Ingredient]
            
            // Check for missing ingredients
            let missingFoodItems = FoodItem.checkForMissingFoodItems(of: loadedIngredients)
            if missingFoodItems.isEmpty {
                FoodItem.setFoodItems(from: loadedIngredients, syncStrategy: .createMissingFoodItems)
            } else {
                self.missingFoodItems = [String]()
                for missingFoodItem in missingFoodItems {
                    self.missingFoodItems.append(missingFoodItem.name ?? NSLocalizedString("- Unnamed -", comment: ""))
                }
                showingActionSheet = true
            }
        } else {
            // TODO Notification
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
            FoodItemSelector(draftFoodItem: self.foodItem, editedFoodItem: self.foodItem.cdFoodItem!, composedFoodItem: composedFoodItem)
        }
    }
}
