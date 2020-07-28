//
//  FoodItemViewModel.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 24.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

enum DataError: Error {
    case inputError(String)
}

class FoodItemViewModel: ObservableObject {
    @Published var name: String
    @Published var favorite: Bool
    @Published var caloriesAsString: String = "" {
        willSet {
            let result = FoodItemViewModel.checkForPositiveDouble(valueAsString: newValue)
            switch result {
            case .success(let caloriesAsDouble):
                caloriesPer100g = caloriesAsDouble
            case .failure(let err):
                debugPrint(err.localizedDescription)
                return
            }
        }
    }
    @Published var carbsAsString: String = "" {
        willSet {
            let result = FoodItemViewModel.checkForPositiveDouble(valueAsString: newValue)
            switch result {
            case .success(let carbsAsDouble):
                carbsPer100g = carbsAsDouble
            case .failure(let err):
                debugPrint(err.localizedDescription)
                return
            }
        }
    }
    @Published var amountAsString: String = "" {
        willSet {
            let result = FoodItemViewModel.checkForPositiveInt(valueAsString: newValue)
            switch result {
            case .success(let amountAsInt):
                amount = amountAsInt
            case .failure(let err):
                debugPrint(err.localizedDescription)
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
        let caloriesResult = FoodItemViewModel.checkForPositiveDouble(valueAsString: caloriesAsString)
        switch caloriesResult {
        case .success(let caloriesAsDouble):
            caloriesPer100g = caloriesAsDouble
        case .failure(let err):
            errorMessage = err.localizedDescription
            return nil
        }
        self.caloriesAsString = caloriesAsString
        
        // Check for valid carbs
        let carbsResult = FoodItemViewModel.checkForPositiveDouble(valueAsString: carbsAsString)
        switch carbsResult {
        case .success(let carbsAsDouble):
            carbsPer100g = carbsAsDouble
        case .failure(let err):
            errorMessage = err.localizedDescription
            return nil
        }
        self.carbsAsString = carbsAsString
        
        // Check if calories from carbs exceed total calories
        if FoodItemViewModel.doubleFormatter(numberOfDigits: 5).number(from: carbsAsString)!.doubleValue * 4 > FoodItemViewModel.doubleFormatter(numberOfDigits: 5).number(from: caloriesAsString)!.doubleValue {
            errorMessage = NSLocalizedString("Calories from carbs (4 kcal per gram) exceed total calories", comment: "")
            return nil
        }
        
        // Check for valid amount
        let amountResult = FoodItemViewModel.checkForPositiveInt(valueAsString: amountAsString)
        switch amountResult {
        case .success(let amountAsInt):
            amount = amountAsInt
        case .failure(let err):
            errorMessage = err.localizedDescription
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
    
    static func checkForPositiveDouble(valueAsString: String) -> Result<Double, DataError> {
        guard
            let valueAsNumber = FoodItemViewModel.doubleFormatter(numberOfDigits: 5).number(from: valueAsString),
            valueAsNumber.doubleValue >= 0.0
        else {
            return .failure(.inputError(NSLocalizedString("Value not a number or negative: ", comment: "") + valueAsString))
        }
        return .success(valueAsNumber.doubleValue)
    }
    
    static func checkForPositiveInt(valueAsString: String) -> Result<Int, DataError> {
        guard
            let valueAsNumber = NumberFormatter().number(from: valueAsString),
            valueAsNumber.intValue >= 0
        else {
            return .failure(.inputError(NSLocalizedString("Value not a number or negative: ", comment: "") + valueAsString))
        }
        return .success(valueAsNumber.intValue)
    }
}
