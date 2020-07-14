//
//  FoodItemEditor.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 13.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct FoodItemEditor: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Binding var isPresented: Bool
    @State var draftFoodItem: FoodItemViewModel // A working copy of the food item
    @State private var showingAlert = false
    
    var body: some View {
        VStack {
            HStack {
                // Cancel editing
                Button(action: {
                    // Do nothing, just quit edit mode, as food item hasn't been modified
                    self.isPresented = false
                }) {
                    Text("Cancel")
                }
                
                Spacer()
                
                // Confirm editing
                Button(action: {
                    if self.draftFoodItem.isValid() { // We have valid data
                        let foodItem = FoodItem(context: self.managedObjectContext)
                        foodItem.name = self.draftFoodItem.name
                        foodItem.favorite = self.draftFoodItem.favorite
                        
                        if let caloriesPer100g = self.draftFoodItem.getCaloriesPer100g() {
                            foodItem.caloriesPer100g = caloriesPer100g
                        } else {
                            foodItem.caloriesPer100g = 0.0
                        }
                        if let carbsPer100g = self.draftFoodItem.getCarbsPer100g() {
                            foodItem.carbsPer100g = carbsPer100g
                        } else {
                            foodItem.carbsPer100g = 0.0
                        }
                        
                        // Save data
                        do {
                            try self.managedObjectContext.save()
                        } catch {
                            debugPrint(error)
                        }
                        
                        // Quit edit mode
                        self.isPresented = false
                    } else { // Invalid data, display alert
                        // Display alert and stay in edit mode
                        self.showingAlert = true
                    }
                }) {
                    Text("Done")
                }
                .alert(isPresented: $showingAlert) {
                    Alert(
                        title: Text("Data alert"),
                        message: Text(self.draftFoodItem.errorMessages!.joined(separator: ", ")),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }.padding()
            
            Form {
                Section {
                    // Name
                    TextField("Name", text: $draftFoodItem.name)
                    
                    // Favorite
                    Toggle("Favorite", isOn: $draftFoodItem.favorite)
                    
                    // Calories
                    HStack {
                        TextField("Calories per 100g", text: $draftFoodItem.caloriesPer100g)
                            .keyboardType(.decimalPad)
                        Text("kcal")
                    }
                    
                    // Carbs
                    HStack {
                        TextField("Carbs per 100g", text: $draftFoodItem.carbsPer100g)
                            .keyboardType(.decimalPad)
                        Text("g")
                    }
                }
            }
        }
    }
}
