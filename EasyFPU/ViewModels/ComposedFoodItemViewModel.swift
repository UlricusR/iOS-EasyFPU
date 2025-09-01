//
//  ComposedProductViewModel.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 29.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class ComposedFoodItemViewModel: ObservableObject, Codable, Hashable, Identifiable {
    var id: UUID
    @Published var name: String
    @Published var foodCategory: FoodCategory? = nil
    var category: FoodItemCategory
    @Published var favorite: Bool
    @Published var amount: Int = 0
    @Published var numberOfPortions: Int = 0
    @Published var foodItemVMs = [FoodItemViewModel]() // TODO should later only be used for encoding/decoding purposes - rename!
    @Published var ingredients = [Ingredient]()
    
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
        for ingredient in ingredients {
            newValue += ingredient.calories
        }
        return newValue
    }
    
    private var carbs: Double {
        var newValue = 0.0
        for ingredient in ingredients {
            newValue += ingredient.carbsInclSugars
        }
        return newValue
    }
    
    private var sugars: Double {
        var newValue = 0.0
        for ingredient in ingredients {
            newValue += ingredient.sugarsOnly
        }
        return newValue
    }
    
    var fpus: FPU {
        var fpu = FPU(fpu: 0.0)
        for ingredient in ingredients {
            let tempFPU = fpu.fpu
            fpu = FPU(fpu: tempFPU + ingredient.fpus.fpu)
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
        self.amountAsString = String(amount)
        self.numberOfPortions = Int(cdComposedFoodItem.numberOfPortions)
        self.cdComposedFoodItem = cdComposedFoodItem
        
        for case let ingredient as Ingredient in cdComposedFoodItem.ingredients {
            // Add Ingredient to ComposedFoodItemVM
            ingredients.append(ingredient)
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
        let ingredients = try composedFoodItem.decode([FoodItemViewModel].self, forKey: .ingredients)
        for ingredient in ingredients {
            // Create the ingredients as FoodItemViewModels
            foodItemVMs.append(FoodItemViewModel(
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
    
    /// Checks if an associated Core Data ComposedFoodItem exists.
    /// - Returns: True if an associated Core Data ComposedFoodItem exists.
    func hasAssociatedComposedFoodItem() -> Bool {
        return cdComposedFoodItem != nil
    }
    
    /// Checks if the associated Core Data ComposedFoodItem is linked to a Core Data FoodItem.
    /// - Returns: True if both a ComposedFoodItem exists and is linked to a FoodItem.
    func hasAssociatedFoodItem() -> Bool {
        return cdComposedFoodItem?.foodItem != nil
    }
    
    /// Checks if a Core Data FoodItem or ComposedFoodItem with the name of this ComposedFoodItemViewModel exists.
    /// - Returns: True if a Core Data FoodItem or ComposedFoodItem with the same name exists, false otherwise.
    func nameExists() -> Bool {
        ComposedFoodItem.getComposedFoodItemByName(name: self.name) != nil || FoodItem.getFoodItemsByName(name: self.name) != nil
    }
    
    /// Saves the ComposedFoodItemViewModel as Core Data ComposedFoodItem.
    /// - Returns: False if no ingredients could be found in the ComposedFoodItemViewModel, otherwise true.
    func save() -> Bool {
        // Check for an existing FoodItem with same ID
        if let existingComposedFoodItem = ComposedFoodItem.getComposedFoodItemByID(id: self.id) {
            if ComposedFoodItemViewModel.areIdentical(cdComposedFoodItem: existingComposedFoodItem, composedFoodItemVM: self) {
                // In case of an identical existing ComposedFoodItem, no new ComposedFoodItem needs to be created
                return true
            } else {
                // Otherwise we need to create a new UUID before saving the VM to Core Data
                self.id = UUID()
            }
        }
        
        guard let cdComposedFoodItem = ComposedFoodItem.create(from: self, saveContext: true) else { return false }
        self.cdComposedFoodItem = cdComposedFoodItem
        return true
    }
    
    /// Adds a FoodItem to the ComposedFoodItem, if it doesn't exist yet. - TODO remove after replacing with add(Ingredient)
    /// - Parameter foodItem: The food item to be added.
    func add(foodItem: FoodItemViewModel) {
        if !foodItemVMs.contains(foodItem) {
            foodItemVMs.append(foodItem)
            amountAsString = String(amount + foodItem.amount) // amount will be set implicitely
        }
    }
    
    /// Adds a FoodItem to the ComposedFoodItem, if it doesn't exist yet.
    /// - Parameter foodItem: The food item to be added.
    func add(ingredient: Ingredient) {
        if !ingredients.contains(ingredient) {
            ingredients.append(ingredient)
            amountAsString = String(amount + Int(ingredient.amount)) // amount will be set implicitely
        }
    }
    
    /// Removes a FoodItem from the ComposedFoodItem, if it exists. - TODO remove after replacing with remove(Ingredient)
    /// - Parameter foodItem: The food item to be removed.
    func remove(foodItem: FoodItemViewModel) {
        if let index = foodItemVMs.firstIndex(of: foodItem) {
            // Substract amount of FoodItem removed
            let oldFoodItemAmount = foodItemVMs[index].amount
            let newComposedFoodItemAmount = amount - oldFoodItemAmount
            amountAsString = String(newComposedFoodItemAmount)
            
            // Remove FoodItem
            foodItemVMs[index].amountAsString = "0"
            foodItemVMs.remove(at: index)
        }
    }
    
    /// Removes a FoodItem from the ComposedFoodItem, if it exists.
    /// - Parameter foodItem: The food item to be removed.
    func remove(ingredient: Ingredient) {
        if let index = ingredients.firstIndex(of: ingredient) {
            // Substract amount of FoodItem removed
            let oldFoodItemAmount = Int(ingredients[index].amount)
            let newComposedFoodItemAmount = amount - oldFoodItemAmount
            amountAsString = String(newComposedFoodItemAmount)
            
            // Remove FoodItem
            ingredients[index].amount = 0
            ingredients.remove(at: index)
        }
    }
    
    func duplicate() {
        if let existingComposedFoodItem = cdComposedFoodItem {
            _ = ComposedFoodItem.duplicate(existingComposedFoodItem)
        }
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
        for ingredient in ingredients {
            ingredient.amount = 0
        }
        ingredients.removeAll()
        amount = 0
    }
    
    func getCarbsInclSugars() -> Double {
        self.carbs
    }
    
    func getSugarsOnly() -> Double {
        self.sugars
    }
    
    func getRegularCarbs(treatSugarsSeparately: Bool) -> Double {
        treatSugarsSeparately ? self.carbs - self.sugars : self.carbs
    }
    
    func getSugars(treatSugarsSeparately: Bool) -> Double {
        treatSugarsSeparately ? self.sugars : 0
    }
    
    static func areIdentical(cdComposedFoodItem: ComposedFoodItem, composedFoodItemVM: ComposedFoodItemViewModel) -> Bool {
        // Compare related food items
        let cdIngredients = cdComposedFoodItem.ingredients.allObjects as! [Ingredient]
        for foodItem in composedFoodItemVM.foodItemVMs {
            let matchingCDFoodItems = cdIngredients.map {
                $0.caloriesPer100g == foodItem.caloriesPer100g &&
                $0.carbsPer100g == foodItem.carbsPer100g &&
                $0.sugarsPer100g == foodItem.sugarsPer100g &&
                $0.amount == foodItem.amount
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
        try composedFoodItem.encode(foodItemVMs, forKey: .ingredients)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ComposedFoodItemViewModel, rhs: ComposedFoodItemViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    static func sampleData() -> ComposedFoodItemViewModel {
        ComposedFoodItemViewModel(id: UUID(), name: "Sample Composed Food Item", foodCategory: nil, category: .product, favorite: false)
    }
}
