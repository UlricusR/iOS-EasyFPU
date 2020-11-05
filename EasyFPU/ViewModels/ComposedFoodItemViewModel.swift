//
//  ComposedProductViewModel.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 29.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class ComposedFoodItemViewModel: ObservableObject, VariableAmountItem {
    var name: String
    var category: FoodItemCategory
    var favorite: Bool
    @Published var amount: Int = 0
    @Published var numberOfPortions: Int = 1
    var foodItems = [FoodItemViewModel]()
    
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
    
    static let `default` = ComposedFoodItemViewModel(name: "Default", category: .product, favorite: false)
    
    init(name: String, category: FoodItemCategory, favorite: Bool) {
        self.name = name
        self.category = category
        self.favorite = favorite
    }
    
    init(from cdComposedFoodItem: ComposedFoodItem) {
        self.name = cdComposedFoodItem.name ?? NSLocalizedString("- Unnamned -", comment: "")
        self.category = FoodItemCategory.init(rawValue: cdComposedFoodItem.category ?? FoodItemCategory.product.rawValue) ?? FoodItemCategory.product // Default is product
        self.favorite = cdComposedFoodItem.favorite
        self.numberOfPortions = Int(cdComposedFoodItem.numberOfPortions)
        
        if let cdIngredients = cdComposedFoodItem.ingredients {
            for cdIngredient in cdIngredients {
                let castedCDIngredient = cdIngredient as! Ingredient
                let foodItem = FoodItemViewModel(from: castedCDIngredient)
                foodItems.append(foodItem)
            }
        }
    }
    
    func add(foodItem: FoodItemViewModel) {
        foodItems.append(foodItem)
        amountAsString = String(amount + foodItem.amount) // amount will be set implicitely
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
    
    func remove(foodItem: FoodItemViewModel) {
        foodItem.amountAsString = "0"
        foodItem.cdFoodItem?.amount = 0
        if let index = foodItems.firstIndex(of: foodItem) {
            foodItems.remove(at: index)
        }
        try? AppDelegate.viewContext.save()
    }
    
    func clear() {
        for foodItem in foodItems {
            foodItem.amountAsString = "0"
            foodItem.cdFoodItem?.amount = 0
        }
        foodItems.removeAll()
        try? AppDelegate.viewContext.save()
    }
}
