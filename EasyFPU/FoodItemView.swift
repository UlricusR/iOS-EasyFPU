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
    var listType: FoodItemListView.FoodItemListType
    @State private var activeSheet: FoodItemViewSheets.State?
    @State private var showingAlert: Bool = false
    @State private var actionSheetIsPresented: Bool = false
    @State private var foodItemToBeDeleted: FoodItem?
    
    var body: some View {
        VStack {
            // First line: amount, name, favorite
            HStack {
                if listType == .selection {
                    if let foodItemIndex = composedFoodItemVM.foodItems.firstIndex(of: foodItemVM) {
                        Image(systemName: "xmark.circle").foregroundStyle(.red)
                        Text("\(composedFoodItemVM.foodItems[foodItemIndex].amount)").font(.headline).foregroundStyle(.blue)
                        Text("g").font(.headline).foregroundStyle(.blue)
                    } else {
                        Image(systemName: "plus.circle").foregroundStyle(.gray)
                    }
                }
                Text(foodItemVM.name).font(.headline).foregroundStyle(listType == .selection && composedFoodItemVM.foodItems.contains(foodItemVM) ? .blue : .primary)
                if foodItemVM.favorite { Image(systemName: "star.fill").foregroundStyle(.yellow).imageScale(.small) }
                Spacer()
            }
            
            // Second line: Nutritional values per 100g
            HStack {
                Text("Nutritional values per 100g:").font(.caption).foregroundStyle(.gray)

                Spacer()

                Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: foodItemVM.caloriesPer100g))!).font(.caption).foregroundStyle(.gray)
                Text("kcal").font(.caption).foregroundStyle(.gray)

                Text("|").foregroundStyle(.gray)

                VStack(alignment: .leading) {
                    HStack {
                        Text(DataHelper.doubleFormatter(numberOfDigits: 2).string(from: NSNumber(value: foodItemVM.carbsPer100g))!).font(.caption).foregroundStyle(.gray)
                        Text("g Carbs").font(.caption).foregroundStyle(.gray)
                    }
                    
                    HStack {
                        Text("Thereof").font(.caption).foregroundStyle(.gray)
                        Text(DataHelper.doubleFormatter(numberOfDigits: 2).string(from: NSNumber(value: foodItemVM.sugarsPer100g))!).font(.caption).foregroundStyle(.gray)
                        Text("g Sugars").font(.caption).foregroundStyle(.gray)
                    }
                }
            }
        }
        .onTapGesture {
            withAnimation(.default) {
                if listType == .selection {
                    if composedFoodItemVM.foodItems.contains(foodItemVM) {
                        composedFoodItemVM.remove(foodItem: foodItemVM)
                    } else {
                        activeSheet = .selectFoodItem
                    }
                }
            }
        }
        .contextMenu(menuItems: {
            if listType == .maintenance {
                // Editing the food item
                Button(action: {
                    if foodItemVM.cdFoodItem?.composedFoodItem != nil {
                        // There's an associated recipe, so show message to open Recipe Editor
                        showingAlert = true
                    } else {
                        activeSheet = .editFoodItem
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
                        // Check for associated recipe
                        if foodItemToBeDeleted.composedFoodItem != nil {
                            self.foodItemToBeDeleted = foodItemToBeDeleted
                            self.actionSheetIsPresented.toggle()
                        } else {
                            FoodItem.delete(foodItemToBeDeleted)
                        }
                    }
                }) {
                    Text("Delete")
                }.disabled(!foodItemVM.canBeDeleted())
            }
        })
        .sheet(item: $activeSheet) {
            sheetContent($0)
        }
        .alert(NSLocalizedString("This product is created from a recipe, please open it in the recipe editor", comment: ""), isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        }
        .actionSheet(isPresented: $actionSheetIsPresented) {
            ActionSheet(title: Text("Warning"), message: Text("There's an associated recipe, do you want to delete it as well?"), buttons: [
                .default(Text("Delete both")) {
                    if let foodItemToBeDeleted {
                        ComposedFoodItem.delete(foodItemToBeDeleted.composedFoodItem!)
                        FoodItem.delete(foodItemToBeDeleted)
                    }
                },
                .default(Text("Keep recipe")) {
                    if let foodItemToBeDeleted {
                        FoodItem.delete(foodItemToBeDeleted)
                    }
                },
                .cancel()
            ])
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
