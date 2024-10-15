//
//  CoreDataTests.swift
//  EasyFPUTests
//
//  Created by Ulrich Rüth on 14/10/2024.
//  Copyright © 2024 Ulrich Rüth. All rights reserved.
//

import Testing
import CoreData
@testable import EasyFPU

struct CoreDataTests {
    struct FoodItemBehavior {
        @Test("ID: 1 - Create FoodItem - allowDuplicate=false - no FoodItem")
        func createFoodItemDuplicateFalseNoFoodItem() async throws {
            // Save a new FoodItem to the DB
            let foodItemVM = DataFactory.shared.foodItem1
            foodItemVM.save(allowDuplicate: false)
            
            // Check results in DB
            #expect(FoodItem.fetchAll().count == 1)
            
            // Check for identical IDs
            let foodItem = FoodItem.getFoodItemByName(name: foodItemVM.name)
            try #require(foodItem != nil)
            #expect(foodItem!.id == foodItemVM.id)
            assessFoodItemValues(foodItemVM: foodItemVM, foodItem: foodItem!)
        }
        
        private func assessFoodItemValues(foodItemVM: FoodItemViewModel, foodItem: FoodItem) {
            #expect(foodItem.name == foodItemVM.name)
            #expect(foodItem.category == foodItemVM.category.rawValue)
            #expect(foodItem.favorite == foodItemVM.favorite)
            #expect(foodItem.caloriesPer100g == foodItemVM.caloriesPer100g)
            #expect(foodItem.carbsPer100g == foodItemVM.carbsPer100g)
            #expect(foodItem.sugarsPer100g == foodItemVM.sugarsPer100g)
        }
    }
    

}
