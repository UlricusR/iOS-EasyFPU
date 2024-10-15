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
    var foodItem1: FoodItemViewModel
    var foodItem1duplicate: FoodItemViewModel
    var foodItem2: FoodItemViewModel
    var foodItem3: FoodItemViewModel
    var foodItem4: FoodItemViewModel
    var ingredient1noReference: FoodItemViewModel
    var ingredient2forFoodItem2: FoodItemViewModel
    var ingredient3forFoodItem3: FoodItemViewModel
    var ingredient4forFoodItem3: FoodItemViewModel
    var composedFoodItem1: ComposedFoodItemViewModel
    var composedFoodItem2: ComposedFoodItemViewModel
    
    static var shared: DataFactory {
        do {
            return try DataFactory()
        } catch {
            fatalError("Could not create DataFactory: \(error)")
        }
    }
    
    private init() throws {
        // Define data
        try foodItem1 = DataFactory.createFoodItemVM(foodItem: [
            "name": "Alpenzwerg light",
            "caloriesPer100g": "72",
            "carbsPer100g": "10.4",
            "sugarsPer100g": "9.4",
            "category": "Product",
            "favorite": "0",
            "id": "220458AD-3216-45A2-9FC3-32285A2A36D0",
            "amount": "0"
        ])
        
        try foodItem1duplicate = DataFactory.createFoodItemVM(foodItem: [
            "name": "Alpenzwerg",
            "caloriesPer100g": "72",
            "carbsPer100g": "10.4",
            "sugarsPer100g": "9.4",
            "category": "Product",
            "favorite": "0",
            "id": "220458AD-3216-45A2-9FC3-32285A2A36D0",
            "amount": "0"
        ])
        
        try foodItem2 = DataFactory.createFoodItemVM(foodItem: [
            "name": "Backpulver",
            "caloriesPer100g": "90",
            "carbsPer100g": "22",
            "sugarsPer100g": "0",
            "category": "Ingredient",
            "favorite": "1",
            "id": "E446505E-7556-49A9-9397-91C422B9D5E2",
            "amount": "0"
        ])
        
        try foodItem3 = DataFactory.createFoodItemVM(foodItem: [
            "name": "Eier (GutBio)",
            "caloriesPer100g": "152.4",
            "carbsPer100g": "0.6",
            "sugarsPer100g": "0.5",
            "category": "Product", // should be Ingredient
            "favorite": "0",
            "id": "371E5B5E-95E4-43B4-9927-8173DD01721B",
            "amount": "0"
        ])
        
        try foodItem4 = DataFactory.createFoodItemVM(foodItem: [
            "name": "Marmorkuchen mit Schokoglasur",
            "caloriesPer100g": "384.546",
            "carbsPer100g": "42.25",
            "sugarsPer100g": "23.769",
            "category": "Product",
            "favorite": "1",
            "id": "A22711E7-3D65-404C-BA40-480916687561",
            "amount": "0"
        ])
        
        try ingredient1noReference = DataFactory.createFoodItemVM(foodItem: [ // For composedFoodItem1, should create a new FoodItem, as unknown
            "amount": "123",
            "name": "Andere Kalorien", // unknown name
            "caloriesPer100g": "123.4", // unknows calories
            "carbsPer100g": "0.6",
            "sugarsPer100g": "0.5",
            "category": "Product", // should be Ingredient
            "favorite": "0",
            "id": "371E5B5E-95E4-43B4-9927-123456789012"
        ])
        
        try ingredient2forFoodItem2 = DataFactory.createFoodItemVM(foodItem: [ // For composedFoodItem1, identical to foodItem2, so should not be created
            "amount": "5",
            "name": "Backpulver",
            "caloriesPer100g": "90",
            "carbsPer100g": "22",
            "sugarsPer100g": "0",
            "category": "Ingredient",
            "favorite": "1",
            "id": "E446505E-7556-49A9-9397-91C422B9D5E2"
        ])
        
        try ingredient3forFoodItem3 = DataFactory.createFoodItemVM(foodItem: [ // For composedFoodItem1, identical to foodItem3, so should not be created
            "amount": "200",
            "name": "Eier (GutBio)",
            "caloriesPer100g": "152.4",
            "carbsPer100g": "0.6",
            "sugarsPer100g": "0.5",
            "category": "Product", // should be Ingredient
            "favorite": "0",
            "id": "371E5B5E-95E4-43B4-9927-987654321098"
        ])
        
        try ingredient4forFoodItem3 = DataFactory.createFoodItemVM(foodItem: [ // For composedFoodItem2, identical to foodItem3, so should not be created
            "amount": "400",
            "name": "Eier (GutBio)",
            "caloriesPer100g": "152.4",
            "carbsPer100g": "0.6",
            "sugarsPer100g": "0.5",
            "category": "Product", // should be Ingredient
            "favorite": "0",
            "id": "371E5B5E-95E4-43B4-9927-765432109876"
        ])
        
        try composedFoodItem1 = DataFactory.createComposedFoodItemViewModel(composedFoodItem: [
            "amount": "1200",
            "name": "Marmorkuchen mit Schokoglasur", // Related: foodItem4
            "category": "Ingredient",
            "favorite": "0",
            "id": "B65CB8FC-DF15-457A-A866-01EBEE8653BB",
            "numberOfPortions": "12"
        ])
        
        try composedFoodItem2 = DataFactory.createComposedFoodItemViewModel(composedFoodItem: [
            "amount": "1234",
            "name": "ComposedFoodItem w/o related FoodItem", // No related FoodItem
            "category": "Ingredient",
            "favorite": "0",
            "id": "B65CB8FC-DF15-457A-A866-876543210987",
            "numberOfPortions": "12"
        ])
    }
    
    /// Creates a FoodItemViewModel (also applicable for ingredients) from the values in the passed dictionary.
    /// - Parameter foodItem: The dictionary with the values of the FoodItem.
    /// - Returns: The created FoodItemViewModel.
    private static func createFoodItemVM(foodItem: Dictionary<String, String>) throws -> FoodItemViewModel {
        try #require(foodItem["id"] != nil)
        try #require(foodItem["name"] != nil)
        try #require(foodItem["category"] != nil)
        try #require(foodItem["favorite"] != nil)
        try #require(foodItem["caloriesPer100g"] != nil)
        try #require(foodItem["carbsPer100g"] != nil)
        try #require(foodItem["sugarsPer100g"] != nil)
        try #require(foodItem["amount"] != nil)
        
        let id = UUID.init(uuidString: foodItem["id"]!)
        try #require(id != nil)
        
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
            id: id!,
            name: name,
            category: category!,
            favorite: favorite,
            caloriesPer100g: caloriesPer100g!,
            carbsPer100g: carbsPer100g!,
            sugarsPer100g: sugarsPer100g!,
            amount: amount!
        )
        return foodItemVM
    }
    
    private static func createComposedFoodItemViewModel(composedFoodItem: Dictionary<String, String>) throws -> ComposedFoodItemViewModel {
        try #require(composedFoodItem["id"] != nil)
        try #require(composedFoodItem["name"] != nil)
        try #require(composedFoodItem["category"] != nil)
        try #require(composedFoodItem["favorite"] != nil)
        try #require(composedFoodItem["numberOfPortions"] != nil)
        try #require(composedFoodItem["amount"] != nil)
        
        let id = UUID.init(uuidString: composedFoodItem["id"]!)
        try #require(id != nil)
        
        let name = composedFoodItem["name"]!
        
        let category = FoodItemCategory(rawValue: composedFoodItem["category"]!)
        try #require(category != nil)
        
        let favorite = composedFoodItem["favorite"]! == "0" ? false : true
        
        let numberOfPortions = Int(composedFoodItem["numberOfPortions"]!)
        try #require(numberOfPortions != nil)
        
        let amount = composedFoodItem["amount"]!
        
        let composedFoodItemViewModel = ComposedFoodItemViewModel(
            id: id!,
            name: name,
            category: category!,
            favorite: favorite
        )
        
        composedFoodItemViewModel.numberOfPortions = numberOfPortions!
        composedFoodItemViewModel.amountAsString = amount
        
        return composedFoodItemViewModel
    }
}
