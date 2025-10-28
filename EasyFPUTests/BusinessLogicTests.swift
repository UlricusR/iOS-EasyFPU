//
//  BusinessLogicTests.swift
//  EasyFPUTests
//
//  Created by Ulrich Rüth on 13/11/2024.
//  Copyright © 2024 Ulrich Rüth. All rights reserved.
//

import Testing
import Foundation
@testable import EasyFPU

struct BusinessLogicTests {
    private static let name = "FoodItem Name"
    private static let category: FoodItemCategory = .product
    private static let favorite: Bool = true
    private static let caloriesPer100g: Double = 432.123
    private static let carbsPer100g: Double = 83.321
    private static let sugarsPer100g: Double = 12.21
    private static let amount: Int = 456
    private static let comment: String = "This is a comment"
    
    private static let absorptionTime: Int = 5
    private static let maxFPU: Int = 3
    
    // Are exactly double values from defaults
    private static let absorptionBlocksFromJson: [AbsorptionBlockFromJson] = [
        AbsorptionBlockFromJson(maxFpu: 2, absorptionTime: 6),
        AbsorptionBlockFromJson(maxFpu: 4, absorptionTime: 8),
        AbsorptionBlockFromJson(maxFpu: 6, absorptionTime: 10),
        AbsorptionBlockFromJson(maxFpu: 8, absorptionTime: 12),
        AbsorptionBlockFromJson(maxFpu: 12, absorptionTime: 16)
    ]
        

    @Suite("FoodItem Tests")
    struct FoodItemTests {
        @Test("ID 1: Initialize FoodItem with numeric values")
        func initializeFoodItemNormal() async throws {
            let foodItemPersistence = FoodItemPersistence(
                id: UUID(),
                name: BusinessLogicTests.name,
                foodCategory: nil,
                category: BusinessLogicTests.category,
                favorite: BusinessLogicTests.favorite,
                caloriesPer100g: BusinessLogicTests.caloriesPer100g,
                carbsPer100g: BusinessLogicTests.carbsPer100g,
                sugarsPer100g: BusinessLogicTests.sugarsPer100g,
                amount: BusinessLogicTests.amount,
                sourceID: nil,
                sourceDB: nil
            )
            var dataError: FoodItemDataError = .none
            let foodItem = FoodItem.create(from: foodItemPersistence, saveContext: false, dataError: &dataError)
            #expect(foodItem != nil)
            #expect(dataError == .none)
            let ingredient = Ingredient.create(from: foodItem!, context: CoreDataStack.viewContext)
            ingredient.amount = Int64(BusinessLogicTests.amount)
            BusinessLogicTests.checkFoodItemValues(ingredient: ingredient)
        }
        
        @Test("ID 3: Initialize FoodItemViewModel with empty name")
        func initializeFoodItemNoName() async throws {
            let foodItemPersistence = FoodItemPersistence(
                id: UUID(),
                name: "",
                foodCategory: nil,
                category: BusinessLogicTests.category,
                favorite: BusinessLogicTests.favorite,
                caloriesPer100g: BusinessLogicTests.caloriesPer100g,
                carbsPer100g: BusinessLogicTests.carbsPer100g,
                sugarsPer100g: BusinessLogicTests.sugarsPer100g,
                amount: BusinessLogicTests.amount,
                sourceID: nil,
                sourceDB: nil
            )
            var foodItemDataError: FoodItemDataError = .none
            let foodItem = FoodItem.create(from: foodItemPersistence, saveContext: false, dataError: &foodItemDataError)
            #expect(foodItem == nil)
            #expect(foodItemDataError  == FoodItemDataError.name(NSLocalizedString("Name must not be empty", comment: "")))
        }
        
        @Test("ID 4: Initialize FoodItemViewModel with error in calories", arguments: zip(
            [
                -3.567
            ],
            [
                NSLocalizedString("Value must not be negative", comment: "")
            ]
        ))
        func initializeFoodItemCaloriesError(inputValue: Double, errorString: String) async throws {
            let foodItemPersistence = FoodItemPersistence(
                id: UUID(),
                name: BusinessLogicTests.name,
                foodCategory: nil,
                category: BusinessLogicTests.category,
                favorite: BusinessLogicTests.favorite,
                caloriesPer100g: inputValue,
                carbsPer100g: BusinessLogicTests.carbsPer100g,
                sugarsPer100g: BusinessLogicTests.sugarsPer100g,
                amount: BusinessLogicTests.amount,
                sourceID: nil,
                sourceDB: nil
            )
            var foodItemDataError: FoodItemDataError = .none
            let foodItem = FoodItem.create(from: foodItemPersistence, saveContext: false, dataError: &foodItemDataError)
            #expect(foodItem == nil)
            #expect(foodItemDataError == FoodItemDataError.calories(errorString))
        }
        
        @Test("ID 5: Initialize FoodItemViewModel with error in carbs", arguments: zip(
            [
                -3.567
            ],
            [
                NSLocalizedString("Value must not be negative", comment: "")
            ]
        ))
        func initializeFoodItemCarbsError(inputValue: Double, errorString: String) async throws {
            let foodItemPersistence = FoodItemPersistence(
                id: UUID(),
                name: BusinessLogicTests.name,
                foodCategory: nil,
                category: BusinessLogicTests.category,
                favorite: BusinessLogicTests.favorite,
                caloriesPer100g: BusinessLogicTests.caloriesPer100g,
                carbsPer100g: inputValue,
                sugarsPer100g: BusinessLogicTests.sugarsPer100g,
                amount: BusinessLogicTests.amount,
                sourceID: nil,
                sourceDB: nil
            )
            var foodItemDataError: FoodItemDataError = .none
            let foodItem = FoodItem.create(from: foodItemPersistence, saveContext: false, dataError: &foodItemDataError)
            #expect(foodItem == nil)
            #expect(foodItemDataError == FoodItemDataError.carbs(errorString))
        }
        
        @Test("ID 6: Initialize FoodItemViewModel with error in sugars", arguments: zip(
            [
                -3.567
            ],
            [
                NSLocalizedString("Value must not be negative", comment: "")
            ]
        ))
        func initializeFoodItemSugarsError(inputValue: Double, errorString: String) async throws {
            let foodItemPersistence = FoodItemPersistence(
                id: UUID(),
                name: BusinessLogicTests.name,
                foodCategory: nil,
                category: BusinessLogicTests.category,
                favorite: BusinessLogicTests.favorite,
                caloriesPer100g: BusinessLogicTests.caloriesPer100g,
                carbsPer100g: BusinessLogicTests.carbsPer100g,
                sugarsPer100g: inputValue,
                amount: BusinessLogicTests.amount,
                sourceID: nil,
                sourceDB: nil
            )
            var foodItemDataError: FoodItemDataError = .none
            let foodItem = FoodItem.create(from: foodItemPersistence, saveContext: false, dataError: &foodItemDataError)
            #expect(foodItem == nil)
            #expect(foodItemDataError == FoodItemDataError.sugars(errorString))
        }
        
        @Test("ID 7: Initialize FoodItemViewModel with sugars exceeding carbs")
        func initializeFoodItemSugarsExceedCarbs() async throws {
            let foodItemPersistence = FoodItemPersistence(
                id: UUID(),
                name: BusinessLogicTests.name,
                foodCategory: nil,
                category: BusinessLogicTests.category,
                favorite: BusinessLogicTests.favorite,
                caloriesPer100g: BusinessLogicTests.caloriesPer100g,
                carbsPer100g: BusinessLogicTests.carbsPer100g,
                sugarsPer100g: BusinessLogicTests.carbsPer100g + 1,
                amount: BusinessLogicTests.amount,
                sourceID: nil,
                sourceDB: nil
            )
            var foodItemDataError: FoodItemDataError = .none
            let foodItem = FoodItem.create(from: foodItemPersistence, saveContext: false, dataError: &foodItemDataError)
            #expect(foodItem == nil)
            #expect(foodItemDataError == FoodItemDataError.tooMuchSugars(NSLocalizedString("Sugars exceed carbs", comment: "")))
        }
        
        @Test("ID 8: Initialize FoodItemViewModel with calories from carbs exactly match total calories")
        func initializeFoodItemCaloriesFromCarbsMatchTotalCalories() async throws {
            let foodItemPersistence = FoodItemPersistence(
                id: UUID(),
                name: BusinessLogicTests.name,
                foodCategory: nil,
                category: BusinessLogicTests.category,
                favorite: BusinessLogicTests.favorite,
                caloriesPer100g: BusinessLogicTests.caloriesPer100g,
                carbsPer100g: BusinessLogicTests.caloriesPer100g / 4,
                sugarsPer100g: BusinessLogicTests.sugarsPer100g,
                amount: BusinessLogicTests.amount,
                sourceID: nil,
                sourceDB: nil
            )
            var foodItemDataError: FoodItemDataError = .none
            let foodItem = FoodItem.create(from: foodItemPersistence, saveContext: false, dataError: &foodItemDataError)
            #expect(foodItem != nil)
            #expect(foodItemDataError == FoodItemDataError.none)
        }
        
        @Test("ID 9: Initialize FoodItemViewModel with calories from carbs exceeding total calories")
        func initializeFoodItemCaloriesFromCarbsExceedTotalCalories() async throws {
            let foodItemPersistence = FoodItemPersistence(
                id: UUID(),
                name: BusinessLogicTests.name,
                foodCategory: nil,
                category: BusinessLogicTests.category,
                favorite: BusinessLogicTests.favorite,
                caloriesPer100g: BusinessLogicTests.caloriesPer100g,
                carbsPer100g: BusinessLogicTests.caloriesPer100g / 4 + 1,
                sugarsPer100g: BusinessLogicTests.sugarsPer100g,
                amount: BusinessLogicTests.amount,
                sourceID: nil,
                sourceDB: nil
            )
            var foodItemDataError: FoodItemDataError = .none
            let foodItem = FoodItem.create(from: foodItemPersistence, saveContext: false, dataError: &foodItemDataError)
            #expect(foodItem == nil)
            #expect(foodItemDataError == FoodItemDataError.tooMuchCarbs(NSLocalizedString("Calories from carbs (4 kcal per gram) exceed total calories", comment: "")))
        }
    }
    
    @Suite("ComposedFoodItem Tests")
    struct ComposedFoodItemViewModelTests {
        @Test("ID: 1 - Verify ComposedFoodItem business logic")
        func verifyComposedFoodItemViewModel() async throws {
            let composedFoodItemVM = try DataFactory.shared.createComposedFoodItemPersistence()
            let allFoodItemVMs = composedFoodItemVM.ingredients
            
            // Calculate nutritional values
            var amount = 0
            var calories = 0.0
            var carbs = 0.0
            var sugars = 0.0
            var fpus = 0.0
            for foodItemVM in allFoodItemVMs {
                amount += foodItemVM.amount
                calories += foodItemVM.caloriesPer100g / 100 * Double(foodItemVM.amount)
                carbs += foodItemVM.carbsPer100g / 100 * Double(foodItemVM.amount)
                sugars += foodItemVM.sugarsPer100g / 100 * Double(foodItemVM.amount)
                fpus += foodItemVM.getFPU().fpu
            }
            
            // Create a Core Data ComposedFoodItem
            let cdComposedFoodItem = ComposedFoodItem.create(from: composedFoodItemVM, saveContext: false)
            #expect(cdComposedFoodItem != nil)
            
            // Verify nutritional values
            #expect(cdComposedFoodItem!.amount == amount)
            #expect(BusinessLogicTests.roundToFiveDecimals(cdComposedFoodItem!.calories) == BusinessLogicTests.roundToFiveDecimals(calories))
            #expect(BusinessLogicTests.roundToFiveDecimals(cdComposedFoodItem!.carbsInclSugars) == BusinessLogicTests.roundToFiveDecimals(carbs))
            #expect(BusinessLogicTests.roundToFiveDecimals(cdComposedFoodItem!.sugarsOnly) == BusinessLogicTests.roundToFiveDecimals(sugars))
            #expect(BusinessLogicTests.roundToFiveDecimals(cdComposedFoodItem!.regularCarbs(treatSugarsSeparately: false)) == BusinessLogicTests.roundToFiveDecimals(carbs))
            #expect(cdComposedFoodItem!.sugars(treatSugarsSeparately: false) == 0)
            #expect(BusinessLogicTests.roundToFiveDecimals(cdComposedFoodItem!.regularCarbs(treatSugarsSeparately: true)) == BusinessLogicTests.roundToFiveDecimals(carbs - sugars))
            #expect(BusinessLogicTests.roundToFiveDecimals(cdComposedFoodItem!.sugars(treatSugarsSeparately: true)) == BusinessLogicTests.roundToFiveDecimals(sugars))
            #expect(BusinessLogicTests.roundToFiveDecimals(cdComposedFoodItem!.fpus.fpu) == BusinessLogicTests.roundToFiveDecimals(fpus))
            
            // Create a new ingredient
            let newFoodItemVM = try DataFactory.shared.createFoodItemPersistence()
            
            // Update the nutritional values
            amount += newFoodItemVM.amount
            calories += newFoodItemVM.caloriesPer100g / 100 * Double(newFoodItemVM.amount)
            carbs += newFoodItemVM.carbsPer100g / 100 * Double(newFoodItemVM.amount)
            sugars += newFoodItemVM.sugarsPer100g / 100 * Double(newFoodItemVM.amount)
            fpus += newFoodItemVM.getFPU().fpu
            
            // Create the core data ingredient
            var dataError: FoodItemDataError = .none
            let cdFoodItem = FoodItem.create(from: newFoodItemVM, saveContext: false, dataError: &dataError)
            try #require(cdFoodItem != nil)
            let cdIngredient = Ingredient.create(from: cdFoodItem!, context: CoreDataStack.viewContext)
            cdIngredient.amount = Int64(newFoodItemVM.amount)
            
            // Add the ingredient to the composed food item
            cdComposedFoodItem!.add(ingredient: cdIngredient)
            
            // Verify nutritional values
            #expect(cdComposedFoodItem!.amount == amount)
            #expect(BusinessLogicTests.roundToFiveDecimals(cdComposedFoodItem!.calories) == BusinessLogicTests.roundToFiveDecimals(calories))
            #expect(BusinessLogicTests.roundToFiveDecimals(cdComposedFoodItem!.carbsInclSugars) == BusinessLogicTests.roundToFiveDecimals(carbs))
            #expect(BusinessLogicTests.roundToFiveDecimals(cdComposedFoodItem!.sugarsOnly) == BusinessLogicTests.roundToFiveDecimals(sugars))
            #expect(BusinessLogicTests.roundToFiveDecimals(cdComposedFoodItem!.regularCarbs(treatSugarsSeparately: false)) == BusinessLogicTests.roundToFiveDecimals(carbs))
            #expect(cdComposedFoodItem!.sugars(treatSugarsSeparately: false) == 0)
            #expect(BusinessLogicTests.roundToFiveDecimals(cdComposedFoodItem!.regularCarbs(treatSugarsSeparately: true)) == BusinessLogicTests.roundToFiveDecimals(carbs - sugars))
            #expect(BusinessLogicTests.roundToFiveDecimals(cdComposedFoodItem!.sugars(treatSugarsSeparately: true)) == BusinessLogicTests.roundToFiveDecimals(sugars))
            #expect(BusinessLogicTests.roundToFiveDecimals(cdComposedFoodItem!.fpus.fpu) == BusinessLogicTests.roundToFiveDecimals(fpus))
            
            // Remove the ingredient again
            cdComposedFoodItem!.remove(cdIngredient)
            
            // Update the nutritional values
            amount -= newFoodItemVM.amount
            calories -= newFoodItemVM.caloriesPer100g / 100 * Double(newFoodItemVM.amount)
            carbs -= newFoodItemVM.carbsPer100g / 100 * Double(newFoodItemVM.amount)
            sugars -= newFoodItemVM.sugarsPer100g / 100 * Double(newFoodItemVM.amount)
            fpus -= newFoodItemVM.getFPU().fpu
            
            // Verify nutritional values
            #expect(cdComposedFoodItem!.amount == amount)
            #expect(BusinessLogicTests.roundToFiveDecimals(cdComposedFoodItem!.calories) == BusinessLogicTests.roundToFiveDecimals(calories))
            #expect(BusinessLogicTests.roundToFiveDecimals(cdComposedFoodItem!.carbsInclSugars) == BusinessLogicTests.roundToFiveDecimals(carbs))
            #expect(BusinessLogicTests.roundToFiveDecimals(cdComposedFoodItem!.sugarsOnly) == BusinessLogicTests.roundToFiveDecimals(sugars))
            #expect(BusinessLogicTests.roundToFiveDecimals(cdComposedFoodItem!.regularCarbs(treatSugarsSeparately: false)) == BusinessLogicTests.roundToFiveDecimals(carbs))
            #expect(cdComposedFoodItem!.sugars(treatSugarsSeparately: false) == 0)
            #expect(BusinessLogicTests.roundToFiveDecimals(cdComposedFoodItem!.regularCarbs(treatSugarsSeparately: true)) == BusinessLogicTests.roundToFiveDecimals(carbs - sugars))
            #expect(BusinessLogicTests.roundToFiveDecimals(cdComposedFoodItem!.sugars(treatSugarsSeparately: true)) == BusinessLogicTests.roundToFiveDecimals(sugars))
            #expect(BusinessLogicTests.roundToFiveDecimals(cdComposedFoodItem!.fpus.fpu) == BusinessLogicTests.roundToFiveDecimals(fpus))
        }
    }
    
    @Suite("TypicalAmount Tests")
    struct TypicalAmountViewModelTests {
        @Test("ID 1 - Initialize with amount as number")
        func initializeWithAmountAsNumber() async throws {
            let typicalAmountVM = TypicalAmountPersistence(amount: BusinessLogicTests.amount, comment: BusinessLogicTests.comment)
            BusinessLogicTests.checkTypicalAmountValues(typicalAmountVM: typicalAmountVM)
        }
    }
    
    @Suite("Absorption Scheme Tests")
    struct AbsorptionSchemeTests {
        @Test("ID 1 - Test Absorption Block initializer from string values")
        func absorptionBlockInitializerFromStringValues() async throws {
            let absorptionBlock = AbsorptionBlockFromJson(
                maxFpu: BusinessLogicTests.maxFPU,
                absorptionTime: BusinessLogicTests.absorptionTime
            )
            let absorptionBlock1 = AbsorptionBlock.create(from: absorptionBlock, id: UUID(), saveContext: false)
            
            let absorptionBlock2 = AbsorptionBlock.create(absorptionTime: BusinessLogicTests.absorptionTime, maxFpu: BusinessLogicTests.maxFPU, saveContext: false)
            #expect(absorptionBlock1 == absorptionBlock2)
        }
        
        @Test("ID 4 - Absorption Scheme")
        func absorptionScheme() async throws {
            // Create AbsorptionSchemeViewModel
            let absorptionSchemeVM = AbsorptionScheme()
            for absorptionBlockJson in absorptionBlocksFromJson {
                let _ = AbsorptionBlock.create(from: absorptionBlockJson, id: UUID(), saveContext: false)
            }
            
            // Fetch all absorption blocks and compare
            #expect(AbsorptionBlock.fetchAll().count == 5)
            
            // Try to add absorption blocks with existing maxFPU
            var alert: SimpleAlertType? = nil
            for absorptionBlockFromJson in BusinessLogicTests.absorptionBlocksFromJson {
                alert = absorptionSchemeVM.add(maxFpu: absorptionBlockFromJson.maxFpu, absorptionTime: absorptionBlockFromJson.absorptionTime, saveContext: false)
                #expect(alert?.messageAsString() == NSLocalizedString("Maximum FPU value already exists", comment: ""))
            }
            
            // Fetch all absorption blocks and compare, we should still have 5
            #expect(AbsorptionBlock.fetchAll().count == 5)
            
            // Try to add the first absorption block with an absorption time equal to the following (wrong)
            alert = nil
            alert = absorptionSchemeVM.add(maxFpu: 1, absorptionTime: 6, saveContext: false)
            #expect(alert?.messageAsString() == NSLocalizedString("Absorption time is equals or larger than the one of the following absorption block", comment: ""))
            #expect(AbsorptionBlock.fetchAll().count == 5)
            
            // Try to add the first absorption block with an absorption time more than the following (wrong)
            alert = nil
            alert = absorptionSchemeVM.add(maxFpu: 1, absorptionTime: 7, saveContext: false)
            #expect(alert?.messageAsString() == NSLocalizedString("Absorption time is equals or larger than the one of the following absorption block", comment: ""))
            
            // Fetch all absorption blocks and compare, we should still have 5
            #expect(AbsorptionBlock.fetchAll().count == 5)
            
            // Try to add the first absorption block with an absorption time less than the following (correct)
            alert = nil
            alert = absorptionSchemeVM.add(maxFpu: 1, absorptionTime: 5, saveContext: false)
            #expect(alert == nil)
            
            // Fetch all absorption blocks and compare, we should now have 6
            #expect(AbsorptionBlock.fetchAll().count == 6)
            
            // Try to add the last absorption block with an absorption time equal to the previous (wrong)
            alert = nil
            alert = absorptionSchemeVM.add(maxFpu: 16, absorptionTime: 16, saveContext: false)
            #expect(alert?.messageAsString() == NSLocalizedString("Absorption time is equals or less than the one of the block before", comment: ""))
            
            // Fetch all absorption blocks and compare, we should still have 6
            #expect(AbsorptionBlock.fetchAll().count == 6)
            
            // Try to add the first absorption block with an absorption time less than the previous (wrong)
            alert = nil
            alert = absorptionSchemeVM.add(maxFpu: 16, absorptionTime: 15, saveContext: false)
            #expect(alert?.messageAsString() == NSLocalizedString("Absorption time is equals or less than the one of the block before", comment: ""))
            
            // Fetch all absorption blocks and compare, we should still have 6
            #expect(AbsorptionBlock.fetchAll().count == 6)
            
            // Try to add the last absorption block with an absorption time more than the previous (correct)
            alert = nil
            alert = absorptionSchemeVM.add(maxFpu: 16, absorptionTime: 20, saveContext: false)
            #expect(alert == nil)
            
            // Fetch all absorption blocks and compare, we should now have 7
            #expect(AbsorptionBlock.fetchAll().count == 7)
            
            // Try to add the last absorption block with an absorption time equal to the previous (wrong)
            alert = nil
            alert = absorptionSchemeVM.add(maxFpu: 7, absorptionTime: 10, saveContext: false)
            #expect(alert?.messageAsString() == NSLocalizedString("Absorption time must be between previous and following block", comment: ""))
            
            // Fetch all absorption blocks and compare, we should still have 7
            #expect(AbsorptionBlock.fetchAll().count == 7)
            
            // Try to add the first absorption block with an absorption time less than the previous (wrong)
            alert = nil
            alert = absorptionSchemeVM.add(maxFpu: 7, absorptionTime: 12, saveContext: false)
            #expect(alert?.messageAsString() == NSLocalizedString("Absorption time must be between previous and following block", comment: ""))
            
            // Fetch all absorption blocks and compare, we should still have 7
            #expect(AbsorptionBlock.fetchAll().count == 7)
            
            // Try to add the last absorption block with an absorption time more than the previous (correct)
            alert = nil
            alert = absorptionSchemeVM.add(maxFpu: 7, absorptionTime: 11, saveContext: false)
            #expect(alert == nil)
            
            // Fetch all absorption blocks and compare, we should now have 8
            #expect(AbsorptionBlock.fetchAll().count == 8)
            
            // Try resetting
            var errorMessage = ""
            #expect(absorptionSchemeVM.resetToDefaultAbsorptionBlocks(saveContext: false, errorMessage: &errorMessage))
            
            // Fetch all absorption blocks and compare, we should now have 5
            var absorptionBlocks = AbsorptionBlock.fetchAll()
            #expect(absorptionBlocks.count == 5)
            
            // Check for the expected values
            #expect(absorptionBlocks[0].maxFpu == Int(absorptionBlocksFromJson[0].maxFpu / 2))
            #expect(absorptionBlocks[0].absorptionTime == Int(absorptionBlocksFromJson[0].absorptionTime / 2))
            #expect(absorptionBlocks[1].maxFpu == Int(absorptionBlocksFromJson[1].maxFpu / 2))
            #expect(absorptionBlocks[1].absorptionTime == Int(absorptionBlocksFromJson[1].absorptionTime / 2))
            #expect(absorptionBlocks[2].maxFpu == Int(absorptionBlocksFromJson[2].maxFpu / 2))
            #expect(absorptionBlocks[2].absorptionTime == Int(absorptionBlocksFromJson[2].absorptionTime / 2))
            #expect(absorptionBlocks[3].maxFpu == Int(absorptionBlocksFromJson[3].maxFpu / 2))
            #expect(absorptionBlocks[3].absorptionTime == Int(absorptionBlocksFromJson[3].absorptionTime / 2))
            #expect(absorptionBlocks[4].maxFpu == Int(absorptionBlocksFromJson[4].maxFpu / 2))
            #expect(absorptionBlocks[4].absorptionTime == Int(absorptionBlocksFromJson[4].absorptionTime / 2))
            
            // Try replacing blocks from back to front
            alert = nil
            alert = absorptionSchemeVM.replace(existingAbsorptionBlockID: absorptionBlocks[4].id!, newMaxFpu: absorptionBlocksFromJson[4].maxFpu, newAbsorptionTime: absorptionBlocksFromJson[4].absorptionTime, saveContext: false)
            #expect(alert == nil)
            
            alert = nil
            alert = absorptionSchemeVM.replace(existingAbsorptionBlockID: absorptionBlocks[3].id!, newMaxFpu: absorptionBlocksFromJson[3].maxFpu, newAbsorptionTime: absorptionBlocksFromJson[3].absorptionTime, saveContext: false)
            #expect(alert == nil)
            
            alert = nil
            alert = absorptionSchemeVM.replace(existingAbsorptionBlockID: absorptionBlocks[2].id!, newMaxFpu: absorptionBlocksFromJson[2].maxFpu, newAbsorptionTime: absorptionBlocksFromJson[2].absorptionTime, saveContext: false)
            #expect(alert == nil)
            
            alert = nil
            alert = absorptionSchemeVM.replace(existingAbsorptionBlockID: absorptionBlocks[1].id!, newMaxFpu: absorptionBlocksFromJson[1].maxFpu, newAbsorptionTime: absorptionBlocksFromJson[1].absorptionTime, saveContext: false)
            #expect(alert == nil)
            
            alert = nil
            alert = absorptionSchemeVM.replace(existingAbsorptionBlockID: absorptionBlocks[0].id!, newMaxFpu: absorptionBlocksFromJson[0].maxFpu, newAbsorptionTime: absorptionBlocksFromJson[0].absorptionTime, saveContext: false)
            #expect(alert == nil)
            
            // Fetch all absorption blocks and compare, we should still have 5
            absorptionBlocks = AbsorptionBlock.fetchAll()
            #expect(absorptionBlocks.count == 5)
            
            // Try to replace first with last block
            #expect(absorptionSchemeVM.replace(existingAbsorptionBlockID: absorptionBlocks[0].id!, newMaxFpu: 14, newAbsorptionTime: 20, saveContext: false) == nil)
            
            // Fetch all absorption blocks and compare, we should still have 5
            absorptionBlocks = AbsorptionBlock.fetchAll()
            #expect(absorptionBlocks.count == 5)
            
            #expect(absorptionBlocks[0].maxFpu == absorptionBlocksFromJson[1].maxFpu)
            #expect(absorptionBlocks[0].absorptionTime == absorptionBlocksFromJson[1].absorptionTime)
            #expect(absorptionBlocks[1].maxFpu == absorptionBlocksFromJson[2].maxFpu)
            #expect(absorptionBlocks[1].absorptionTime == absorptionBlocksFromJson[2].absorptionTime)
            #expect(absorptionBlocks[2].maxFpu == absorptionBlocksFromJson[3].maxFpu)
            #expect(absorptionBlocks[2].absorptionTime == absorptionBlocksFromJson[3].absorptionTime)
            #expect(absorptionBlocks[3].maxFpu == absorptionBlocksFromJson[4].maxFpu)
            #expect(absorptionBlocks[3].absorptionTime == absorptionBlocksFromJson[4].absorptionTime)
            #expect(absorptionBlocks[4].maxFpu == 14)
            #expect(absorptionBlocks[4].absorptionTime == 20)
        }
    }
    
    //
    // Helper functions
    //
    
    private static func checkFoodItemValues(ingredient: Ingredient) {
        // Direct values
        #expect(ingredient.name == BusinessLogicTests.name)
        #expect(ingredient.favorite == BusinessLogicTests.favorite)
        #expect(ingredient.caloriesPer100g == BusinessLogicTests.caloriesPer100g)
        #expect(ingredient.carbsPer100g == BusinessLogicTests.carbsPer100g)
        #expect(ingredient.sugarsPer100g == BusinessLogicTests.sugarsPer100g)
        #expect(ingredient.amount == BusinessLogicTests.amount)
        
        // Calculated values
        #expect(BusinessLogicTests.roundToFiveDecimals(ingredient.calories) == BusinessLogicTests.roundToFiveDecimals(BusinessLogicTests.caloriesPer100g / 100 * Double(BusinessLogicTests.amount)))
        #expect(BusinessLogicTests.roundToFiveDecimals(ingredient.carbsInclSugars) == BusinessLogicTests.roundToFiveDecimals(BusinessLogicTests.carbsPer100g / 100 * Double(BusinessLogicTests.amount)))
        #expect(BusinessLogicTests.roundToFiveDecimals(ingredient.sugarsOnly) == BusinessLogicTests.roundToFiveDecimals(BusinessLogicTests.sugarsPer100g / 100 * Double(BusinessLogicTests.amount)))
        #expect(BusinessLogicTests.roundToFiveDecimals(ingredient.getRegularCarbs(treatSugarsSeparately: true)) == BusinessLogicTests.roundToFiveDecimals((BusinessLogicTests.carbsPer100g - BusinessLogicTests.sugarsPer100g) / 100 * Double(BusinessLogicTests.amount)))
        #expect(BusinessLogicTests.roundToFiveDecimals(ingredient.getRegularCarbs(treatSugarsSeparately: false)) == BusinessLogicTests.roundToFiveDecimals(BusinessLogicTests.carbsPer100g / 100 * Double(BusinessLogicTests.amount)))
        #expect(BusinessLogicTests.roundToFiveDecimals(ingredient.getSugars(treatSugarsSeparately: true)) == BusinessLogicTests.roundToFiveDecimals(BusinessLogicTests.sugarsPer100g / 100 * Double(BusinessLogicTests.amount)))
        #expect(ingredient.getSugars(treatSugarsSeparately: false) == 0)
        
        // Calculate FPU, see https://www.rueth.info/iOS-EasyFPU/manual/#absorption-scheme-for-extended-carbs
        let totalCalories = BusinessLogicTests.caloriesPer100g / 100 * Double(BusinessLogicTests.amount)
        let carbsCalories = 4 * BusinessLogicTests.carbsPer100g / 100 * Double(BusinessLogicTests.amount)
        let fpCalories = totalCalories - carbsCalories
        let fpus = fpCalories / 100
        #expect(ingredient.fpus.fpu == fpus)
        
        // Calculate e-carbs
        let eCarbsFactor = UserSettings.shared.eCarbsFactor
        let eCarbs = fpus * eCarbsFactor
        #expect(ingredient.fpus.getExtendedCarbs() == eCarbs)
    }
    
    private static func checkTypicalAmountValues(typicalAmountVM: TypicalAmountPersistence) {
        #expect(typicalAmountVM.amount == BusinessLogicTests.amount)
        #expect(typicalAmountVM.comment == BusinessLogicTests.comment)
    }
    
    private static func compareAbsorptionBlocks(cdAbsorptionBlock: AbsorptionBlock, absorptionBlock: AbsorptionBlock) {
        #expect(cdAbsorptionBlock.maxFpu == absorptionBlock.maxFpu)
        #expect(cdAbsorptionBlock.absorptionTime == absorptionBlock.absorptionTime)
    }
        
    private static func roundToFiveDecimals(_ value: Double) -> Double {
        return Double(round(100000 * value) / 100000)
    }
}
