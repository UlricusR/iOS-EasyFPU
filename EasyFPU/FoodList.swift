//
//  ContentView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 11.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct FoodList: View {
    @EnvironmentObject var userData: UserData
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
    
    var meal: Meal {
        var meal = Meal(name: "Total meal")
        for foodItem in foodItems {
            meal.add(foodItem: foodItem)
        }
        return meal
    }
    
    var body: some View {
        VStack {
            NavigationView {
                List {
                    ForEach(foodItems, id: \.self) { foodItem in
                        FoodItemView(foodItem: foodItem)
                        .environmentObject(self.userData)
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
                
            if meal.amount > 0 {
                VStack {
                    Text("Total meal").font(.headline)
                    
                    HStack {
                        VStack {
                            HStack {
                                Text(FoodItemViewModel.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: self.meal.carbs))!)
                                Text("g")
                            }
                            Text("Carbs").font(.caption)
                        }
                        
                        VStack {
                            HStack {
                                Text(FoodItemViewModel.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: self.meal.fpus.getExtendedCarbs()))!)
                                Text("g")
                            }
                            Text("Extended Carbs").font(.caption)
                        }
                        
                        VStack {
                            HStack {
                                Text(NumberFormatter().string(from: NSNumber(value: self.meal.fpus.getAbsorptionTime(absorptionScheme: self.userData.absorptionScheme)))!)
                                Text("h")
                            }
                            Text("Absorption Time").font(.caption)
                        }
                    }
                }
                .onTapGesture {
                    self.activeSheet = .showMealDetails
                    self.showingSheet = true
                }
                .foregroundColor(.red)
            }
        }
        .sheet(isPresented: $showingSheet) {
            FoodListSheets(
                activeSheet: self.activeSheet,
                isPresented: self.$showingSheet,
                draftFoodItem: self.$draftFoodItem,
                meal: self.meal,
                editedFoodItem: self.$editedFoodItem
            )
                .environment(\.managedObjectContext, self.managedObjectContext)
                .environmentObject(self.userData)
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
