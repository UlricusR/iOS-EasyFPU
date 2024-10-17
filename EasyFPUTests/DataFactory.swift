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
    // Tests 1-4
    var tests14FoodItem1: FoodItemViewModel
    var tests14FoodItem1duplicate: FoodItemViewModel
    
    // Tests 5-6
    var tests56FoodItemForComposedFoodItem3: FoodItemViewModel
    var tests56ComposedFoodItem3: ComposedFoodItemViewModel
    var tests56FoodItem1forComposedFoodItem3: FoodItemViewModel
    var tests56Ingredient1forComposedFoodItem3: FoodItemViewModel
    var tests56FoodItem2forComposedFoodItem3: FoodItemViewModel
    var tests56Ingredient2forComposedFoodItem3: FoodItemViewModel
    var tests56FoodItem3forComposedFoodItem3: FoodItemViewModel
    var tests56Ingredient3forComposedFoodItem3: FoodItemViewModel
    var tests56Ingredient4forComposedFoodItem3: FoodItemViewModel
    var tests56Ingredient5forComposedFoodItem3: FoodItemViewModel
    
    // Tests 7-10
    var test710FoodItem: FoodItemViewModel
    var test710TypicalAmount1: TypicalAmountViewModel
    var test710TypicalAmount2: TypicalAmountViewModel
    var test710TypicalAmount3: TypicalAmountViewModel
    var test710TypicalAmount4: TypicalAmountViewModel
    
    // Test 12
    var foodItemForComposedFoodItem1: FoodItemViewModel
    var composedFoodItem1: ComposedFoodItemViewModel
    var ingredient2forFoodItem2: FoodItemViewModel
    
    // Unused
    var foodItem3: FoodItemViewModel
    var ingredient1noReference: FoodItemViewModel
    var ingredient3forFoodItem3: FoodItemViewModel
    var ingredient4forFoodItem3: FoodItemViewModel
    var composedFoodItem2: ComposedFoodItemViewModel
    
    static var shared: DataFactory {
        do {
            return try DataFactory()
        } catch {
            fatalError("Could not create DataFactory: \(error)")
        }
    }
    
    private init() throws {
        // Tests 1-4
        try tests14FoodItem1 = DataFactory.createFoodItemVM(foodItem: [
            "name": "Alpenzwerg",
            "caloriesPer100g": "72",
            "carbsPer100g": "10.4",
            "sugarsPer100g": "9.4",
            "category": "Product",
            "favorite": "0",
            "id": "220458AD-3216-45A2-9FC3-32285A2A36D0",
            "amount": "0"
        ])
        
        try tests14FoodItem1duplicate = DataFactory.createFoodItemVM(foodItem: [
            "name": "Alpenzwerg",
            "caloriesPer100g": "72",
            "carbsPer100g": "10.4",
            "sugarsPer100g": "9.4",
            "category": "Product",
            "favorite": "0",
            "id": "220458AD-3216-45A2-9FC3-32285A2A36D0",
            "amount": "0"
        ])
        
        // Tests 5-6
        try tests56FoodItemForComposedFoodItem3 = DataFactory.createFoodItemVM(foodItem: [ // For composedFoodItem3
            "amount": "0",
            "name": "Pizzateig",
            "caloriesPer100g": "219.2",
            "carbsPer100g": "43.8",
            "sugarsPer100g": "0.4",
            "category": "Product",
            "favorite": "1",
            "id": "D556506E-8667-49B9-0397-91C433B9E5D2" // identical ID as composedFoodItem3
        ])
        
        try tests56ComposedFoodItem3 = DataFactory.createComposedFoodItemViewModel(composedFoodItem: [
            "amount": "816",
            "name": "Pizzateig", // No related FoodItem
            "category": "Product",
            "favorite": "1",
            "id": "D556506E-8667-49B9-0397-91C433B9E5D2",
            "numberOfPortions": "8"
        ])
        
        try tests56FoodItem1forComposedFoodItem3 = DataFactory.createFoodItemVM(foodItem: [ // For composedFoodItem3, for ingredient1forComposedFoodItem3
            "amount": "0",
            "name": "Weizenmehl 405",
            "caloriesPer100g": "343",
            "carbsPer100g": "72",
            "sugarsPer100g": "0.7",
            "category": "Ingredient",
            "favorite": "0",
            "id": "362F6C6F-06F5-54C5-0038-9284EE12832C" // identical ID as ingredient1forComposedFoodItem3
        ])
        
        try tests56Ingredient1forComposedFoodItem3 = DataFactory.createFoodItemVM(foodItem: [ // For composedFoodItem3, for foodItem1forComposedFoodItem3
            "amount": "500",
            "name": "Weizenmehl 405",
            "caloriesPer100g": "343",
            "carbsPer100g": "72",
            "sugarsPer100g": "0.7",
            "category": "Ingredient",
            "favorite": "0",
            "id": "362F6C6F-06F5-54C5-0038-9284EE12832C" // identical ID as foodItem1forComposedFoodItem3
        ])
        
        try tests56FoodItem2forComposedFoodItem3 = DataFactory.createFoodItemVM(foodItem: [ // For composedFoodItem3, for ingredient2forComposedFoodItem3
            "amount": "0",
            "name": "Backhefe trocken",
            "caloriesPer100g": "320",
            "carbsPer100g": "11",
            "sugarsPer100g": "0",
            "category": "Ingredient",
            "favorite": "0",
            "id": "748F6C6F-06E6-56C5-0072-1826EE12832C" // identical ID as ingredient2forComposedFoodItem3
        ])
        
        try tests56Ingredient2forComposedFoodItem3 = DataFactory.createFoodItemVM(foodItem: [ // For composedFoodItem3, for foodItem2forComposedFoodItem3
            "amount": "10",
            "name": "Backhefe trocken",
            "caloriesPer100g": "320",
            "carbsPer100g": "11",
            "sugarsPer100g": "0",
            "category": "Ingredient",
            "favorite": "0",
            "id": "748F6C6F-06E6-56C5-0072-1826EE12832C" // identical ID as foodItem2forComposedFoodItem3
        ])
        
        try tests56FoodItem3forComposedFoodItem3 = DataFactory.createFoodItemVM(foodItem: [ // For composedFoodItem3, for ingredient3forComposedFoodItem3
            "amount": "0",
            "name": "Olivenöl",
            "caloriesPer100g": "828",
            "carbsPer100g": "0",
            "sugarsPer100g": "0",
            "category": "Ingredient",
            "favorite": "0",
            "id": "84976C7F-66E5-56C6-1272-2726FE13835F" // identical ID as ingredient3forComposedFoodItem3
        ])
        
        try tests56Ingredient3forComposedFoodItem3 = DataFactory.createFoodItemVM(foodItem: [ // For composedFoodItem3, for foodItem3forComposedFoodItem3
            "amount": "5",
            "name": "Olivenöl",
            "caloriesPer100g": "828",
            "carbsPer100g": "0",
            "sugarsPer100g": "0",
            "category": "Ingredient",
            "favorite": "0",
            "id": "84976C7F-66E5-56C6-1272-2726FE13835F" // identical ID as foodItem3forComposedFoodItem3
        ])
        
        try tests56Ingredient4forComposedFoodItem3 = DataFactory.createFoodItemVM(foodItem: [ // For composedFoodItem3, no FoodItem
            "amount": "300",
            "name": "Wasser",
            "caloriesPer100g": "0",
            "carbsPer100g": "0",
            "sugarsPer100g": "0",
            "category": "Ingredient",
            "favorite": "0",
            "id": "B65CB8FC-DF15-457A-A866-876543210986"
        ])
        
        try tests56Ingredient5forComposedFoodItem3 = DataFactory.createFoodItemVM(foodItem: [ // For composedFoodItem3, no FoodItem
            "amount": "1",
            "name": "Salz",
            "caloriesPer100g": "0",
            "carbsPer100g": "0",
            "sugarsPer100g": "0",
            "category": "Ingredient",
            "favorite": "0",
            "id": "84956C7F-75E5-86C6-9292-2774FE18265F"
        ])
        
        // Tests 7-8
        try test710FoodItem = DataFactory.createFoodItemVM(foodItem: [
            "name": "Backpulver",
            "caloriesPer100g": "90",
            "carbsPer100g": "22",
            "sugarsPer100g": "0",
            "category": "Ingredient",
            "favorite": "1",
            "id": "E446505E-7556-49A9-9397-91C422B9D5E2",
            "amount": "0"
        ])
        
        try test710TypicalAmount1 = DataFactory.createTypicalAmountViewModel(typicalAmount: [
            "amount": "100",
            "comment": "Comment 1"
        ])
        
        try test710TypicalAmount2 = DataFactory.createTypicalAmountViewModel(typicalAmount: [
            "amount": "200",
            "comment": "Comment 2"
        ])
        
        try test710TypicalAmount3 = DataFactory.createTypicalAmountViewModel(typicalAmount: [
            "amount": "300",
            "comment": "Comment 3"
        ])
        
        try test710TypicalAmount4 = DataFactory.createTypicalAmountViewModel(typicalAmount: [
            "amount": "400",
            "comment": "Comment 4"
        ])
        
        // Tests xxxx (FoodItem.update with related Ingredients)
        
        try foodItemForComposedFoodItem1 = DataFactory.createFoodItemVM(foodItem: [
            "name": "Marmorkuchen mit Schokoglasur",
            "caloriesPer100g": "384.546",
            "carbsPer100g": "42.25",
            "sugarsPer100g": "23.769",
            "category": "Product",
            "favorite": "1",
            "id": "A22711E7-3D65-404C-BA40-480916687561",
            "amount": "0"
        ])
        
        try composedFoodItem1 = DataFactory.createComposedFoodItemViewModel(composedFoodItem: [
            "amount": "1200",
            "name": "Marmorkuchen mit Schokoglasur",
            "category": "Ingredient",
            "favorite": "0",
            "id": "A22711E7-3D65-404C-BA40-480916687561", // Related: foodItem4
            "numberOfPortions": "12"
        ])
        
        try ingredient2forFoodItem2 = DataFactory.createFoodItemVM(foodItem: [ // For composedFoodItem1, identical to foodItem2
            "amount": "5",
            "name": "Backpulver",
            "caloriesPer100g": "90",
            "carbsPer100g": "22",
            "sugarsPer100g": "0",
            "category": "Ingredient",
            "favorite": "1",
            "id": "E446505E-7556-49A9-9397-91C422B9D5E2" // identical ID as foodItem2
        ])
        
        
        // Unused
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
        
        try ingredient3forFoodItem3 = DataFactory.createFoodItemVM(foodItem: [ // For composedFoodItem1, identical to foodItem3, so should not be created
            "amount": "200",
            "name": "Eier (GutBio)",
            "caloriesPer100g": "152.4",
            "carbsPer100g": "0.6",
            "sugarsPer100g": "0.5",
            "category": "Product", // should be Ingredient
            "favorite": "0",
            "id": "371E5B5E-95E4-43B4-9927-8173DD01721B" // identical ID as foodItem3
        ])
        
        try ingredient4forFoodItem3 = DataFactory.createFoodItemVM(foodItem: [ // For composedFoodItem2, identical to foodItem3, so should not be created
            "amount": "400",
            "name": "Eier (GutBio)",
            "caloriesPer100g": "152.4",
            "carbsPer100g": "0.6",
            "sugarsPer100g": "0.5",
            "category": "Product", // should be Ingredient
            "favorite": "0",
            "id": "371E5B5E-95E4-43B4-9927-8173DD01721B"  // identical ID as foodItem3
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
    
    // Tests 5-6
    func tests56CreateComposedFoodItem3() -> ComposedFoodItemViewModel {
        tests56ComposedFoodItem3.foodItems.append(tests56Ingredient1forComposedFoodItem3)
        tests56ComposedFoodItem3.foodItems.append(tests56Ingredient2forComposedFoodItem3)
        tests56ComposedFoodItem3.foodItems.append(tests56Ingredient3forComposedFoodItem3)
        tests56ComposedFoodItem3.foodItems.append(tests56Ingredient4forComposedFoodItem3)
        tests56ComposedFoodItem3.foodItems.append(tests56Ingredient5forComposedFoodItem3)
        return tests56ComposedFoodItem3
    }
    
    // Tests 7-10
    func tests78CreateFoodItemWithTypicalAmounts() -> FoodItemViewModel {
        let foodItemVM = DataFactory.shared.test710FoodItem
        foodItemVM.typicalAmounts.append(DataFactory.shared.test710TypicalAmount1)
        foodItemVM.typicalAmounts.append(DataFactory.shared.test710TypicalAmount2)
        foodItemVM.typicalAmounts.append(DataFactory.shared.test710TypicalAmount3)
        foodItemVM.typicalAmounts.append(DataFactory.shared.test710TypicalAmount4)
        return foodItemVM
    }
    
    // Tests xxxx
    func createComposedFoodItem1() -> ComposedFoodItemViewModel {
        composedFoodItem1.foodItems.append(ingredient2forFoodItem2)
        return composedFoodItem1
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
    
    private static func createTypicalAmountViewModel(typicalAmount: Dictionary<String, String>) throws -> TypicalAmountViewModel {
        try #require(typicalAmount["amount"] != nil)
        try #require(typicalAmount["comment"] != nil)
        
        let amount = Int(typicalAmount["amount"]!)
        try #require(amount != nil)
        
        let comment = typicalAmount["comment"]!
        
        let typicalAmountViewModel = TypicalAmountViewModel(amount: amount!, comment: comment)
        
        return typicalAmountViewModel
    }
}
