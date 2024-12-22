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
    
    /// Creates a FoodItemViewModel (also applicable for ingredients). Don't pass an id if you want to create a new FoodItemViewModel,
    /// pass an id if you want a duplicate.
    /// - Parameter id: If an UUID is passed, it will be used for the FoodItemViewModel, otherwise a new UUID will be created.
    /// - Returns: The created FoodItemViewModel.
    func createFoodItemVM(id: UUID = UUID()) throws -> FoodItemViewModel {
        return try createFoodItemVM(foodItem: self.foodItem, id: id)
    }
    
    private func createFoodItemVM(foodItem: Dictionary<String, String>, id: UUID) throws -> FoodItemViewModel {
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
        
        let foodItemVM = FoodItemViewModel(
            id: id,
            name: name,
            category: category!,
            favorite: favorite,
            caloriesPer100g: caloriesPer100g!,
            carbsPer100g: carbsPer100g!,
            sugarsPer100g: sugarsPer100g!,
            amount: amount!,
            sourceID: nil,
            sourceDB: nil
        )
        return foodItemVM
    }
    
    /// Creates a ComposedFoodItemViewModel with 5 attached ingredients (as FoodItemViewModels).
    /// Don't pass an id if you want to create a new ComposedFoodItemViewModel, pass an id if you want a duplicate.
    /// - Parameter id: The id to be used for the ComposedFoodItemViewModel.
    /// - Returns: A ComposedFoodItemViewModel with 5 attached ingredients.
    func createComposedFoodItemViewModel(id: UUID = UUID()) throws -> ComposedFoodItemViewModel {
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
        
        let amount = composedFoodItem["amount"]!
        
        let composedFoodItemViewModel = ComposedFoodItemViewModel(
            id: id,
            name: name,
            category: category!,
            favorite: favorite
        )
        
        composedFoodItemViewModel.numberOfPortions = numberOfPortions!
        composedFoodItemViewModel.amountAsString = amount
        
        // Attach ingredients
        composedFoodItemViewModel.foodItemVMs.append(try createFoodItemVM(foodItem: self.ingredient1, id: UUID()))
        composedFoodItemViewModel.foodItemVMs.append(try createFoodItemVM(foodItem: self.ingredient2, id: UUID()))
        composedFoodItemViewModel.foodItemVMs.append(try createFoodItemVM(foodItem: self.ingredient3, id: UUID()))
        composedFoodItemViewModel.foodItemVMs.append(try createFoodItemVM(foodItem: self.ingredient4, id: UUID()))
        composedFoodItemViewModel.foodItemVMs.append(try createFoodItemVM(foodItem: self.ingredient5, id: UUID()))
        
        // Return the complete VM
        return composedFoodItemViewModel
    }
    
    func getTwoIngredients() throws -> [FoodItemViewModel] {
        var ingredients = [FoodItemViewModel]()
        ingredients.append(try createFoodItemVM(foodItem: self.ingredient6, id: UUID()))
        ingredients.append(try createFoodItemVM(foodItem: self.ingredient7, id: UUID()))
        return ingredients
    }
    
    func createFoodItemViewModel(for composedFoodItemViewModel: ComposedFoodItemViewModel) throws -> FoodItemViewModel {
        var caloriesPer100g: Double = 0
        var carbsPer100g: Double = 0
        var sugarsPer100g: Double = 0
        var amount: Int = 0
        
        for ingredient in composedFoodItemViewModel.foodItemVMs {
            caloriesPer100g += Double(ingredient.amount) * ingredient.caloriesPer100g
            carbsPer100g += Double(ingredient.amount) * ingredient.carbsPer100g
            sugarsPer100g += Double(ingredient.amount) * ingredient.sugarsPer100g
            amount += ingredient.amount
        }
        
        try #require(amount > 0, "Amount of food item must be greater than zero.")
        
        caloriesPer100g = caloriesPer100g / Double(amount)
        carbsPer100g = carbsPer100g / Double(amount)
        sugarsPer100g = sugarsPer100g / Double(amount)
        
        let foodItemVM = FoodItemViewModel(
            id: composedFoodItemViewModel.id,
            name: composedFoodItemViewModel.name,
            category: composedFoodItemViewModel.category,
            favorite: composedFoodItemViewModel.favorite,
            caloriesPer100g: caloriesPer100g,
            carbsPer100g: carbsPer100g,
            sugarsPer100g: sugarsPer100g,
            amount: amount,
            sourceID: nil,
            sourceDB: nil
        )
        return foodItemVM
    }
    
    /// Adds four TypicalAmountViewModels to the passed FoodItemViewModel.
    /// - Parameter foodItem: The FoodItemViewModel to add the TypicalAmountViewModels to.
    func addTypicalAmounts(to foodItem: FoodItemViewModel) throws {
        let typicalAmountVMs = try getTypicalAmounts()
        for typicalAmountVM in typicalAmountVMs {
            foodItem.typicalAmounts.append(typicalAmountVM)
        }
    }
    
    /// Creates 4 TypicalAmountViewModels.
    /// - Returns: An array of four TypicalAmountViewModels.
    func getTypicalAmounts() throws -> [TypicalAmountViewModel] {
        var typicalAmountVMs = [TypicalAmountViewModel]()
        typicalAmountVMs.append(try createTypicalAmountViewModel(typicalAmount: typicalAmount1))
        typicalAmountVMs.append(try createTypicalAmountViewModel(typicalAmount: typicalAmount2))
        typicalAmountVMs.append(try createTypicalAmountViewModel(typicalAmount: typicalAmount3))
        typicalAmountVMs.append(try createTypicalAmountViewModel(typicalAmount: typicalAmount4))
        return typicalAmountVMs
    }
    
    private func createTypicalAmountViewModel(typicalAmount: Dictionary<String, String>) throws -> TypicalAmountViewModel {
        try #require(typicalAmount["amount"] != nil)
        try #require(typicalAmount["comment"] != nil)
        
        let amount = Int(typicalAmount["amount"]!)
        try #require(amount != nil)
        
        let comment = typicalAmount["comment"]!
        
        let typicalAmountViewModel = TypicalAmountViewModel(amount: amount!, comment: comment)
        
        return typicalAmountViewModel
    }
}
