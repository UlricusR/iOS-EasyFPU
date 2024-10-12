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
    @State private var activeAlert: FoodItemViewSheets.AlertState?
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
                if foodItemVM.hasAssociatedRecipe() {
                    Image(systemName: "frying.pan.fill").foregroundStyle(.gray).imageScale(.small)
                }
                if foodItemVM.favorite {
                    Image(systemName: "star.fill").foregroundStyle(.yellow).imageScale(.small)
                }
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
        .swipeActions(edge: .trailing) {
            // Editing the food item
            Button("Edit", systemImage: "pencil") {
                if foodItemVM.cdFoodItem?.composedFoodItem != nil {
                    // There's an associated recipe, so show message to open Recipe Editor
                    activeAlert = .associatedRecipe
                } else {
                    activeSheet = .editFoodItem
                }
            }
            .tint(.blue)
            
            // Duplicating the food item
            Button("Duplicate", systemImage: "document.on.document") {
                foodItemVM.duplicate()
            }
            .tint(.indigo)
            
            // Delete the food item
            Button("Delete", systemImage: "trash", role: .destructive) {
                if let foodItemToBeDeleted = foodItemVM.cdFoodItem {
                    self.foodItemToBeDeleted = foodItemToBeDeleted
                    
                    // Check if FoodItem is related to an Ingredient
                    if !foodItemVM.canBeDeleted() {
                        self.activeAlert = .associatedIngredient
                    } else if foodItemToBeDeleted.composedFoodItem != nil {
                        self.actionSheetIsPresented.toggle()
                    } else {
                        self.activeAlert = .confirmDelete
                    }
                }
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            // Moving the food item to another category
            Button(NSLocalizedString("Move to \(foodItemVM.category == .product ? FoodItemCategory.ingredient.rawValue : FoodItemCategory.product.rawValue) List", comment: ""), systemImage: "rectangle.2.swap") {
                composedFoodItemVM.remove(foodItem: foodItemVM)
                foodItemVM.changeCategory(to: foodItemVM.category == .product ? .ingredient : .product)
            }
            .tint(.yellow)
            
            // Sharing the food item
            Button("Share", systemImage: "square.and.arrow.up") {
                activeSheet = .exportFoodItem
            }
            .tint(.green)
        }
        .sheet(item: $activeSheet) {
            sheetContent($0)
        }
        .alert(item: $activeAlert) {
            alertContent($0)
        }
        .actionSheet(isPresented: $actionSheetIsPresented) {
            ActionSheet(title: Text("Warning"), message: Text("There's an associated recipe, do you want to delete it as well?"), buttons: [
                .default(Text("Delete both")) {
                    if let foodItemToBeDeleted {
                        withAnimation(.default) {
                            ComposedFoodItem.delete(foodItemToBeDeleted.composedFoodItem!)
                            FoodItem.delete(foodItemToBeDeleted)
                        }
                    }
                },
                .default(Text("Keep recipe")) {
                    if let foodItemToBeDeleted {
                        withAnimation(.default) {
                            FoodItem.delete(foodItemToBeDeleted)
                        }
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
    
    private func alertContent(_ state: FoodItemViewSheets.AlertState) -> Alert {
        switch state {
        case .associatedRecipe:
            return Alert(
                title: Text("Edit food"),
                message: Text("This food item is created from a recipe, please open it in the recipe editor"),
                dismissButton: .default(Text("OK"))
            )
        case .confirmDelete:
            return Alert(
                title: Text("Delete food"),
                message: Text("Do you really want to delete this food item? This cannot be undone!"),
                primaryButton: .default(
                    Text("Do not delete")
                ),
                secondaryButton: .destructive(
                    Text("Delete"),
                    action: deleteFoodItem
                )
            )
        case .associatedIngredient:
            return Alert(
                title: Text("Cannot delete food"),
                message: Text("This food item is in use in a recipe, please remove it from the recipe before deleting.")
            )
        }
    }
    
    private func deleteFoodItem() {
        if let foodItemToBeDeleted {
            withAnimation(.default) {
                FoodItem.delete(foodItemToBeDeleted)
            }
        }
    }
}
