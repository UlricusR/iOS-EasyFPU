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
    
    enum FoodItemListType {
        case maintenance
        case selection
    }
    
    enum SheetState: Identifiable {
        case productSelectionListHelp
        case productMaintenanceListHelp
        case ingredientSelectionListHelp
        case ingredientMaintenanceListHelp
        
        var id: SheetState { self }
    }
    
    @Environment(\.managedObjectContext) var managedObjectContext
    var category: FoodItemCategory
    var listType: FoodItemListType
    var foodItemListTitle: String
    var helpSheet: SheetState
    @Binding var navigationPath: NavigationPath
    @ObservedObject var composedFoodItem: ComposedFoodItemViewModel
    
    @State private var searchString = ""
    @State private var showFavoritesOnly = false
    @State private var activeSheet: SheetState?
    
    private var emptyStateImage: Image {
        switch category {
        case .product:
            Image("nachos")
        case .ingredient:
            Image("eggs-color")
        }
    }
    private var emptyStateMessage: Text {
        switch category {
        case .product:
            Text("Oops! There are no dishes in your list yet. Start by adding some!")
        case .ingredient:
            Text("Oops! There are no ingredients in your list yet. Start by adding some!")
        }
    }
    private var emptyStateButtonText: Text {
        switch category {
        case .product:
            Text("Add products")
        case .ingredient:
            Text("Add ingredients")
        }
    }
    
    @FetchRequest(
        entity: FoodItem.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \FoodItem.name, ascending: true)
        ]
    ) var foodItems: FetchedResults<FoodItem>
    
    private var filteredFoodItems: [FoodItemViewModel] {
        if searchString == "" {
            return showFavoritesOnly ?
            foodItems.map { FoodItemViewModel(from: $0) } .filter { $0.category == self.category && $0.favorite } :
            foodItems.map { FoodItemViewModel(from: $0) } .filter { $0.category == self.category }
        } else {
            return showFavoritesOnly ?
            foodItems.map { FoodItemViewModel(from: $0) } .filter { $0.category == self.category && $0.favorite && $0.name.lowercased().contains(searchString.lowercased()) } :
            foodItems.map { FoodItemViewModel(from: $0) } .filter { $0.category == self.category && $0.name.lowercased().contains(searchString.lowercased()) }
        }
    }
    
    var body: some View {
        VStack {
            if foodItems.isEmpty {
                // List is empty, so show a nice picture and an action button
                emptyStateImage.padding()
                emptyStateMessage.padding()
                Button {
                    // Add new food item
                    navigationPath.append(FoodItemListView.FoodListNavigationDestination.AddFoodItem(category: category))
                } label: {
                    HStack {
                        Image(systemName: "plus.circle").imageScale(.large).foregroundStyle(.green)
                        emptyStateButtonText
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(.yellow)
                    )
                }
                .accessibilityIdentifierLeaf("AddFoodItemButton")
            } else {
                ZStack {
                    // The food list
                    List(self.filteredFoodItems.sorted {
                        if listType == .selection {
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
                        FoodItemView(navigationPath: $navigationPath, composedFoodItemVM: composedFoodItem, foodItemVM: foodItem, category: self.category, listType: listType)
                            .environment(\.managedObjectContext, self.managedObjectContext)
                            .accessibilityIdentifierBranch(String(foodItem.name.prefix(10)))
                    }
                    .safeAreaPadding(EdgeInsets(top: 0, leading: 0, bottom: listType == .selection ? 70 : 0, trailing: 0)) // Required to avoid the content to be hidden by the Finished button
                    
                    // The overlaying finished button in case we have a selection type list
                    if listType == .selection {
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
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                                            .fill(.yellow)
                                    )
                                }
                                .accessibilityIdentifierLeaf("FinishedButton")
                                Spacer()
                            }
                            .padding()
                        }
                    }
                }
            }
        }
        .navigationTitle(foodItemListTitle)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button(action: {
                    withAnimation {
                        self.activeSheet = helpSheet
                    }
                }) {
                    Image(systemName: "questionmark.circle")
                        .imageScale(.large)
                }
                .accessibilityIdentifierLeaf("HelpButton")
                
                Button(action: {
                    // Add new food item
                    navigationPath.append(FoodItemListView.FoodListNavigationDestination.AddFoodItem(category: category))
                }) {
                    Image(systemName: "plus.circle")
                        .imageScale(.large)
                        .foregroundStyle(.green)
                }
                .accessibilityIdentifierLeaf("AddFoodItemButton")
                
                if listType == .selection && !composedFoodItem.foodItemVMs.isEmpty {
                    Button(action: {
                        withAnimation(.default) {
                            composedFoodItem.clearIngredients()
                            
                            // Close sheet
                            navigationPath.removeLast()
                        }
                    }) {
                        Image(systemName: "xmark.circle").foregroundStyle(.red)
                            .imageScale(.large)
                    }
                    .accessibilityIdentifierLeaf("ClearButton")
                }
            }
            
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    withAnimation {
                        self.showFavoritesOnly.toggle()
                    }
                }) {
                    if self.showFavoritesOnly {
                        Image(systemName: "star.fill")
                            .foregroundStyle(Color.yellow)
                            .imageScale(.large)
                    } else {
                        Image(systemName: "star")
                            .foregroundStyle(Color.blue)
                            .imageScale(.large)
                    }
                }
                .accessibilityIdentifierLeaf("ClearButton")
            }
        }
        .searchable(text: self.$searchString)
        .sheet(item: $activeSheet) {
            sheetContent($0)
        }
    }
    
    @ViewBuilder
    private func sheetContent(_ state: SheetState) -> some View {
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
