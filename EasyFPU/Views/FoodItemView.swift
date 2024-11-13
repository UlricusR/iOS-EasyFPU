//
//  FoodItemView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 13.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct FoodItemView: View {
    enum SheetState: Identifiable {
        case editFoodItem
        case selectFoodItem
        case exportFoodItem
        
        var id: SheetState { self }
    }
    
    enum DeleteAlertChoice {
        case associatedIngredient
        case confirmDelete
    }
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var composedFoodItemVM: ComposedFoodItemViewModel
    @ObservedObject var foodItemVM: FoodItemViewModel
    var category: FoodItemCategory
    var listType: FoodItemListView.FoodItemListType
    @State private var activeSheet: SheetState?
    @State private var showingDeleteAlert = false
    @State private var activeDeleteAlert: DeleteAlertChoice?
    @State private var isConfirming = false
    @State private var showingNoEditAlert = false
    
    var body: some View {
        VStack {
            // First line: amount, name, favorite
            HStack {
                if listType == .selection {
                    if let foodItemIndex = composedFoodItemVM.foodItemVMs.firstIndex(of: foodItemVM) {
                        Image(systemName: "xmark.circle")
                            .foregroundStyle(.red)
                            .accessibilityIdentifierLeaf("DeselectFoodItemButton")
                        Text("\(composedFoodItemVM.foodItemVMs[foodItemIndex].amount)").font(.headline).foregroundStyle(.blue)
                        Text("g").font(.headline).foregroundStyle(.blue)
                    } else {
                        Image(systemName: "plus.circle")
                            .foregroundStyle(.gray)
                            .accessibilityIdentifierLeaf("SelectFoodItemButton")
                    }
                }
                Text(foodItemVM.name)
                    .font(.headline)
                    .foregroundStyle(listType == .selection && composedFoodItemVM.foodItemVMs.contains(foodItemVM) ? .blue : .primary)
                    .accessibilityIdentifierLeaf("FoodItemNameLabel")
                if foodItemVM.hasAssociatedRecipe() {
                    Image(systemName: "frying.pan.fill").foregroundStyle(.gray).imageScale(.small)
                        .accessibilityIdentifierLeaf("HasAssociatedRecipeSymbol")
                }
                if foodItemVM.favorite {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .imageScale(.small)
                        .accessibilityIdentifierLeaf("IsFavoriteSymbol")
                }
                Spacer()
            }
            
            // Second line: Nutritional values per 100g
            HStack {
                Text("Nutritional values per 100g:")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .accessibilityIdentifierLeaf("HeadingNutritionalValues")

                Spacer()

                Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: foodItemVM.caloriesPer100g))!)
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .accessibilityIdentifierLeaf("CaloriesValue")
                Text("kcal")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .accessibilityIdentifierLeaf("CaloriesUnit")

                Text("|").foregroundStyle(.gray)

                VStack(alignment: .leading) {
                    HStack {
                        Text(DataHelper.doubleFormatter(numberOfDigits: 2).string(from: NSNumber(value: foodItemVM.carbsPer100g))!)
                            .font(.caption)
                            .foregroundStyle(.gray)
                            .accessibilityIdentifierLeaf("CarbsValue")
                        Text("g Carbs")
                            .font(.caption)
                            .foregroundStyle(.gray)
                            .accessibilityIdentifierLeaf("CarbsUnit")
                    }
                    
                    HStack {
                        Text("Thereof").font(.caption).foregroundStyle(.gray)
                        Text(DataHelper.doubleFormatter(numberOfDigits: 2).string(from: NSNumber(value: foodItemVM.sugarsPer100g))!)
                            .font(.caption)
                            .foregroundStyle(.gray)
                            .accessibilityIdentifierLeaf("SugarsValue")
                        Text("g Sugars")
                            .font(.caption)
                            .foregroundStyle(.gray)
                            .accessibilityIdentifierLeaf("SugarsUnit")
                    }
                }
            }
        }
        .onTapGesture {
            withAnimation(.default) {
                if listType == .selection {
                    if composedFoodItemVM.foodItemVMs.contains(foodItemVM) {
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
                    showingNoEditAlert = true
                } else {
                    activeSheet = .editFoodItem
                }
            }
            .tint(.blue)
            .accessibilityIdentifierLeaf("EditButton")
            .alert(
                "Edit food",
                isPresented: $showingNoEditAlert,
                actions: {},
                message: { Text("This food item is created from a recipe, please open it in the recipe editor") }
            )
            
            
            // Duplicating the food item
            Button("Duplicate", systemImage: "document.on.document") {
                foodItemVM.duplicate()
            }
            .tint(.indigo)
            .accessibilityIdentifierLeaf("DuplicateButton")
            
            // Delete the food item
            Button("Delete", systemImage: "trash") {
                if foodItemVM.hasAssociatedFoodItem() {
                    // Check if FoodItem is related to an Ingredient
                    if !foodItemVM.canBeDeleted() {
                        self.activeDeleteAlert = .associatedIngredient
                        self.showingDeleteAlert = true
                    } else if foodItemVM.hasAssociatedRecipe() {
                        self.isConfirming.toggle()
                    } else {
                        self.activeDeleteAlert = .confirmDelete
                        self.showingDeleteAlert = true
                    }
                }
            }
            .tint(.red)
            .accessibilityIdentifierLeaf("DeleteButton")
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            // Moving the food item to another category
            Button(NSLocalizedString("Move to \(foodItemVM.category == .product ? FoodItemCategory.ingredient.rawValue : FoodItemCategory.product.rawValue) List", comment: ""), systemImage: "rectangle.2.swap") {
                composedFoodItemVM.remove(foodItem: foodItemVM)
                foodItemVM.changeCategory(to: foodItemVM.category == .product ? .ingredient : .product)
            }
            .tint(.yellow)
            .accessibilityIdentifierLeaf("MoveButton")
            
            // Sharing the food item
            Button("Share", systemImage: "square.and.arrow.up") {
                activeSheet = .exportFoodItem
            }
            .tint(.green)
            .accessibilityIdentifierLeaf("ShareButton")
        }
        .sheet(item: $activeSheet) {
            sheetContent($0)
        }
        .alert(deleteAlertTitle, isPresented: $showingDeleteAlert, presenting: activeDeleteAlert) {
            deleteAlertActions(for: $0)
        } message: {
            deleteAlertMessage(for: $0)
        }
        .confirmationDialog(
            "Warning",
            isPresented: $isConfirming
        ) {
            Button("Delete both") {
                deleteFoodItemAndComposedFoodItem()
            }
            Button("Keep recipe") {
                deleteFoodItemOnly()
            }
            Button("Cancel", role: .cancel) {
                isConfirming.toggle()
            }
        } message: {
            Text("There's an associated recipe, do you want to delete it as well?")
        }
    }
    
    @ViewBuilder
    private func sheetContent(_ state: SheetState) -> some View {
        switch state {
        case .editFoodItem:
            if self.foodItemVM.cdFoodItem != nil {
                FoodItemEditor(
                    navigationBarTitle: NSLocalizedString("Edit food item", comment: ""),
                    draftFoodItemVM: self.foodItemVM,
                    category: category
                )
                .environment(\.managedObjectContext, managedObjectContext)
                .accessibilityIdentifierBranch("EditFoodItem")
            } else {
                Text(NSLocalizedString("Fatal error: Couldn't find CoreData FoodItem, please inform the app developer", comment: ""))
            }
        case .selectFoodItem:
            FoodItemSelector(draftFoodItem: self.foodItemVM, composedFoodItem: composedFoodItemVM, category: self.category)
                .accessibilityIdentifierBranch("SelectFoodItems")
        case .exportFoodItem:
            if let path = foodItemVM.exportToURL() {
                ActivityView(activityItems: [path], applicationActivities: nil)
                    .accessibilityIdentifierBranch("ExportFoodItem")
            } else {
                Text(NSLocalizedString("Could not generate data export", comment: ""))
            }
        }
    }
    
    @ViewBuilder
    private func deleteAlertMessage(for alert: DeleteAlertChoice) -> some View {
        switch alert {
        case .associatedIngredient:
            Text("This food item is in use in a recipe, please remove it from the recipe before deleting.")
        case .confirmDelete:
            Text("Do you really want to delete this food item? This cannot be undone!")
        }
    }
    
    @ViewBuilder
    private func deleteAlertActions(for alert: DeleteAlertChoice) -> some View {
        switch alert {
        case .associatedIngredient:
            Button("OK", role: .cancel) {}
        case .confirmDelete:
            Button("Do not delete", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteFoodItemOnly()
            }
        }
    }
    
    private var deleteAlertTitle: LocalizedStringKey {
        switch activeDeleteAlert {
        case .associatedIngredient:
            LocalizedStringKey("Cannot delete food")
        case .confirmDelete:
            LocalizedStringKey("Delete food")
        case nil:
            ""
        }
    }
    
    private func deleteFoodItemOnly() {
        withAnimation(.default) {
            foodItemVM.delete(includeAssociatedRecipe: false)
        }
    }
    
    private func deleteFoodItemAndComposedFoodItem() {
        withAnimation(.default) {
            foodItemVM.delete(includeAssociatedRecipe: true)
        }
    }
}
