//
//  FoodItemListView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 01.11.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct FoodItemListView: View {
    enum FoodListNavigationDestination: Hashable {
        case AddFoodItem(category: FoodItemCategory)
        case EditFoodItem(category: FoodItemCategory, foodItemVM: FoodItemViewModel)
        case SelectFoodItem(category: FoodItemCategory, draftFoodItem: FoodItemViewModel, composedFoodItem: ComposedFoodItemViewModel)
    }
    
    @Binding var navigationPath: NavigationPath
    @ObservedObject var foodListVM: FoodListViewModel
    @ObservedObject var userSettings = UserSettings.shared
    @ObservedObject var composedFoodItem: ComposedFoodItemViewModel
    
    @State private var activeSheet: FoodListViewModel.SheetState?
    
    private var emptyStateImage: Image {
        switch foodListVM.category {
        case .product:
            Image("nachos")
        case .ingredient:
            Image("eggs-color")
        }
    }
    private var emptyStateMessage: Text {
        switch foodListVM.category {
        case .product:
            Text("Oops! There are no dishes in your list yet. Start by adding some!")
        case .ingredient:
            Text("Oops! There are no ingredients in your list yet. Start by adding some!")
        }
    }
    private var emptyStateButtonText: Text {
        switch foodListVM.category {
        case .product:
            Text("Add products")
        case .ingredient:
            Text("Add ingredients")
        }
    }
    
    var body: some View {
        VStack {
            if foodListVM.foodItems.isEmpty {
                // List is empty, so show a nice picture and an action button
                emptyStateImage.padding()
                emptyStateMessage.padding()
                Button {
                    // Add new food item
                    navigationPath.append(FoodItemListView.FoodListNavigationDestination.AddFoodItem(category: foodListVM.category))
                } label: {
                    HStack {
                        Image(systemName: "plus.circle").imageScale(.large).foregroundStyle(.green)
                        emptyStateButtonText
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(ActionButton())
                .padding()
                .accessibilityIdentifierLeaf("AddFoodItemButton")
            } else {
                ZStack {
                    // The food list
                    List(foodListVM.filteredFoodItems.sorted {
                        if foodListVM.listType == .selection {
                            if composedFoodItem.foodItemVMs.contains($0) && !composedFoodItem.foodItemVMs.contains($1) {
                                return true
                            } else if !composedFoodItem.foodItemVMs.contains($0) && composedFoodItem.foodItemVMs.contains($1) {
                                return false
                            } else {
                                return $0.name < $1.name
                            }
                        } else {
                            return $0.name < $1.name
                        }
                    }) { foodItem in
                        FoodItemView(navigationPath: $navigationPath, composedFoodItemVM: composedFoodItem, foodItemVM: foodItem, category: foodListVM.category, listType: foodListVM.listType)
                            .accessibilityIdentifierBranch(String(foodItem.name.prefix(10)))
                    }
                    .safeAreaPadding(EdgeInsets(top: 0, leading: 0, bottom: foodListVM.listType == .selection ? ActionButton.safeButtonSpace : 0, trailing: 0)) // Required to avoid the content to be hidden by the Finished button
                    
                    // The overlaying finished button in case we have a selection type list
                    if foodListVM.listType == .selection {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Button {
                                    // Return to previous view
                                    navigationPath.removeLast()
                                } label: {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill").imageScale(.large).foregroundStyle(.green)
                                        Text("Finished")
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(ActionButton())
                                .accessibilityIdentifierLeaf("FinishedButton")
                                Spacer()
                            }
                            .padding()
                        }
                    }
                }
            }
        }
        .navigationTitle(foodListVM.foodItemListTitle)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button(action: {
                    withAnimation {
                        self.activeSheet = foodListVM.helpSheet
                    }
                }) {
                    Image(systemName: "questionmark.circle")
                        .imageScale(.large)
                }
                .accessibilityIdentifierLeaf("HelpButton")
                
                Button(action: {
                    // Add new food item
                    navigationPath.append(FoodItemListView.FoodListNavigationDestination.AddFoodItem(category: foodListVM.category))
                }) {
                    Image(systemName: "plus.circle")
                        .imageScale(.large)
                        .foregroundStyle(.green)
                }
                .accessibilityIdentifierLeaf("AddFoodItemButton")
            }
            
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                // The grouping button
                Button(action: {
                    withAnimation {
                        var errorMessage = ""
                        if foodListVM.category == .product {
                            self.userSettings.groupProductsByCategory.toggle()
                            _ = UserSettings.set(UserSettings.UserDefaultsType.bool(userSettings.groupProductsByCategory, UserSettings.UserDefaultsBoolKey.groupProductsByCategory), errorMessage: &errorMessage)
                        } else if foodListVM.category == .ingredient {
                            self.userSettings.groupIngredientsByCategory.toggle()
                            _ = UserSettings.set(UserSettings.UserDefaultsType.bool(userSettings.groupIngredientsByCategory, UserSettings.UserDefaultsBoolKey.groupIngredientsByCategory), errorMessage: &errorMessage)
                        }
                    }
                }) {
                    if foodListVM.category == .product && self.userSettings.groupProductsByCategory ||
                        foodListVM.category == .ingredient && self.userSettings.groupIngredientsByCategory {
                        Image(systemName: "square.grid.3x1.below.line.grid.1x2.fill")
                            .foregroundStyle(Color.blue)
                            .imageScale(.large)
                    } else {
                        Image(systemName: "square.grid.3x1.below.line.grid.1x2")
                            .foregroundStyle(Color.blue)
                            .imageScale(.large)
                    }
                }
                
                // The favorite button
                Button(action: {
                    withAnimation {
                        foodListVM.showFavoritesOnly.toggle()
                    }
                }) {
                    if foodListVM.showFavoritesOnly {
                        Image(systemName: "star.fill")
                            .foregroundStyle(Color.yellow)
                            .imageScale(.large)
                    } else {
                        Image(systemName: "star")
                            .foregroundStyle(Color.blue)
                            .imageScale(.large)
                    }
                }
                .accessibilityIdentifierLeaf("FavoriteButton")
            }
        }
        .searchable(text: $foodListVM.searchString)
        .sheet(item: $activeSheet) {
            sheetContent($0)
        }
    }
    
    @ViewBuilder
    private func sheetContent(_ state: FoodListViewModel.SheetState) -> some View {
        switch state {
        case .productMaintenanceListHelp:
            HelpView(helpScreen: .productMaintenanceList)
                .accessibilityIdentifierBranch("HelpProductMaintenanceList")
        case .productSelectionListHelp:
            HelpView(helpScreen: .productSelectionList)
                .accessibilityIdentifierBranch("HelpProductSelectionList")
        case .ingredientMaintenanceListHelp:
            HelpView(helpScreen: .ingredientMaintenanceList)
                .accessibilityIdentifierBranch("HelpIngredientMaintenanceList")
        case .ingredientSelectionListHelp:
            HelpView(helpScreen: .ingredientSelectionList)
                .accessibilityIdentifierBranch("HelpIngredientSelectionList")
        }
    }
}

struct FoodItemListView_Previews: PreviewProvider {
    @State private static var navigationPath = NavigationPath()
    static var previews: some View {
        let foodListVM = FoodListViewModel(
            category: .product,
            listType: .selection,
            foodItemListTitle: "My Products",
            helpSheet: .productSelectionListHelp
        )
        FoodItemListView(
            navigationPath: $navigationPath,
            foodListVM: foodListVM,
            composedFoodItem: ComposedFoodItemViewModel.sampleData()
        )
    }
}
