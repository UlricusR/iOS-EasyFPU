//
//  ComposedProductViewModel.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 29.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class ComposedFoodItemPersistence: Codable, Hashable, Identifiable {
    var id: UUID
    var name: String
    var foodCategory: FoodCategory? = nil
    var category: FoodItemCategory
    var favorite: Bool
    var amount: Int = 0
    var numberOfPortions: Int = 0
    var ingredients = [FoodItemPersistence]()
    
    var calories: Double {
        var newValue = 0.0
        for ingredient in ingredients {
            newValue += ingredient.getCalories()
        }
        return newValue
    }
    
    private var carbs: Double {
        var newValue = 0.0
        for ingredient in ingredients {
            newValue += ingredient.getCarbsInclSugars()
        }
        return newValue
    }
    
    private var sugars: Double {
        var newValue = 0.0
        for ingredient in ingredients {
            newValue += ingredient.getSugarsOnly()
        }
        return newValue
    }
    
    var fpus: FPU {
        var fpu = FPU(fpu: 0.0)
        for ingredient in ingredients {
            let tempFPU = fpu.fpu
            fpu = FPU(fpu: tempFPU + ingredient.getFPU().fpu)
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
    
    var typicalAmounts: [TypicalAmountPersistence] {
        var typicalAmounts = [TypicalAmountPersistence]()
        if numberOfPortions > 0 {
            let portionWeight = amount / numberOfPortions
            for multiplier in 1...numberOfPortions {
                let portionAmount = portionWeight * multiplier
                let comment = "\(multiplier) \(NSLocalizedString("portion(s)", comment: "")) (\(multiplier)/\(numberOfPortions))"
                let typicalAmount = TypicalAmountPersistence(amount: portionAmount, comment: comment)
                typicalAmounts.append(typicalAmount)
            }
        }
        return typicalAmounts
    }
    
    enum CodingKeys: String, CodingKey {
        case composedFoodItem
        case id, name, foodCategory, category, favorite, amount, numberOfPortions
        case ingredients
    }
    
    init(id: UUID, name: String, foodCategory: FoodCategory?, category: FoodItemCategory, favorite: Bool) {
        self.id = id
        self.name = name
        self.foodCategory = foodCategory
        self.category = category
        self.favorite = favorite
    }
    
    init(from cdComposedFoodItem: ComposedFoodItem) {
        self.id = cdComposedFoodItem.id // Same ID as the Core Data ComposedFoodItem
        self.name = cdComposedFoodItem.name
        self.foodCategory = cdComposedFoodItem.foodCategory
        self.category = FoodItemCategory.product
        self.favorite = cdComposedFoodItem.favorite
        self.amount = Int(cdComposedFoodItem.amount)
        self.numberOfPortions = Int(cdComposedFoodItem.numberOfPortions)
        
        for case let ingredient as Ingredient in cdComposedFoodItem.ingredients {
            // Add Ingredient to ComposedFoodItemVM
            if let foodItemVM = FoodItemPersistence(from: ingredient) {
                ingredients.append(foodItemVM)
            }
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
        if let foodCategoryName = try? composedFoodItem.decode(String.self, forKey: .foodCategory) {
            foodCategory = FoodCategory.getFoodCategoriesByName(name: foodCategoryName, category: category)?.first
        }
        numberOfPortions = try composedFoodItem.decode(Int.self, forKey: .numberOfPortions)
        
        // Load the ingredients
        let ingredients = try composedFoodItem.decode([FoodItemPersistence].self, forKey: .ingredients)
        for ingredient in ingredients {
            // Create the ingredients as FoodItemViewModels
            self.ingredients.append(FoodItemPersistence(
                id: ingredient.id,
                name: ingredient.name,
                foodCategory: ingredient.foodCategory,
                category: .ingredient,
                favorite: ingredient.favorite,
                caloriesPer100g: ingredient.caloriesPer100g,
                carbsPer100g: ingredient.carbsPer100g,
                sugarsPer100g: ingredient.sugarsPer100g,
                amount: ingredient.amount,
                sourceID: nil,
                sourceDB: nil
            ))
        }
    }
    
    /// Saves the ComposedFoodItemViewModel as Core Data ComposedFoodItem.
    /// - Returns: False if no ingredients could be found in the ComposedFoodItemViewModel, otherwise true.
    func save() -> Bool {
        // Check for an existing FoodItem with same ID
        if let existingComposedFoodItem = ComposedFoodItem.getComposedFoodItemByID(id: self.id) {
            if ComposedFoodItemPersistence.areIdentical(cdComposedFoodItem: existingComposedFoodItem, composedFoodItemVM: self) {
                // In case of an identical existing ComposedFoodItem, no new ComposedFoodItem needs to be created
                return true
            } else {
                // Otherwise we need to create a new UUID before saving the VM to Core Data
                self.id = UUID()
            }
        }
        
        guard ComposedFoodItem.create(from: self, saveContext: true) != nil else { return false }
        return true
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
    
    static func areIdentical(cdComposedFoodItem: ComposedFoodItem, composedFoodItemVM: ComposedFoodItemPersistence) -> Bool {
        // Compare related food items
        let cdIngredients = cdComposedFoodItem.ingredients.allObjects as! [Ingredient]
        for ingredient in composedFoodItemVM.ingredients {
            let matchingCDFoodItems = cdIngredients.map {
                $0.caloriesPer100g == ingredient.caloriesPer100g &&
                $0.carbsPer100g == ingredient.carbsPer100g &&
                $0.sugarsPer100g == ingredient.sugarsPer100g &&
                $0.amount == ingredient.amount
            }
            
            if matchingCDFoodItems.isEmpty { return false }
        }
        
        return true
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var composedFoodItem = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .composedFoodItem)
        try composedFoodItem.encode(id, forKey: .id)
        try composedFoodItem.encode(name, forKey: .name)
        try composedFoodItem.encode(foodCategory?.name, forKey: .foodCategory)
        try composedFoodItem.encode(favorite, forKey: .favorite)
        try composedFoodItem.encode(amount, forKey: .amount)
        try composedFoodItem.encode(numberOfPortions, forKey: .numberOfPortions)
        try composedFoodItem.encode(ingredients, forKey: .ingredients)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ComposedFoodItemPersistence, rhs: ComposedFoodItemPersistence) -> Bool {
        lhs.id == rhs.id
    }
    
    static func sampleData() -> ComposedFoodItemPersistence {
        ComposedFoodItemPersistence(id: UUID(), name: "Sample Composed Food Item", foodCategory: nil, category: .product, favorite: false)
    }
}
