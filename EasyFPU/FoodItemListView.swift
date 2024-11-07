//
//  FoodItemListView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 01.11.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct FoodItemListView: View {
    enum FoodItemListType {
        case maintenance
        case selection
    }
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var presentation
    var category: FoodItemCategory
    var listType: FoodItemListType
    @ObservedObject var composedFoodItem: ComposedFoodItemViewModel
    var helpSheet: FoodItemListViewSheets.State
    var foodItemListTitle: String
    var emptyStateImage: Image
    var emptyStateMessage: Text
    var emptyStateButtonText: Text
    @State private var searchString = ""
    @State private var showFavoritesOnly = false
    @State private var activeSheet: FoodItemListViewSheets.State?
    @State private var showingAlert: Bool = false
    @State private var errorMessage: String = ""
    
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
        ZStack(alignment: .top) {
            NavigationStack {
                VStack {
                    if foodItems.isEmpty {
                        // List is empty, so show a nice picture and an action button
                        emptyStateImage.padding()
                        emptyStateMessage.padding()
                        Button {
                            // Add new food item
                            activeSheet = .addFoodItem
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
                        List {
                            ForEach(self.filteredFoodItems.sorted {
                                if composedFoodItem.foodItemVMs.contains($0) && !composedFoodItem.foodItemVMs.contains($1) {
                                    return true
                                } else if !composedFoodItem.foodItemVMs.contains($0) && composedFoodItem.foodItemVMs.contains($1) {
                                    return false
                                } else {
                                    return $0.name < $1.name
                                }
                            }) { foodItem in
                                FoodItemView(composedFoodItemVM: composedFoodItem, foodItemVM: foodItem, category: self.category, listType: listType)
                                    .environment(\.managedObjectContext, self.managedObjectContext)
                                    .accessibilityIdentifierBranch(String(foodItem.name.prefix(10)))
                            }
                        }
                    }
                }
                .navigationBarTitle(foodItemListTitle)
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
                            activeSheet = .addFoodItem
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
                                    presentation.wrappedValue.dismiss()
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
                        
                        if listType == .selection {
                            Button(action: {
                                // Close sheet
                                presentation.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "checkmark.circle.fill")
                                    .imageScale(.large)
                            }
                            .disabled(composedFoodItem.foodItemVMs.isEmpty)
                            .accessibilityIdentifierLeaf("SaveButton")
                        }
                    }
                }
            }
            .searchable(text: self.$searchString)
            .sheet(item: $activeSheet) {
                sheetContent($0)
            }
            .alert(isPresented: self.$showingAlert) {
                Alert(
                    title: Text("Notice"),
                    message: Text(self.errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    @ViewBuilder
    private func sheetContent(_ state: FoodItemListViewSheets.State) -> some View {
        switch state {
        case .addFoodItem:
            FoodItemEditor(
                navigationBarTitle: NSLocalizedString("New \(category.rawValue)", comment: ""),
                draftFoodItemVM: // Create new empty draftFoodItem
                    FoodItemViewModel(
                        id: UUID(),
                        name: "",
                        category: category,
                        favorite: false,
                        caloriesPer100g: 0.0,
                        carbsPer100g: 0.0,
                        sugarsPer100g: 0.0,
                        amount: 0
                    ),
                category: category
            )
            .environment(\.managedObjectContext, managedObjectContext)
            .accessibilityIdentifierBranch("EditFoodItem")
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
