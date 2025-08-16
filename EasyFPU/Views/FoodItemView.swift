//
//  FoodItemView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 13.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers

struct FoodItemView: View {
    enum AlertChoice {
        case simpleAlert(type: SimpleAlertType)
        case confirmDelete
    }
    
    @Binding var navigationPath: NavigationPath
    @ObservedObject var composedFoodItemVM: ComposedFoodItemViewModel
    @ObservedObject var foodItemVM: FoodItemViewModel
    var category: FoodItemCategory
    var listType: FoodItemListView.FoodItemListType
    @State private var showingAlert = false
    @State private var activeAlert: AlertChoice?
    @State private var isConfirming = false
    
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
                        navigationPath.append(FoodItemListView.FoodListNavigationDestination.SelectFoodItem(category: category, draftFoodItem: foodItemVM, composedFoodItem: composedFoodItemVM))
                    }
                }
            }
        }
        .swipeActions(edge: .trailing) {
            // Editing the food item
            Button("Edit", systemImage: "pencil") {
                if foodItemVM.cdFoodItem?.composedFoodItem != nil {
                    // There's an associated recipe, so show message to open Recipe Editor
                    activeAlert = .simpleAlert(type: .notice(message: "This food item is created from a recipe, please open it in the recipe editor"))
                    showingAlert = true
                } else {
                    navigationPath.append(FoodItemListView.FoodListNavigationDestination.EditFoodItem(category: category, foodItemVM: foodItemVM))
                }
            }
            .tint(.blue)
            .accessibilityIdentifierLeaf("EditButton")
            
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
                    if let associatedRecipeNames = foodItemVM.getAssociatedRecipeNames() {
                        // There are associated recipes
                        activeAlert = .simpleAlert(type: .notice(message: createWarningMessage(from: associatedRecipeNames)))
                        showingAlert = true
                    } else if foodItemVM.hasAssociatedRecipe() {
                        self.isConfirming.toggle()
                    } else {
                        self.activeAlert = .confirmDelete
                        self.showingAlert = true
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
            ShareLink(item: DataWrapper(dataModelVersion: .version2, foodItemVMs: [foodItemVM], composedFoodItemVMs: []), preview: .init("Share"))
            .tint(.green)
            .accessibilityIdentifierLeaf("ShareButton")
        }
        .alert(alertTitle, isPresented: $showingAlert, presenting: activeAlert) {
            alertAction(for: $0)
        } message: {
            alertMessage(for: $0)
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
    private func alertMessage(for alert: AlertChoice) -> some View {
        switch alert {
        case let .simpleAlert(type: type):
            type.message()
        case .confirmDelete:
            Text("Do you really want to delete this food item? This cannot be undone!")
        }
    }

    @ViewBuilder
    private func alertAction(for alert: AlertChoice) -> some View {
        switch alert {
        case let .simpleAlert(type: type):
            type.button()
        case .confirmDelete:
            Button("Do not delete", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteFoodItemOnly()
            }
        }
    }
    
    private var alertTitle: LocalizedStringKey {
        switch activeAlert {
        case let .simpleAlert(type: type):
            LocalizedStringKey(type.title())
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
    
    private func createWarningMessage(from associatedRecipeNames: [String]) -> String {
        NSLocalizedString("This food item is in use in a recipe", comment: "") + associatedRecipeNames.joined(separator: ", ")
    }
}
