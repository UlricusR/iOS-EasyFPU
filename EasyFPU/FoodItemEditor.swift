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
    @Binding var draftFoodItem: FoodItem // A working copy of the food item
    @State private var showingAlert = false
    @FetchRequest(
        entity: FoodItem.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \FoodItem.name, ascending: true)
        ]
    ) var foodItems: FetchedResults<FoodItem>
    
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
                        if let updatedFoodItem = self.foodItems.first(where: { $0.id == self.draftFoodItem.id }) {
                            // Existing food item
                            updatedFoodItem.name = self.draftFoodItem.name
                            updatedFoodItem.favorite = self.draftFoodItem.favorite
                            updatedFoodItem.carbsPer100g = self.draftFoodItem.carbsPer100g
                            updatedFoodItem.caloriesPer100g = self.draftFoodItem.caloriesPer100g
                            updatedFoodItem.amount = self.draftFoodItem.amount
                        } else {
                            // New food item
                            let newFoodItem = FoodItem(context: self.managedObjectContext)
                            newFoodItem.id = UUID()
                            newFoodItem.name = self.draftFoodItem.name
                            newFoodItem.favorite = self.draftFoodItem.favorite
                            newFoodItem.carbsPer100g = self.draftFoodItem.carbsPer100g
                            newFoodItem.caloriesPer100g = self.draftFoodItem.caloriesPer100g
                            newFoodItem.amount = self.draftFoodItem.amount
                        }
                        
                        // Save new food item
                        self.saveContext()
                        
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
                        message: Text(self.draftFoodItem.errorMessage!),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }.padding()
            
            Form {
                Section {
                    // Name
                    TextField("Name", text: $draftFoodItem.name.bound)
                    
                    // Favorite
                    Toggle("Favorite", isOn: $draftFoodItem.favorite)
                    
                    // Calories
                    HStack {
                        TextFieldDouble(title: "Calories per 100g", value: $draftFoodItem.caloriesPer100g)
                        Text("kcal")
                    }
                    
                    // Carbs
                    HStack {
                        TextFieldDouble(title: "Carbs per 100g", value: $draftFoodItem.carbsPer100g)
                        Text("g")
                    }
                }
            }
        }
    }
    
    func saveContext() {
        if self.managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                print("Error saving managed object context: \(error)")
            }
        }
    }
}

extension Optional where Wrapped == String {
    var _bound: String? {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
    public var bound: String {
        get {
            return _bound ?? ""
        }
        set {
            _bound = newValue.isEmpty ? nil : newValue
        }
    }
}
