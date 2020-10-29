//
//  ContentView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 11.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct FoodList: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var absorptionScheme: AbsorptionScheme
    @Binding var showingMenu: Bool
    @FetchRequest(
        entity: FoodItem.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \FoodItem.name, ascending: true)
        ]
    ) var foodItems: FetchedResults<FoodItem>
    
    @State private var activeSheet: FoodListSheets.State?
    @State private var showingAlert = false
    @State private var errorMessage = ""
    @State private var draftFoodItem = FoodItemViewModel(
        name: "",
        category: .product,
        favorite: false,
        caloriesPer100g: 0.0,
        carbsPer100g: 0.0,
        sugarsPer100g: 0.0,
        amount: 0
    )
    @State private var searchString = ""
    @State private var showCancelButton: Bool = false
    @State private var showFavoritesOnly = false
    private let helpScreen = HelpScreen.foodList

    var filteredFoodItems: [FoodItemViewModel] {
        if searchString == "" {
            return showFavoritesOnly ? foodItems.map { FoodItemViewModel(from: $0) } .filter { $0.favorite && $0.category == .product } : foodItems.map { FoodItemViewModel(from: $0) } .filter { $0.category == .product }
        } else {
            return showFavoritesOnly ? foodItems.map { FoodItemViewModel(from: $0) } .filter { $0.favorite && $0.category == .product && $0.name.lowercased().contains(searchString.lowercased()) } : foodItems.map { FoodItemViewModel(from: $0) } .filter { $0.category == .product && $0.name.lowercased().contains(searchString.lowercased()) }
        }
    }
    
    var meal: MealViewModel {
        let meal = MealViewModel(name: "Total meal")
        for foodItem in foodItems {
            if foodItem.category == FoodItemCategory.product.rawValue && foodItem.amount > 0 {
                meal.add(foodItem: FoodItemViewModel(from: foodItem))
            }
        }
        return meal
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
                        FoodItemView(foodItem: foodItem, category: .product)
                            .environment(\.managedObjectContext, self.managedObjectContext)
                    }
                    .onDelete(perform: self.deleteFoodItem)
                }
                
                if !self.meal.foodItems.isEmpty {
                    MealSummaryView(activeFoodListSheet: self.$activeSheet, absorptionScheme: self.absorptionScheme, meal: self.meal)
                }
            }
            .disabled(self.showingMenu ? true : false)
            .navigationBarTitle("Products")
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
                        // Add new food item
                        activeSheet = .addFoodItem
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
                errorMessage = NSLocalizedString("Cannot delete food item", comment: "")
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
    private func sheetContent(_ state: FoodListSheets.State) -> some View {
        switch state {
        case .addFoodItem:
            FoodItemEditor(
                navigationBarTitle: NSLocalizedString("New food item", comment: ""),
                draftFoodItem: draftFoodItem,
                category: .product
            ).environment(\.managedObjectContext, managedObjectContext)
        case .mealDetails:
            MealDetail(absorptionScheme: self.absorptionScheme, meal: self.meal)
        case .help:
            HelpView(helpScreen: helpScreen)
        }
    }
}
