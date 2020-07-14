//
//  FoodVM.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 12.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI
import CoreData

struct FoodItemViewModel: Identifiable {
    var id: UUID = UUID()
    var amount: Int = 0
    var selected: Bool = false
    var name: String
    var favorite: Bool
    var caloriesPer100g: String
    var carbsPer100g: String
    var typicalAmounts: [TypicalAmount]?
    
    var caloriesAsNUmber: NSNumber?
    var carbsAsNumber: NSNumber?
    
    var errorMessages: [String]?
    
    mutating func isValid() -> Bool {
        // Create empty error message array
        errorMessages = [String]()
        
        // Convert string representation of numbers to number
        guard let caloriesPer100g = getAsNumber(from: self.caloriesPer100g) else {
            errorMessages!.append(NSLocalizedString("Calories not a valid number", comment: ""))
            return false
        }
        guard let carbsPer100g = getAsNumber(from: self.carbsPer100g) else {
            errorMessages!.append(NSLocalizedString("Carbs not a valid number", comment: ""))
            return false
        }
        
        caloriesAsNUmber = caloriesPer100g
        carbsAsNumber = carbsPer100g
        
        var isValid = true
        if name.isEmpty {
            errorMessages!.append(NSLocalizedString("Name must not be empty", comment: ""))
            isValid = false
        }
        if caloriesPer100g.doubleValue < 0.0 {
            errorMessages!.append(NSLocalizedString("Calories per 100g must not be negative", comment: ""))
            isValid = false
        }
        
        if carbsPer100g.doubleValue < 0.0 {
            errorMessages!.append(NSLocalizedString("Carbs per 100g must not be negative", comment: ""))
            isValid = false
        }
        if carbsPer100g.doubleValue * 4 > caloriesPer100g.doubleValue {
            errorMessages!.append(NSLocalizedString("Calories from carbs (4 kcal per gram) exceed total calories", comment: ""))
            isValid = false
        }
        return isValid
    }
    
    private func getAsNumber(from numberAsString: String) -> NSNumber? {
        // Create a formatter with the correct decimal separator
        let formatter = NumberFormatter()
        formatter.decimalSeparator = (numberAsString.firstIndex(of: ",") != nil ) ? "," : "."
        return formatter.number(from: numberAsString)
    }
    
    mutating func getCaloriesPer100g() -> Double? {
        if caloriesAsNUmber != nil || isValid() {
            return caloriesAsNUmber!.doubleValue
        } else {
            return nil
        }
    }
    
    mutating func getCarbsPer100g() -> Double? {
        if carbsAsNumber != nil || isValid() {
            return carbsAsNumber!.doubleValue
        } else {
            return nil
        }
    }
}
