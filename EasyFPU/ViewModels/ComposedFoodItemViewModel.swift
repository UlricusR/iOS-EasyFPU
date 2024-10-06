//
//  ComposedProductViewModel.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 29.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class ComposedFoodItemViewModel: ObservableObject, Codable, Identifiable, VariableAmountItem {
    var id: UUID
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
        case id, name, category, favorite, amount, numberOfPortions
        case ingredients
    }
    
    init(id: UUID, name: String, category: FoodItemCategory, favorite: Bool) {
        self.id = id
        self.name = name
        self.category = category
        self.favorite = favorite
    }
    
    init(from cdComposedFoodItem: ComposedFoodItem) {
        self.id = cdComposedFoodItem.id // Same ID as the Core Data ComposedFoodItem
        self.name = cdComposedFoodItem.name
        self.category = FoodItemCategory.product
        self.favorite = cdComposedFoodItem.favorite
        self.amount = Int(cdComposedFoodItem.amount)
        self.amountAsString = String(amount)
        self.numberOfPortions = Int(cdComposedFoodItem.numberOfPortions)
        self.cdComposedFoodItem = cdComposedFoodItem
        
        for ingredient in cdComposedFoodItem.ingredients {
            let ingredient = ingredient as! Ingredient
            var newCDFoodItem: FoodItem
            if let cdFoodItem = FoodItem.getFoodItemByID(ingredient.id.uuidString) {
                // A FoodItem exists, so use it
                newCDFoodItem = cdFoodItem
            } else {
                // Create a new FoodItem
                newCDFoodItem = FoodItem.create(from: self)
            }
            
            // Add the amount
            let foodItemVM = FoodItemViewModel(from: newCDFoodItem)
            let amount = Int(ingredient.amount)
            foodItemVM.amount = amount
            
            // Add FoodItemVM to ComposedFoodItemVM
            foodItems.append(foodItemVM)
        }
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let composedFoodItem = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .composedFoodItem)
        let uuidString = try composedFoodItem.decode(String.self, forKey: .id)
        id = UUID(uuidString: uuidString) ?? UUID()
        category = .product
        amount = try composedFoodItem.decode(Int.self, forKey: .amount)
        favorite = try composedFoodItem.decode(Bool.self, forKey: .favorite)
        name = try composedFoodItem.decode(String.self, forKey: .name)
        numberOfPortions = try composedFoodItem.decode(Int.self, forKey: .numberOfPortions)
        
        // Load the ingredients
        let ingredients = try composedFoodItem.decode([FoodItemViewModel].self, forKey: .ingredients)
        for ingredient in ingredients {
            // Create the ingredients as FoodItemViewModels
            foodItems.append(FoodItemViewModel(
                id: ingredient.id,
                name: ingredient.name,
                category: .ingredient,
                favorite: ingredient.favorite,
                caloriesPer100g: ingredient.caloriesPer100g,
                carbsPer100g: ingredient.carbsPer100g,
                sugarsPer100g: ingredient.sugarsPer100g,
                amount: ingredient.amount
            ))
        }
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
    
    func duplicate() {
        // Create the duplicate in Core Data
        _ = ComposedFoodItem.duplicate(self)
    }
    
    func exportToURL() -> URL? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let encoded = try? encoder.encode(self) else { return nil }
        
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        guard let path = documents?.appendingPathComponent("/\(name).recipe") else {
            return nil
        }
        
        do {
            try encoded.write(to: path, options: .atomicWrite)
            return path
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    /**
     Resets the entire ComposedFoodItemViewModel, i.e., clears ingredients, resets values, removes link to Core Data ComposedFoodItem and creates a new ID.
     */
    func clear() {
        // Clear ingredients
        clearIngredients()
        
        // Reset values and create new UUID
        id = UUID()
        name = NSLocalizedString("Composed product", comment: "")
        favorite = false
        numberOfPortions = 0
        cdComposedFoodItem = nil
    }
    
    /**
     Clears all ingredients and sets the amount to 0.
     */
    func clearIngredients() {
        for foodItem in foodItems {
            foodItem.amountAsString = "0"
        }
        foodItems.removeAll()
        amount = 0
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
        try composedFoodItem.encode(id, forKey: .id)
        try composedFoodItem.encode(name, forKey: .name)
        try composedFoodItem.encode(favorite, forKey: .favorite)
        try composedFoodItem.encode(amount, forKey: .amount)
        try composedFoodItem.encode(numberOfPortions, forKey: .numberOfPortions)
        try composedFoodItem.encode(foodItems, forKey: .ingredients)
    }
}
