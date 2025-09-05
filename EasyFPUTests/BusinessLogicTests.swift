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
    private static let absorptionBlocks: [AbsorptionBlockFromJson] = [
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
            let ingredient = Ingredient.create(from: foodItem!)
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
            var calories = 0.0
            var carbs = 0.0
            var sugars = 0.0
            var fpus = 0.0
            for foodItemVM in allFoodItemVMs {
                calories += foodItemVM.caloriesPer100g / 100 * Double(foodItemVM.amount)
                carbs += foodItemVM.carbsPer100g / 100 * Double(foodItemVM.amount)
                sugars += foodItemVM.sugarsPer100g / 100 * Double(foodItemVM.amount)
                fpus += foodItemVM.getFPU().fpu
            }
            
            // Create a Core Data ComposedFoodItem
            let cdComposedFoodItem = ComposedFoodItem.create(from: composedFoodItemVM, saveContext: false)
            #expect(cdComposedFoodItem != nil)
            
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
            for absorptionBlockJson in absorptionBlocks {
                absorptionSchemeVM.absorptionBlocks.append(AbsorptionBlock.create(from: absorptionBlockJson, id: UUID(), saveContext: false))
            }
            #expect(absorptionSchemeVM.absorptionBlocks.count == 5)
            for absorptionBlock in absorptionSchemeVM.absorptionBlocks {
                let cdAbsorptionBlock = AbsorptionBlock.getAbsorptionBlockByID(id: absorptionBlock.id!)
                try #require(cdAbsorptionBlock != nil)
                BusinessLogicTests.compareAbsorptionBlocks(cdAbsorptionBlock: cdAbsorptionBlock!, absorptionBlock: absorptionBlock)
            }
            
            // Try to add absorption blocks with existing maxFPU
            var alert: SimpleAlertType? = nil
            for absorptionBlock in BusinessLogicTests.absorptionBlocks {
                alert = absorptionSchemeVM.add(newAbsorptionBlock: AbsorptionBlock.create(from: absorptionBlock, id: UUID(), saveContext: false), saveContext: false)
                #expect(alert?.messageAsString() == NSLocalizedString("Maximum FPU value already exists", comment: ""))
            }
            
            // Try to add the first absorption block with an absorption time equal to the following (wrong)
            alert = nil
            alert = absorptionSchemeVM.add(newAbsorptionBlock: AbsorptionBlock.create(absorptionTime: 6, maxFpu: 1, saveContext: false), saveContext: false)
            #expect(alert?.messageAsString() == NSLocalizedString("Absorption time is equals or larger than the one of the following absorption block", comment: ""))
            #expect(absorptionSchemeVM.absorptionBlocks.count == 5)
            
            // Try to add the first absorption block with an absorption time more than the following (wrong)
            alert = nil
            alert = absorptionSchemeVM.add(newAbsorptionBlock: AbsorptionBlock.create(absorptionTime: 7, maxFpu: 1, saveContext: false), saveContext: false)
            #expect(alert?.messageAsString() == NSLocalizedString("Absorption time is equals or larger than the one of the following absorption block", comment: ""))
            #expect(absorptionSchemeVM.absorptionBlocks.count == 5)
            
            // Try to add the first absorption block with an absorption time less than the following (correct)
            alert = nil
            alert = absorptionSchemeVM.add(newAbsorptionBlock: AbsorptionBlock.create(absorptionTime: 5, maxFpu: 1, saveContext: false), saveContext: false)
            #expect(alert == nil)
            #expect(absorptionSchemeVM.absorptionBlocks.count == 6)
            
            // Try to add the last absorption block with an absorption time equal to the previous (wrong)
            alert = nil
            alert = absorptionSchemeVM.add(newAbsorptionBlock: AbsorptionBlock.create(absorptionTime: 16, maxFpu: 16, saveContext: false), saveContext: false)
            #expect(alert?.messageAsString() == NSLocalizedString("Absorption time is equals or less than the one of the block before", comment: ""))
            #expect(absorptionSchemeVM.absorptionBlocks.count == 6)
            
            // Try to add the first absorption block with an absorption time less than the previous (wrong)
            alert = nil
            alert = absorptionSchemeVM.add(newAbsorptionBlock: AbsorptionBlock.create(absorptionTime: 15, maxFpu: 16, saveContext: false), saveContext: false)
            #expect(alert?.messageAsString() == NSLocalizedString("Absorption time is equals or less than the one of the block before", comment: ""))
            #expect(absorptionSchemeVM.absorptionBlocks.count == 6)
            
            // Try to add the last absorption block with an absorption time more than the previous (correct)
            alert = nil
            alert = absorptionSchemeVM.add(newAbsorptionBlock: AbsorptionBlock.create(absorptionTime: 20, maxFpu: 16, saveContext: false), saveContext: false)
            #expect(alert == nil)
            #expect(absorptionSchemeVM.absorptionBlocks.count == 7)
            
            // Try to add the last absorption block with an absorption time equal to the previous (wrong)
            alert = nil
            alert = absorptionSchemeVM.add(newAbsorptionBlock: AbsorptionBlock.create(absorptionTime: 10, maxFpu: 7, saveContext: false), saveContext: false)
            #expect(alert?.messageAsString() == NSLocalizedString("Absorption time must be between previous and following block", comment: ""))
            #expect(absorptionSchemeVM.absorptionBlocks.count == 7)
            
            // Try to add the first absorption block with an absorption time less than the previous (wrong)
            alert = nil
            alert = absorptionSchemeVM.add(newAbsorptionBlock: AbsorptionBlock.create(absorptionTime: 12, maxFpu: 7, saveContext: false), saveContext: false)
            #expect(alert?.messageAsString() == NSLocalizedString("Absorption time must be between previous and following block", comment: ""))
            #expect(absorptionSchemeVM.absorptionBlocks.count == 7)
            
            // Try to add the last absorption block with an absorption time more than the previous (correct)
            alert = nil
            alert = absorptionSchemeVM.add(newAbsorptionBlock: AbsorptionBlock.create(absorptionTime: 11, maxFpu: 7, saveContext: false), saveContext: false)
            #expect(alert == nil)
            #expect(absorptionSchemeVM.absorptionBlocks.count == 8)
            
            // Try resetting
            var errorMessage = ""
            #expect(absorptionSchemeVM.resetToDefaultAbsorptionBlocks(saveContext: false, errorMessage: &errorMessage))
            #expect(absorptionSchemeVM.absorptionBlocks.count == 5)
            #expect(absorptionSchemeVM.absorptionBlocks[0].maxFpu == Int(absorptionBlocks[0].maxFpu / 2))
            #expect(absorptionSchemeVM.absorptionBlocks[0].absorptionTime == Int(absorptionBlocks[0].absorptionTime / 2))
            #expect(absorptionSchemeVM.absorptionBlocks[1].maxFpu == Int(absorptionBlocks[1].maxFpu / 2))
            #expect(absorptionSchemeVM.absorptionBlocks[1].absorptionTime == Int(absorptionBlocks[1].absorptionTime / 2))
            #expect(absorptionSchemeVM.absorptionBlocks[2].maxFpu == Int(absorptionBlocks[2].maxFpu / 2))
            #expect(absorptionSchemeVM.absorptionBlocks[2].absorptionTime == Int(absorptionBlocks[2].absorptionTime / 2))
            #expect(absorptionSchemeVM.absorptionBlocks[3].maxFpu == Int(absorptionBlocks[3].maxFpu / 2))
            #expect(absorptionSchemeVM.absorptionBlocks[3].absorptionTime == Int(absorptionBlocks[3].absorptionTime / 2))
            #expect(absorptionSchemeVM.absorptionBlocks[4].maxFpu == Int(absorptionBlocks[4].maxFpu / 2))
            #expect(absorptionSchemeVM.absorptionBlocks[4].absorptionTime == Int(absorptionBlocks[4].absorptionTime / 2))
            
            // Try replacing blocks from back to front
            alert = nil
            alert = absorptionSchemeVM.replace(existingAbsorptionBlockID: absorptionSchemeVM.absorptionBlocks[4].id!, newMaxFpu: absorptionBlocks[4].maxFpu, newAbsorptionTime: absorptionBlocks[4].absorptionTime, saveContext: false)
            #expect(alert == nil)
            
            alert = nil
            alert = absorptionSchemeVM.replace(existingAbsorptionBlockID: absorptionSchemeVM.absorptionBlocks[3].id!, newMaxFpu: absorptionBlocks[3].maxFpu, newAbsorptionTime: absorptionBlocks[3].absorptionTime, saveContext: false)
            #expect(alert == nil)
            
            alert = nil
            alert = absorptionSchemeVM.replace(existingAbsorptionBlockID: absorptionSchemeVM.absorptionBlocks[2].id!, newMaxFpu: absorptionBlocks[2].maxFpu, newAbsorptionTime: absorptionBlocks[2].absorptionTime, saveContext: false)
            #expect(alert == nil)
            
            alert = nil
            alert = absorptionSchemeVM.replace(existingAbsorptionBlockID: absorptionSchemeVM.absorptionBlocks[1].id!, newMaxFpu: absorptionBlocks[1].maxFpu, newAbsorptionTime: absorptionBlocks[1].absorptionTime, saveContext: false)
            #expect(alert == nil)
            
            alert = nil
            alert = absorptionSchemeVM.replace(existingAbsorptionBlockID: absorptionSchemeVM.absorptionBlocks[0].id!, newMaxFpu: absorptionBlocks[0].maxFpu, newAbsorptionTime: absorptionBlocks[0].absorptionTime, saveContext: false)
            #expect(alert == nil)
            
            // Try to replace first with last block
            #expect(absorptionSchemeVM.replace(existingAbsorptionBlockID: absorptionSchemeVM.absorptionBlocks[0].id!, newMaxFpu: 14, newAbsorptionTime: 20, saveContext: false) == nil)
            #expect(absorptionSchemeVM.absorptionBlocks.count == 5)
            #expect(absorptionSchemeVM.absorptionBlocks[0].maxFpu == absorptionBlocks[1].maxFpu)
            #expect(absorptionSchemeVM.absorptionBlocks[0].absorptionTime == absorptionBlocks[1].absorptionTime)
            #expect(absorptionSchemeVM.absorptionBlocks[1].maxFpu == absorptionBlocks[2].maxFpu)
            #expect(absorptionSchemeVM.absorptionBlocks[1].absorptionTime == absorptionBlocks[2].absorptionTime)
            #expect(absorptionSchemeVM.absorptionBlocks[2].maxFpu == absorptionBlocks[3].maxFpu)
            #expect(absorptionSchemeVM.absorptionBlocks[2].absorptionTime == absorptionBlocks[3].absorptionTime)
            #expect(absorptionSchemeVM.absorptionBlocks[3].maxFpu == absorptionBlocks[4].maxFpu)
            #expect(absorptionSchemeVM.absorptionBlocks[3].absorptionTime == absorptionBlocks[4].absorptionTime)
            #expect(absorptionSchemeVM.absorptionBlocks[4].maxFpu == 14)
            #expect(absorptionSchemeVM.absorptionBlocks[4].absorptionTime == 20)
            #expect(AbsorptionBlock.fetchAll().count == 5)
            
            // Remove one block outside index
            #expect(!absorptionSchemeVM.removeAbsorptionBlock(at: 6, saveContext: false))
            #expect(AbsorptionBlock.fetchAll().count == 5)
            
            // Remove one block inside index
            #expect(absorptionSchemeVM.resetToDefaultAbsorptionBlocks(saveContext: false, errorMessage: &errorMessage))
            #expect(absorptionSchemeVM.removeAbsorptionBlock(at: 3, saveContext: false))
            #expect(AbsorptionBlock.fetchAll().count == 4)
            #expect(absorptionSchemeVM.absorptionBlocks[0].maxFpu == Int(absorptionBlocks[0].maxFpu / 2))
            #expect(absorptionSchemeVM.absorptionBlocks[0].absorptionTime == Int(absorptionBlocks[0].absorptionTime / 2))
            #expect(absorptionSchemeVM.absorptionBlocks[1].maxFpu == Int(absorptionBlocks[1].maxFpu / 2))
            #expect(absorptionSchemeVM.absorptionBlocks[1].absorptionTime == Int(absorptionBlocks[1].absorptionTime / 2))
            #expect(absorptionSchemeVM.absorptionBlocks[2].maxFpu == Int(absorptionBlocks[2].maxFpu / 2))
            #expect(absorptionSchemeVM.absorptionBlocks[2].absorptionTime == Int(absorptionBlocks[2].absorptionTime / 2))
            #expect(absorptionSchemeVM.absorptionBlocks[3].maxFpu == Int(absorptionBlocks[4].maxFpu / 2))
            #expect(absorptionSchemeVM.absorptionBlocks[3].absorptionTime == Int(absorptionBlocks[4].absorptionTime / 2))
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
