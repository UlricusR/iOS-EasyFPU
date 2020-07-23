//
//  FoodItemEditor.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 13.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI
import Combine

class FoodItemViewModel: ObservableObject {
    @Published var name: String
    @Published var favorite: Bool
    @Published var caloriesAsString: String = ""
    @Published var carbsAsString: String = ""
    @Published var amountAsString: String = ""
    var caloriesPer100g: Double = 0.0
    var carbsPer100g: Double = 0.0
    var amount: Int = 0
    
    static func doubleFormatter(numberOfDigits: Int) -> NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = numberOfDigits
        return numberFormatter
    }
    
    init(name: String, favorite: Bool, caloriesPer100g: Double, carbsPer100g: Double, amount: Int) {
        self.name = name
        self.favorite = favorite
        self.caloriesPer100g = caloriesPer100g
        self.carbsPer100g = carbsPer100g
        self.amount = amount
        
        self.caloriesAsString = FoodItemViewModel.doubleFormatter(numberOfDigits: 5).string(from: NSNumber(value: caloriesPer100g))!
        self.carbsAsString = FoodItemViewModel.doubleFormatter(numberOfDigits: 5).string(from: NSNumber(value: carbsPer100g))!
        self.amountAsString = NumberFormatter().string(from: NSNumber(value: amount))!
    }
    
    init?(name: String, favorite: Bool, caloriesAsString: String, carbsAsString: String, amountAsString: String, errorMessage: inout String) {
        self.name = name
        self.favorite = favorite
        
        // Check for valid calories
        guard FoodItemViewModel.checkForPositiveDouble(valueAsString: caloriesAsString, valueAsDouble: &self.caloriesPer100g) else {
            errorMessage = NSLocalizedString("Calories not a valid number or negative", comment: "")
            return nil
        }
        self.caloriesAsString = caloriesAsString
        
        // Check for valid carbs
        guard FoodItemViewModel.checkForPositiveDouble(valueAsString: carbsAsString, valueAsDouble: &self.carbsPer100g) else {
            errorMessage = NSLocalizedString("Carbs not a valid number or negative", comment: "")
            return nil
        }
        self.carbsAsString = carbsAsString
        
        // Check if calories from carbs exceed total calories
        if FoodItemViewModel.doubleFormatter(numberOfDigits: 5).number(from: carbsAsString)!.doubleValue * 4 > FoodItemViewModel.doubleFormatter(numberOfDigits: 5).number(from: caloriesAsString)!.doubleValue {
            errorMessage = NSLocalizedString("Calories from carbs (4 kcal per gram) exceed total calories", comment: "")
            return nil
        }
        
        // Check for valid amount
        guard FoodItemViewModel.checkForPositiveInt(valueAsString: amountAsString, valueAsInt: &self.amount) else {
            errorMessage = NSLocalizedString("Amount not a valid number or negative", comment: "")
            return nil
        }
        self.amountAsString = amountAsString
    }
    
    static func checkForPositiveDouble(valueAsString: String, valueAsDouble: inout Double) -> Bool {
        guard let valueAsNumber = FoodItemViewModel.doubleFormatter(numberOfDigits: 5).number(from: valueAsString) else {
            return false
        }
        guard valueAsNumber.doubleValue >= 0.0 else {
            return false
        }
        valueAsDouble = valueAsNumber.doubleValue
        return true
    }
    
    static func checkForPositiveInt(valueAsString: String, valueAsInt: inout Int) -> Bool {
        guard let valueAsNumber = NumberFormatter().number(from: valueAsString) else {
            return false
        }
        guard valueAsNumber.intValue >= 0 else {
            return false
        }
        valueAsInt = valueAsNumber.intValue
        return true
    }
}

struct FoodItemEditor: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Binding var isPresented: Bool
    @Binding var draftFoodItem: FoodItemViewModel
    var editedFoodItem: FoodItem? // Working copy of the food item
    @State var errorMessage: String = ""
    
    @State var showingAlert = false
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
                    if let updatedFoodItem = FoodItemViewModel(
                        name: self.draftFoodItem.name,
                        favorite: self.draftFoodItem.favorite,
                        caloriesAsString: self.draftFoodItem.caloriesAsString,
                        carbsAsString: self.draftFoodItem.carbsAsString,
                        amountAsString: self.draftFoodItem.amountAsString,
                        errorMessage: &self.errorMessage) { // We have a valid food item
                        if self.editedFoodItem != nil { // We need to update an existing food item
                            self.editedFoodItem!.name = updatedFoodItem.name
                            self.editedFoodItem!.favorite = updatedFoodItem.favorite
                            self.editedFoodItem!.carbsPer100g = updatedFoodItem.carbsPer100g
                            self.editedFoodItem!.caloriesPer100g = updatedFoodItem.caloriesPer100g
                            self.editedFoodItem!.amount = Int64(updatedFoodItem.amount)
                        } else { // We have a new food item
                            let newFoodItem = FoodItem(context: self.managedObjectContext)
                            newFoodItem.id = UUID()
                            newFoodItem.name = updatedFoodItem.name
                            newFoodItem.favorite = updatedFoodItem.favorite
                            newFoodItem.carbsPer100g = updatedFoodItem.carbsPer100g
                            newFoodItem.caloriesPer100g = updatedFoodItem.caloriesPer100g
                            newFoodItem.amount = Int64(updatedFoodItem.amount)
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
                        message: Text(self.errorMessage),
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
                        TextField("Calories per 100g", text: $draftFoodItem.caloriesAsString)
                            .keyboardType(.decimalPad)
                        Text("kcal")
                    }
                    
                    // Carbs
                    HStack {
                        TextField("Carbs per 100g", text: $draftFoodItem.carbsAsString)
                            .keyboardType(.decimalPad)
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
