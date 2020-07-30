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
    @State var activeSheet = ActiveFoodListSheet.addFoodItem
    @State var draftFoodItem = FoodItemViewModel(
        name: "",
        favorite: false,
        caloriesPer100g: 0.0,
        carbsPer100g: 0.0,
        amount: 0
    )
    
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
                    Text("Tap to select, long press to edit").font(.caption)
                    ForEach(foodItems, id: \.self) { foodItem in
                        FoodItemView(foodItem: foodItem)
                            .environment(\.managedObjectContext, self.managedObjectContext)
                            .environmentObject(self.userData)
                    }
                    .onDelete(perform: deleteFoodItem)
                }
                .navigationBarTitle("Food List")
                .navigationBarItems(
                    leading: Button(action: {
                        self.activeSheet = .editAbsorptionScheme
                        self.showingSheet = true
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .imageScale(.large)
                    },
                    trailing: Button(action: {
                        // Add new food item
                        self.draftFoodItem = FoodItemViewModel(
                            name: "",
                            favorite: false,
                            caloriesPer100g: 0.0,
                            carbsPer100g: 0.0,
                            amount: 0
                        )
                        self.activeSheet = .addFoodItem
                        self.showingSheet = true
                    }) {
                        Image(systemName: "plus.circle")
                            .imageScale(.large)
                            .foregroundColor(.green)
                    }
                )
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
                draftFoodItem: self.draftFoodItem,
                draftAbsorptionScheme: AbsorptionSchemeViewModel(from: self.userData.absorptionScheme),
                meal: self.meal
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
