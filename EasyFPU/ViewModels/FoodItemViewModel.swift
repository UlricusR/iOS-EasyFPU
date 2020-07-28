//
//  FoodItemViewModel.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 24.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class FoodItemViewModel: ObservableObject {
    @Published var name: String
    @Published var favorite: Bool
    @Published var caloriesAsString: String = "" {
        willSet {
            guard FoodItemViewModel.checkForPositiveDouble(valueAsString: newValue, valueAsDouble: &caloriesPer100g) else {
                return
            }
        }
    }
    @Published var carbsAsString: String = "" {
        willSet {
            guard FoodItemViewModel.checkForPositiveDouble(valueAsString: newValue, valueAsDouble: &carbsPer100g) else {
                return
            }
        }
    }
    @Published var amountAsString: String = "" {
        willSet {
            guard FoodItemViewModel.checkForPositiveInt(valueAsString: newValue, valueAsInt: &amount) else {
                return
            }
        }
    }
    private(set) var caloriesPer100g: Double = 0.0
    private(set) var carbsPer100g: Double = 0.0
    private(set) var amount: Int = 0
    var typicalAmounts = [TypicalAmountViewModel]()
    
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
    
    static func doubleFormatter(numberOfDigits: Int) -> NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = numberOfDigits
        return numberFormatter
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
