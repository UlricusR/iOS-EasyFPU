//
//  IngredientsList.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 28.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct IngredientsList: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Binding var showingMenu: Bool
    @FetchRequest(
        entity: FoodItem.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \FoodItem.name, ascending: true)
        ]
    ) var foodItems: FetchedResults<FoodItem>
    
    @State private var activeSheet: IngredientsListSheets.State?
    @State private var showingAlert = false
    @State private var errorMessage = ""
    @State private var draftFoodItem = FoodItemViewModel(
        name: "",
        category: .ingredient,
        favorite: false,
        caloriesPer100g: 0.0,
        carbsPer100g: 0.0,
        sugarsPer100g: 0.0,
        amount: 0
    )
    @State private var searchString = ""
    @State private var showCancelButton: Bool = false
    @State private var showFavoritesOnly = false
    private let helpScreen = HelpScreen.ingredients

    var filteredFoodItems: [FoodItemViewModel] {
        if searchString == "" {
            return showFavoritesOnly ? foodItems.map { FoodItemViewModel(from: $0) } .filter { $0.favorite && $0.category == .ingredient } : foodItems.map { FoodItemViewModel(from: $0) } .filter { $0.category == .ingredient }
        } else {
            return showFavoritesOnly ? foodItems.map { FoodItemViewModel(from: $0) } .filter { $0.favorite && $0.category == .ingredient && $0.name.lowercased().contains(searchString.lowercased()) } : foodItems.map { FoodItemViewModel(from: $0) } .filter { $0.category == .ingredient && $0.name.lowercased().contains(searchString.lowercased()) }
        }
    }
    
    var composedProduct: ComposedProductViewModel {
        let product = ComposedProductViewModel(name: "Composed Product")
        for foodItem in foodItems {
            if foodItem.amount > 0 {
                foodItem.category = FoodItemCategory.ingredient.rawValue
                product.add(foodItem: FoodItemViewModel(from: foodItem))
            }
        }
        return product
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    // Search view
                    SearchView(searchString: self.$searchString, showCancelButton: self.$showCancelButton)
                        .padding(.horizontal)
                    Text("Tap to select, long press to edit").font(.caption)
                    ForEach(self.filteredFoodItems) { foodItem in
                        FoodItemView(foodItem: foodItem, category: .ingredient)
                            .environment(\.managedObjectContext, self.managedObjectContext)
                    }
                    .onDelete(perform: self.deleteFoodItem)
                }
                
                if !self.composedProduct.foodItems.isEmpty {
                    ComposedProductSummaryView(activeIngredientsListSheet: self.$activeSheet, product: self.composedProduct)
                }
            }
            .disabled(self.showingMenu ? true : false)
            .navigationBarTitle("Ingredients")
            .navigationBarItems(
                leading: HStack {
                    Button(action: {
                        withAnimation {
                            self.showingMenu.toggle()
                        }
                    }) {
                        Image(systemName: self.showingMenu ? "xmark" : "line.horizontal.3")
                        .imageScale(.large)
                    }
                    
                    Button(action: {
                        withAnimation {
                            self.activeSheet = .help
                        }
                    }) {
                        Image(systemName: "questionmark.circle")
                        .imageScale(.large)
                        .padding()
                    }.disabled(self.showingMenu ? true : false)
                },
                trailing: HStack {
                    Button(action: {
                        withAnimation {
                            self.showFavoritesOnly.toggle()
                        }
                    }) {
                        if self.showFavoritesOnly {
                            Image(systemName: "star.fill")
                            .foregroundColor(Color.yellow)
                            .padding()
                        } else {
                            Image(systemName: "star")
                            .foregroundColor(Color.gray)
                            .padding()
                        }
                    }.disabled(self.showingMenu ? true : false)
                    
                    Button(action: {
                        // Add new ingredient
                        activeSheet = .addIngredient
                    }) {
                        Image(systemName: "plus.circle")
                            .imageScale(.large)
                            .foregroundColor(.green)
                    }.disabled(self.showingMenu ? true : false)
                }
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
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
    
    private func deleteFoodItem(at offsets: IndexSet) {
        offsets.forEach { index in
            guard let foodItem = self.filteredFoodItems[index].cdFoodItem else {
                errorMessage = NSLocalizedString("Cannot delete ingredient", comment: "")
                showingAlert = true
                return
            }
            
            // Delete typical amounts first
            let typicalAmountsToBeDeleted = foodItem.typicalAmounts
            if typicalAmountsToBeDeleted != nil {
                for typicalAmountToBeDeleted in typicalAmountsToBeDeleted! {
                    self.managedObjectContext.delete(typicalAmountToBeDeleted as! TypicalAmount)
                }
                foodItem.removeFromTypicalAmounts(typicalAmountsToBeDeleted!)
            }
            
            // Delete food item
            self.managedObjectContext.delete(foodItem)
        }
        
        try? AppDelegate.viewContext.save()
    }
    
    @ViewBuilder
    private func sheetContent(_ state: IngredientsListSheets.State) -> some View {
        switch state {
        case .addIngredient:
            FoodItemEditor(
                navigationBarTitle: NSLocalizedString("New food item", comment: ""),
                draftFoodItem: draftFoodItem,
                category: .ingredient
            ).environment(\.managedObjectContext, managedObjectContext)
        case .composedProductDetail:
            ComposedProductDetail(product: self.composedProduct)
        case .help:
            HelpView(helpScreen: helpScreen)
        }
    }
}
