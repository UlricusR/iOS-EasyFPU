//
//  DataSimulator.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 15/10/2024.
//  Copyright © 2024 Ulrich Rüth. All rights reserved.
//

import Foundation
import Testing
@testable import EasyFPU

struct DataFactory {
    private var foodItem: [String: String] = [
        "amount": "0",
        "name": "Pizzateig",
        "caloriesPer100g": "219.17",
        "carbsPer100g": "44.25",
        "sugarsPer100g": "0.31",
        "category": "Product",
        "favorite": "1"
    ]
    
    private var composedFoodItem: [String: String] = [
        "amount": "816",
        "name": "Pizzateig", // No related FoodItem
        "category": "Product",
        "favorite": "1",
        "numberOfPortions": "8"
    ]
    
    private var ingredient1: [String: String] = [
        "amount": "500",
        "name": "Weizenmehl 405",
        "caloriesPer100g": "343",
        "carbsPer100g": "72",
        "sugarsPer100g": "0.7",
        "category": "Ingredient",
        "favorite": "0"
    ]
    
    private var ingredient2: [String: String] = [
        "amount": "10",
        "name": "Backhefe trocken",
        "caloriesPer100g": "320",
        "carbsPer100g": "11",
        "sugarsPer100g": "0",
        "category": "Ingredient",
        "favorite": "0"
    ]
    
    private var ingredient3: [String: String] = [ // For composedFoodItem3, for foodItem3forComposedFoodItem3
        "amount": "5",
        "name": "Olivenöl",
        "caloriesPer100g": "828",
        "carbsPer100g": "0",
        "sugarsPer100g": "0",
        "category": "Ingredient",
        "favorite": "0"
    ]
    
    private var ingredient4: [String: String] = [
        "amount": "1",
        "name": "Salz",
        "caloriesPer100g": "0",
        "carbsPer100g": "0",
        "sugarsPer100g": "0",
        "category": "Ingredient",
        "favorite": "0"
    ]
    
    private var ingredient5: [String: String] = [
        "amount": "300",
        "name": "Wasser",
        "caloriesPer100g": "0",
        "carbsPer100g": "0",
        "sugarsPer100g": "0",
        "category": "Ingredient",
        "favorite": "0"
    ]
    
    private var ingredient6: [String: String] = [
        "amount": "5",
        "name": "Backpulver",
        "caloriesPer100g": "90",
        "carbsPer100g": "22",
        "sugarsPer100g": "0",
        "category": "Ingredient",
        "favorite": "1"
    ]
    
    private var ingredient7:[String: String] = [
        "amount": "150",
        "name": "Mozzarella",
        "caloriesPer100g": "238",
        "carbsPer100g": "2",
        "sugarsPer100g": "1",
        "category": "Ingredient",
        "favorite": "0"
    ]
    
    private var typicalAmount1: [String: String] = [
        "amount": "100",
        "comment": "Comment 1"
    ]
    
    private var typicalAmount2: [String: String] = [
        "amount": "200",
        "comment": "Comment 2"
    ]
    
    private var typicalAmount3: [String: String] = [
        "amount": "300",
        "comment": "Comment 3"
    ]
    
    private var typicalAmount4: [String: String] = [
        "amount": "400",
        "comment": "Comment 4"
    ]
    
    static var shared: DataFactory {
        DataFactory()
    }
    
    /// Creates a FoodItemPersistence (also applicable for ingredients). Don't pass an id if you want to create a new FoodItemViewModel,
    /// pass an id if you want a duplicate.
    /// - Parameter id: If an UUID is passed, it will be used for the FoodItemViewModel, otherwise a new UUID will be created.
    /// - Returns: The created FoodItemPersistence.
    func createFoodItemPersistence(id: UUID = UUID()) throws -> FoodItemPersistence {
        return try createFoodItemPersistence(foodItem: self.foodItem, id: id)
    }
    
    private func createFoodItemPersistence(foodItem: Dictionary<String, String>, id: UUID) throws -> FoodItemPersistence {
        try #require(foodItem["name"] != nil)
        try #require(foodItem["category"] != nil)
        try #require(foodItem["favorite"] != nil)
        try #require(foodItem["caloriesPer100g"] != nil)
        try #require(foodItem["carbsPer100g"] != nil)
        try #require(foodItem["sugarsPer100g"] != nil)
        try #require(foodItem["amount"] != nil)
        
        let name = foodItem["name"]!
        
        let category = FoodItemCategory(rawValue: foodItem["category"]!)
        try #require(category != nil)
        
        let favorite = foodItem["favorite"]! == "0" ? false : true
        
        let caloriesPer100g = Double(foodItem["caloriesPer100g"]!)
        try #require(caloriesPer100g != nil)
        
        let carbsPer100g = Double(foodItem["carbsPer100g"]!)
        try #require(carbsPer100g != nil)
        
        let sugarsPer100g = Double(foodItem["sugarsPer100g"]!)
        try #require(sugarsPer100g != nil)
        
        let amount = Int(foodItem["amount"]!)
        try #require(amount != nil)
        
        let foodItemPersistence = FoodItemPersistence(
            id: id,
            name: name,
            foodCategory: nil,
            category: category!,
            favorite: favorite,
            caloriesPer100g: caloriesPer100g!,
            carbsPer100g: carbsPer100g!,
            sugarsPer100g: sugarsPer100g!,
            amount: amount!,
            sourceID: nil,
            sourceDB: nil
        )
        return foodItemPersistence
    }
    
    /// Creates a ComposedFoodItemPersistence with 5 attached ingredients (as FoodItemPersistence).
    /// Don't pass an id if you want to create a new ComposedFoodItemPersistence, pass an id if you want a duplicate.
    /// - Parameter id: The id to be used for the ComposedFoodItemPersistence.
    /// - Returns: A ComposedFoodItemPersistence with 5 attached ingredients.
    func createComposedFoodItemPersistence(id: UUID = UUID()) throws -> ComposedFoodItemPersistence {
        try #require(composedFoodItem["name"] != nil)
        try #require(composedFoodItem["category"] != nil)
        try #require(composedFoodItem["favorite"] != nil)
        try #require(composedFoodItem["numberOfPortions"] != nil)
        try #require(composedFoodItem["amount"] != nil)
        
        let name = composedFoodItem["name"]!
        
        let category = FoodItemCategory(rawValue: composedFoodItem["category"]!)
        try #require(category != nil)
        
        let favorite = composedFoodItem["favorite"]! == "0" ? false : true
        
        let numberOfPortions = Int(composedFoodItem["numberOfPortions"]!)
        try #require(numberOfPortions != nil)
        
        let amount = Int(composedFoodItem["amount"]!)
        try #require(amount != nil)
        
        let composedFoodItemPersistence = ComposedFoodItemPersistence(
            id: id,
            name: name,
            foodCategory: nil,
            category: category!,
            favorite: favorite
        )
        
        composedFoodItemPersistence.numberOfPortions = numberOfPortions!
        composedFoodItemPersistence.amount = amount!
        
        // Attach ingredients
        composedFoodItemPersistence.ingredients.append(try createFoodItemPersistence(foodItem: self.ingredient1, id: UUID()))
        composedFoodItemPersistence.ingredients.append(try createFoodItemPersistence(foodItem: self.ingredient2, id: UUID()))
        composedFoodItemPersistence.ingredients.append(try createFoodItemPersistence(foodItem: self.ingredient3, id: UUID()))
        composedFoodItemPersistence.ingredients.append(try createFoodItemPersistence(foodItem: self.ingredient4, id: UUID()))
        composedFoodItemPersistence.ingredients.append(try createFoodItemPersistence(foodItem: self.ingredient5, id: UUID()))
        
        // Return the complete VM
        return composedFoodItemPersistence
    }
    
    func getTwoIngredients() throws -> [FoodItemPersistence] {
        var ingredients = [FoodItemPersistence]()
        ingredients.append(try createFoodItemPersistence(foodItem: self.ingredient6, id: UUID()))
        ingredients.append(try createFoodItemPersistence(foodItem: self.ingredient7, id: UUID()))
        return ingredients
    }
    
    func createFoodItemPersistence(for composedFoodItemPersistence: ComposedFoodItemPersistence) throws -> FoodItemPersistence {
        var caloriesPer100g: Double = 0
        var carbsPer100g: Double = 0
        var sugarsPer100g: Double = 0
        var amount: Int = 0
        
        for ingredient in composedFoodItemPersistence.ingredients {
            caloriesPer100g += Double(ingredient.amount) * ingredient.caloriesPer100g
            carbsPer100g += Double(ingredient.amount) * ingredient.carbsPer100g
            sugarsPer100g += Double(ingredient.amount) * ingredient.sugarsPer100g
            amount += ingredient.amount
        }
        
        try #require(amount > 0, "Amount of food item must be greater than zero.")
        
        caloriesPer100g = caloriesPer100g / Double(amount)
        carbsPer100g = carbsPer100g / Double(amount)
        sugarsPer100g = sugarsPer100g / Double(amount)
        
        let foodItemPersistence = FoodItemPersistence(
            id: composedFoodItemPersistence.id,
            name: composedFoodItemPersistence.name,
            foodCategory: nil,
            category: composedFoodItemPersistence.category,
            favorite: composedFoodItemPersistence.favorite,
            caloriesPer100g: caloriesPer100g,
            carbsPer100g: carbsPer100g,
            sugarsPer100g: sugarsPer100g,
            amount: amount,
            sourceID: nil,
            sourceDB: nil
        )
        return foodItemPersistence
    }
    
    /// Adds four TypicalAmountViewModels to the passed FoodItemViewModel.
    /// - Parameter foodItem: The FoodItemViewModel to add the TypicalAmountViewModels to.
    func addTypicalAmounts(to foodItem: FoodItemPersistence) throws {
        let typicalAmounts = try getTypicalAmounts()
        for typicalAmount in typicalAmounts {
            foodItem.typicalAmounts.append(typicalAmount)
        }
    }
    
    /// Creates 4 TypicalAmountViewModels.
    /// - Returns: An array of four TypicalAmountViewModels.
    func getTypicalAmounts() throws -> [TypicalAmountPersistence] {
        var typicalAmounts = [TypicalAmountPersistence]()
        typicalAmounts.append(try createTypicalAmountPersistence(typicalAmount: typicalAmount1))
        typicalAmounts.append(try createTypicalAmountPersistence(typicalAmount: typicalAmount2))
        typicalAmounts.append(try createTypicalAmountPersistence(typicalAmount: typicalAmount3))
        typicalAmounts.append(try createTypicalAmountPersistence(typicalAmount: typicalAmount4))
        return typicalAmounts
    }
    
    private func createTypicalAmountPersistence(typicalAmount: Dictionary<String, String>) throws -> TypicalAmountPersistence {
        try #require(typicalAmount["amount"] != nil)
        try #require(typicalAmount["comment"] != nil)
        
        let amount = Int(typicalAmount["amount"]!)
        try #require(amount != nil)
        
        let comment = typicalAmount["comment"]!
        
        let typicalAmountPersistence = TypicalAmountPersistence(amount: amount!, comment: comment)
        
        return typicalAmountPersistence
    }
}
