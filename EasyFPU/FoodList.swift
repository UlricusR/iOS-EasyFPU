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
    @FetchRequest(
        entity: FoodItem.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \FoodItem.name, ascending: true)
        ]
    ) var foodItems: FetchedResults<FoodItem>
    @State var showingSheet = false
    @State var activeSheet = ActiveFoodListSheet.selectFoodItem
    @State var draftFoodItem = FoodItemViewModel(
        name: "",
        favorite: false,
        caloriesPer100g: 0.0,
        carbsPer100g: 0.0,
        amount: 0
    )
    @State var editedFoodItem: FoodItem?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(foodItems, id: \.self) { foodItem in
                    FoodItemView(foodItem: foodItem)
                    .onTapGesture {
                        // Select food item for meal
                        self.editedFoodItem = foodItem
                        self.activeSheet = .selectFoodItem
                        self.showingSheet = true
                    }
                    .onLongPressGesture {
                        // Edit food item
                        self.draftFoodItem = FoodItemViewModel(
                            name: foodItem.name ?? "",
                            favorite: foodItem.favorite,
                            caloriesPer100g: foodItem.caloriesPer100g,
                            carbsPer100g: foodItem.carbsPer100g,
                            amount: Int(foodItem.amount)
                        )
                        self.editedFoodItem = foodItem
                        self.activeSheet = .editFoodItem
                        self.showingSheet = true
                    }
                }
                .onDelete(perform: deleteFoodItem)
            }
            .navigationBarTitle("Food List")
            .navigationBarItems(trailing: Button(action: {
                // Add new food item
                self.draftFoodItem = FoodItemViewModel(
                    name: "",
                    favorite: false,
                    caloriesPer100g: 0.0,
                    carbsPer100g: 0.0,
                    amount: 0
                )
                self.editedFoodItem = nil
                self.activeSheet = .editFoodItem
                self.showingSheet = true
            }) {
                Image(systemName: "plus.circle")
                    .imageScale(.large)
                    .foregroundColor(.green)
            })
        }
        .sheet(isPresented: $showingSheet) {
            FoodListSheets(
                activeSheet: self.activeSheet,
                isPresented: self.$showingSheet,
                draftFoodItem: self.$draftFoodItem,
                editedFoodItem: self.$editedFoodItem
            ).environment(\.managedObjectContext, self.managedObjectContext)
        }
    }
    
    func deleteFoodItem(at offsets: IndexSet) {
        offsets.forEach { index in
            let foodItem = self.foodItems[index]
            self.managedObjectContext.delete(foodItem)
        }
        
        saveContext()
    }
    
    func saveContext() {
        do {
            try managedObjectContext.save()
        } catch {
            print("Error saving managed object context: \(error)")
        }
    }
}
