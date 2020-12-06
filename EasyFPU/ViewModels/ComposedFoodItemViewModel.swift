//
//  ComposedProductViewModel.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 29.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class ComposedFoodItemViewModel: ObservableObject, Codable, VariableAmountItem {
    enum IngredientsSyncStrategy {
        case createMissingFoodItems, removeNonExistingIngredients
    }
    
    @Published var name: String
    var category: FoodItemCategory
    @Published var favorite: Bool
    @Published var amount: Int = 0
    @Published var numberOfPortions: Int = 0
    @Published var foodItems = [FoodItemViewModel]()
    var cdComposedFoodItem: ComposedFoodItem?
    
    @Published var amountAsString: String = "" {
        willSet {
            let result = DataHelper.checkForPositiveInt(valueAsString: newValue, allowZero: true)
            switch result {
            case .success(let amountAsInt):
                amount = amountAsInt
            case .failure(let err):
                debugPrint(err.evaluate())
                return
            }
        }
    }
    
    var calories: Double {
        var newValue = 0.0
        for foodItem in foodItems {
            newValue += foodItem.getCalories()
        }
        return newValue
    }
    
    private var carbs: Double {
        var newValue = 0.0
        for foodItem in foodItems {
            newValue += foodItem.getCarbsInclSugars()
        }
        return newValue
    }
    
    private var sugars: Double {
        var newValue = 0.0
        for foodItem in foodItems {
            newValue += foodItem.getSugarsOnly()
        }
        return newValue
    }
    
    var fpus: FPU {
        var fpu = FPU(fpu: 0.0)
        for foodItem in foodItems {
            let tempFPU = fpu.fpu
            fpu = FPU(fpu: tempFPU + foodItem.getFPU().fpu)
        }
        return fpu
    }
    
    var caloriesPer100g: Double {
        calories / Double(amount) * 100
    }
    
    var carbsPer100g: Double {
        carbs / Double(amount) * 100
    }
    
    var sugarsPer100g: Double {
        sugars / Double(amount) * 100
    }
    
    var typicalAmounts: [TypicalAmountViewModel] {
        var typicalAmounts = [TypicalAmountViewModel]()
        if numberOfPortions > 0 {
            let portionWeight = amount / numberOfPortions
            for multiplier in 1...numberOfPortions {
                let portionAmount = portionWeight * multiplier
                let comment = "\(multiplier) \(NSLocalizedString("portion(s)", comment: "")) (\(multiplier)/\(numberOfPortions))"
                let typicalAmount = TypicalAmountViewModel(amount: portionAmount, comment: comment)
                typicalAmounts.append(typicalAmount)
            }
        }
        return typicalAmounts
    }
    
    enum CodingKeys: String, CodingKey {
        case composedFoodItem
        case id, amount, favorite, name, category, numberOfPortions, foodItems
    }
    
    init(name: String, category: FoodItemCategory, favorite: Bool) {
        self.name = name
        self.category = category
        self.favorite = favorite
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let composedFoodItem = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .composedFoodItem)
        category = try FoodItemCategory.init(rawValue: composedFoodItem.decode(String.self, forKey: .category)) ?? .product
        amount = try composedFoodItem.decode(Int.self, forKey: .amount)
        favorite = try composedFoodItem.decode(Bool.self, forKey: .favorite)
        name = try composedFoodItem.decode(String.self, forKey: .name)
        numberOfPortions = try composedFoodItem.decode(Int.self, forKey: .numberOfPortions)
        foodItems = try composedFoodItem.decode([FoodItemViewModel].self, forKey: .foodItems)
    }
    
    func add(foodItem: FoodItemViewModel) {
        if !foodItems.contains(foodItem) {
            foodItems.append(foodItem)
            amountAsString = String(amount + foodItem.amount) // amount will be set implicitely
        }
    }
    
    func remove(foodItem: FoodItemViewModel) {
        if let index = foodItems.firstIndex(of: foodItem) {
            // Substract amount of FoodItem removed
            let oldFoodItemAmount = foodItems[index].amount
            let newComposedFoodItemAmount = amount - oldFoodItemAmount
            amountAsString = String(newComposedFoodItemAmount)
            
            // Remove FoodItem
            foodItems[index].amountAsString = "0"
            foodItems.remove(at: index)
        }
    }
    
    func clear() {
        for foodItem in foodItems {
            foodItem.amountAsString = "0"
        }
        foodItems.removeAll()
        
        switch category {
        case .ingredient:
            name = NSLocalizedString(IngredientsListView.composedFoodItemName, comment: "")
        case .product:
            name = NSLocalizedString(ProductsListView.composedFoodItemName, comment: "")
        }
        
        favorite = false
        amount = 0
        numberOfPortions = 0
        cdComposedFoodItem = nil
    }
    
    func fill(from cdComposedFoodItem: ComposedFoodItem?, syncStrategy: IngredientsSyncStrategy) {
        if let cdComposedFoodItem = cdComposedFoodItem {
            // First clear existing data
            clear()
            
            // Check for missing FoodItems
            if let ingredients = cdComposedFoodItem.ingredients?.allObjects as? [Ingredient] {
                for ingredient in ingredients {
                    if let foodItem = ingredient.foodItem { // The FoodItem hasn't been deleted
                        foodItem.category = FoodItemCategory.ingredient.rawValue
                        let foodItemVM = FoodItemViewModel(from: foodItem)
                        foodItemVM.amount = Int(ingredient.amount)
                        foodItems.append(foodItemVM)
                    } else if syncStrategy == .createMissingFoodItems { // Create missing FoodItem
                        let foodItem = FoodItem.create(from: ingredient)
                        let foodItemVM = FoodItemViewModel(from: foodItem)
                        foodItemVM.amount = Int(ingredient.amount)
                        foodItems.append(foodItemVM)
                    }
                }
            }
            
            // Then fill from ComposedFoodItem
            self.name = cdComposedFoodItem.name ?? NSLocalizedString("- Unnamned -", comment: "")
            self.amountAsString = String(cdComposedFoodItem.amount)
            self.favorite = cdComposedFoodItem.favorite
            self.numberOfPortions = Int(cdComposedFoodItem.numberOfPortions)
            self.cdComposedFoodItem = cdComposedFoodItem
        }
    }
    
    func getCarbsInclSugars() -> Double {
        self.carbs
    }
    
    func getSugarsOnly() -> Double {
        self.sugars
    }
    
    func getRegularCarbs(when treatSugarsSeparately: Bool) -> Double {
        treatSugarsSeparately ? self.carbs - self.sugars : self.carbs
    }
    
    func getSugars(when treatSugarsSeparately: Bool) -> Double {
        treatSugarsSeparately ? self.sugars : 0
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var composedFoodItem = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .composedFoodItem)
        try composedFoodItem.encode(category.rawValue, forKey: .category)
        try composedFoodItem.encode(amount, forKey: .amount)
        try composedFoodItem.encode(favorite, forKey: .favorite)
        try composedFoodItem.encode(name, forKey: .name)
        try composedFoodItem.encode(numberOfPortions, forKey: .numberOfPortions)
        try composedFoodItem.encode(foodItems, forKey: .foodItems)
    }
}
