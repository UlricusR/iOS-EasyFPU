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

class FoodItemViewModel: ObservableObject, Codable, Hashable {
    @Published var name: String
    @Published var favorite: Bool
    @Published var caloriesAsString: String = "" {
        willSet {
            let result = FoodItemViewModel.checkForPositiveDouble(valueAsString: newValue, allowZero: true)
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
            let result = FoodItemViewModel.checkForPositiveDouble(valueAsString: newValue, allowZero: true)
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
            let result = FoodItemViewModel.checkForPositiveInt(valueAsString: newValue, allowZero: true)
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
    var cdFoodItem: FoodItem?
    
    enum CodingKeys: String, CodingKey {
        case foodItem
        case amount, caloriesPer100g, carbsPer100g, favorite, name, typicalAmounts
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
    
    init(from cdFoodItem: FoodItem) {
        self.name = cdFoodItem.name ?? NSLocalizedString("- Unnamned -", comment: "")
        self.favorite = cdFoodItem.favorite
        self.caloriesPer100g = cdFoodItem.caloriesPer100g
        self.carbsPer100g = cdFoodItem.carbsPer100g
        self.amount = Int(cdFoodItem.amount)
        self.cdFoodItem = cdFoodItem
        
        self.caloriesAsString = FoodItemViewModel.doubleFormatter(numberOfDigits: 5).string(from: NSNumber(value: cdFoodItem.caloriesPer100g))!
        self.carbsAsString = FoodItemViewModel.doubleFormatter(numberOfDigits: 5).string(from: NSNumber(value: cdFoodItem.carbsPer100g))!
        self.amountAsString = NumberFormatter().string(from: NSNumber(value: cdFoodItem.amount))!
        
        if cdFoodItem.typicalAmounts != nil {
            for typicalAmount in cdFoodItem.typicalAmounts!.allObjects {
                let castedTypicalAmount = typicalAmount as! TypicalAmount
                typicalAmounts.append(TypicalAmountViewModel(from: castedTypicalAmount))
            }
        }
    }
    
    init?(name: String, favorite: Bool, caloriesAsString: String, carbsAsString: String, amountAsString: String, errorMessage: inout String) {
        self.name = name
        self.favorite = favorite
        
        // Check for valid calories
        let caloriesResult = FoodItemViewModel.checkForPositiveDouble(valueAsString: caloriesAsString, allowZero: true)
        switch caloriesResult {
        case .success(let caloriesAsDouble):
            caloriesPer100g = caloriesAsDouble
        case .failure(let err):
            errorMessage = err.localizedDescription
            return nil
        }
        self.caloriesAsString = caloriesAsString
        
        // Check for valid carbs
        let carbsResult = FoodItemViewModel.checkForPositiveDouble(valueAsString: carbsAsString, allowZero: true)
        switch carbsResult {
        case .success(let carbsAsDouble):
            carbsPer100g = carbsAsDouble
        case .failure(let err):
            errorMessage = err.localizedDescription
            return nil
        }
        self.carbsAsString = carbsAsString
        
        // Check if calories from carbs exceed total calories
        if carbsPer100g * 4 > caloriesPer100g {
            errorMessage = NSLocalizedString("Calories from carbs (4 kcal per gram) exceed total calories", comment: "")
            return nil
        }
        
        // Check for valid amount
        let amountResult = FoodItemViewModel.checkForPositiveInt(valueAsString: amountAsString, allowZero: true)
        switch amountResult {
        case .success(let amountAsInt):
            amount = amountAsInt
        case .failure(let err):
            errorMessage = err.localizedDescription
            return nil
        }
        self.amountAsString = amountAsString
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let foodItem = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .foodItem)
        amount = try foodItem.decode(Int.self, forKey: .amount)
        caloriesPer100g = try foodItem.decode(Double.self, forKey: .caloriesPer100g)
        carbsPer100g = try foodItem.decode(Double.self, forKey: .carbsPer100g)
        favorite = try foodItem.decode(Bool.self, forKey: .favorite)
        name = try foodItem.decode(String.self, forKey: .name)
        typicalAmounts = try foodItem.decode([TypicalAmountViewModel].self, forKey: .typicalAmounts)
        
        guard
            let caloriesAsString = FoodItemViewModel.doubleFormatter(numberOfDigits: 5).string(from: NSNumber(value: caloriesPer100g)),
            let carbsAsString = FoodItemViewModel.doubleFormatter(numberOfDigits: 5).string(from: NSNumber(value: carbsPer100g)),
            let amountAsString = NumberFormatter().string(from: NSNumber(value: amount))
        else {
            throw DataError.inputError(NSLocalizedString("Fatal error: Cannot convert numbers into string, please contact app developer", comment: ""))
        }
        self.caloriesAsString = caloriesAsString
        self.carbsAsString = carbsAsString
        self.amountAsString = amountAsString
    }
    
    func getCalories() -> Double {
        Double(self.amount) * self.caloriesPer100g / 100
    }
    
    func getCarbs() -> Double {
        Double(self.amount) * self.carbsPer100g / 100
    }
    
    func getFPU() -> FPU {
        // 1g carbs has ~4 kcal, so calculate carb portion of calories
        let carbsCal = Double(self.amount) / 100 * self.carbsPer100g * 4;

        // The carbs from fat and protein is the remainder
        let calFromFP = getCalories() - carbsCal;

        // 100kcal makes 1 FPU
        let fpus = calFromFP / 100;

        // Create and return the FPU object
        return FPU(fpu: fpus)
    }
    
    func updateCDFoodItem(_ cdFoodItem: inout FoodItem) {
        cdFoodItem.name = name
        cdFoodItem.amount = Int64(amount)
        cdFoodItem.caloriesPer100g = caloriesPer100g
        cdFoodItem.carbsPer100g = carbsPer100g
        cdFoodItem.favorite = favorite
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var foodItem = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .foodItem)
        try foodItem.encode(amount, forKey: .amount)
        try foodItem.encode(caloriesPer100g, forKey: .caloriesPer100g)
        try foodItem.encode(carbsPer100g, forKey: .carbsPer100g)
        try foodItem.encode(favorite, forKey: .favorite)
        try foodItem.encode(name, forKey: .name)
        try foodItem.encode(typicalAmounts, forKey: .typicalAmounts)
    }
    
    static func doubleFormatter(numberOfDigits: Int) -> NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = numberOfDigits
        return numberFormatter
    }
    
    static func checkForPositiveDouble(valueAsString: String, allowZero: Bool) -> Result<Double, DataError> {
        guard let valueAsNumber = FoodItemViewModel.doubleFormatter(numberOfDigits: 5).number(from: valueAsString) else {
            return .failure(.inputError(NSLocalizedString("Value not a number: ", comment: "") + valueAsString))
        }
        guard allowZero ? valueAsNumber.doubleValue >= 0.0 : valueAsNumber.doubleValue > 0.0 else {
            return .failure(.inputError(NSLocalizedString("Value must not be zero or negative", comment: "")))
        }
        return .success(valueAsNumber.doubleValue)
    }
    
    static func checkForPositiveInt(valueAsString: String, allowZero: Bool) -> Result<Int, DataError> {
        guard let valueAsNumber = NumberFormatter().number(from: valueAsString) else {
            return .failure(.inputError(NSLocalizedString("Value not a number: ", comment: "") + valueAsString))
        }
        guard allowZero ? valueAsNumber.intValue >= 0 : valueAsNumber.intValue > 0 else {
            return .failure(.inputError(NSLocalizedString("Value must not be zero or negative", comment: "")))
        }
        return .success(valueAsNumber.intValue)
    }
    
    static func == (lhs: FoodItemViewModel, rhs: FoodItemViewModel) -> Bool {
        if lhs.name != rhs.name { return false }
        if lhs.caloriesPer100g != rhs.caloriesPer100g { return false }
        if lhs.carbsPer100g != rhs.carbsPer100g { return false }
        if lhs.amount != rhs.amount { return false }
        return true
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(caloriesPer100g)
        hasher.combine(carbsPer100g)
        hasher.combine(amount)
    }
}
