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
            let foodItem = FoodItem.create(from: foodItemPersistence, saveContext: false)
            let ingredient = Ingredient.create(from: foodItem)
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
            let foodItem = FoodItem.create(from: foodItemPersistence, saveContext: false)
            let foodItemDataError = foodItem.validateInput()
            #expect(foodItemDataError  == FoodItemDataError.name(NSLocalizedString("Name must not be empty", comment: "")))
        }
        
        @Test("ID 4: Initialize FoodItemViewModel with error in calories", arguments: zip(
            [
                -3.567
            ],
            [
                NSLocalizedString("Input error: ", comment: "") + NSLocalizedString("Value must not be negative", comment: "")
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
            let foodItem = FoodItem.create(from: foodItemPersistence, saveContext: false)
            let foodItemDataError = foodItem.validateInput()
            #expect(foodItemDataError == FoodItemDataError.calories(errorString))
        }
        
        @Test("ID 5: Initialize FoodItemViewModel with error in carbs", arguments: zip(
            [
                -3.567
            ],
            [
                NSLocalizedString("Input error: ", comment: "") + NSLocalizedString("Value must not be negative", comment: "")
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
            let foodItem = FoodItem.create(from: foodItemPersistence, saveContext: false)
            let foodItemDataError = foodItem.validateInput()
            #expect(foodItemDataError == FoodItemDataError.carbs(errorString))
        }
        
        @Test("ID 6: Initialize FoodItemViewModel with error in sugars", arguments: zip(
            [
                -3.567
            ],
            [
                NSLocalizedString("Input error: ", comment: "") + NSLocalizedString("Value must not be negative", comment: "")
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
            let foodItem = FoodItem.create(from: foodItemPersistence, saveContext: false)
            let foodItemDataError = foodItem.validateInput()
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
            let foodItem = FoodItem.create(from: foodItemPersistence, saveContext: false)
            let foodItemDataError = foodItem.validateInput()
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
            let foodItem = FoodItem.create(from: foodItemPersistence, saveContext: false)
            let foodItemDataError = foodItem.validateInput()
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
            let foodItem = FoodItem.create(from: foodItemPersistence, saveContext: false)
            let foodItemDataError = foodItem.validateInput()
            #expect(foodItemDataError == FoodItemDataError.tooMuchCarbs(NSLocalizedString("Calories from carbs (4 kcal per gram) exceed total calories", comment: "")))
        }
        
        @Test("ID 10: Initialize FoodItemViewModel with error in amount", arguments: zip(
            [
                -3.567,
                -3
            ],
            [
                NSLocalizedString("Input error: ", comment: "") + NSLocalizedString("Value must not be negative", comment: ""),
                NSLocalizedString("Input error: ", comment: "") + NSLocalizedString("Value must not be negative", comment: "")
            ]
        ))
        func initializeFoodItemAmountError(inputValue: Double, errorString: String) async throws {
            let foodItemPersistence = FoodItemPersistence(
                id: UUID(),
                name: BusinessLogicTests.name,
                foodCategory: nil,
                category: BusinessLogicTests.category,
                favorite: BusinessLogicTests.favorite,
                caloriesPer100g: BusinessLogicTests.caloriesPer100g,
                carbsPer100g: BusinessLogicTests.carbsPer100g,
                sugarsPer100g: BusinessLogicTests.sugarsPer100g,
                amount: inputString,
                sourceID: nil,
                sourceDB: nil
            )
            let foodItem = FoodItem.create(from: foodItemPersistence, saveContext: false)
            let foodItemDataError = foodItem.validateInput()
            #expect(foodItemDataError == FoodItemDataError.amount(errorString))
        }
    }
    
    @Suite("ComposedFoodItemViewModel Tests")
    struct ComposedFoodItemViewModelTests {
        @Test("ID: 1 - Verify ComposedFoodItemViewModel business logic")
        func verifyComposedFoodItemViewModel() async throws {
            let composedFoodItemVM = try DataFactory.shared.createComposedFoodItemViewModel()
            let allFoodItemVMs = composedFoodItemVM.foodItems
            
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
            
            #expect(BusinessLogicTests.roundToFiveDecimals(composedFoodItemVM.calories) == BusinessLogicTests.roundToFiveDecimals(calories))
            #expect(BusinessLogicTests.roundToFiveDecimals(composedFoodItemVM.getCarbsInclSugars()) == BusinessLogicTests.roundToFiveDecimals(carbs))
            #expect(BusinessLogicTests.roundToFiveDecimals(composedFoodItemVM.getSugarsOnly()) == BusinessLogicTests.roundToFiveDecimals(sugars))
            #expect(BusinessLogicTests.roundToFiveDecimals(composedFoodItemVM.getRegularCarbs(treatSugarsSeparately: false)) == BusinessLogicTests.roundToFiveDecimals(carbs))
            #expect(composedFoodItemVM.getSugars(treatSugarsSeparately: false) == 0)
            #expect(BusinessLogicTests.roundToFiveDecimals(composedFoodItemVM.getRegularCarbs(treatSugarsSeparately: true)) == BusinessLogicTests.roundToFiveDecimals(carbs - sugars))
            #expect(BusinessLogicTests.roundToFiveDecimals(composedFoodItemVM.getSugars(treatSugarsSeparately: true)) == BusinessLogicTests.roundToFiveDecimals(sugars))
            #expect(BusinessLogicTests.roundToFiveDecimals(composedFoodItemVM.fpus.fpu) == BusinessLogicTests.roundToFiveDecimals(fpus))
        }
    }
    
    @Suite("TypicalAmountViewModel Tests")
    struct TypicalAmountViewModelTests {
        @Test("ID 1 - Initialize with amount as number")
        func initializeWithAmountAsNumber() async throws {
            let typicalAmountVM = TypicalAmountViewModel(amount: BusinessLogicTests.amount, comment: BusinessLogicTests.comment)
            BusinessLogicTests.checkTypicalAmountValues(typicalAmountVM: typicalAmountVM)
        }
        
        @Test("ID 2 - Initialize with amount as string")
        func initializeWithAmountAsString() async throws {
            var errorMessage = ""
            let typicalAmountVM = TypicalAmountViewModel(amountAsString: BusinessLogicTests.amountAsString, comment: BusinessLogicTests.comment, errorMessage: &errorMessage)
            #expect(errorMessage.isEmpty)
            try #require(typicalAmountVM != nil)
            BusinessLogicTests.checkTypicalAmountValues(typicalAmountVM: typicalAmountVM!)
        }
        
        @Test("ID 3 - Initialize with amount as string with errors", arguments: zip(
            [
                "asdf",
                "-3",
                "0"
            ],
            [
                NSLocalizedString("Input error: ", comment: "") + NSLocalizedString("Value not a number", comment: ""),
                NSLocalizedString("Input error: ", comment: "") + NSLocalizedString("Value must not be zero or negative", comment: ""),
                NSLocalizedString("Input error: ", comment: "") + NSLocalizedString("Value must not be zero or negative", comment: "")
            ]
        ))
        func initializeWithAmountAsStringWithErrors(inputString: String, errorString: String) async throws {
            var errorMessage = ""
            let typicalAmountVM = TypicalAmountViewModel(amountAsString: inputString, comment: BusinessLogicTests.comment, errorMessage: &errorMessage)
            #expect(typicalAmountVM == nil)
            #expect(errorMessage == errorString)
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
            let absorptionBlockVM1 = AbsorptionBlockViewModel(from: absorptionBlock)
            
            var alert: SimpleAlertType? = nil
            let absorptionBlockVM2 = AbsorptionBlockViewModel(maxFpuAsString: BusinessLogicTests.maxFPUAsString, absorptionTimeAsString: BusinessLogicTests.absorptionTimeAsString, activeAlert: &alert)
            #expect(alert == nil)
            #expect(absorptionBlockVM2 != nil)
            #expect(absorptionBlockVM1 == absorptionBlockVM2)
        }
        
        @Test("ID 2 - Test Absorption Block initializer with wrong maxFPU", arguments: zip(
            [
                "54kc",
                "-3",
                "0"
            ],
            [
                NSLocalizedString("Input error: ", comment: "") + NSLocalizedString("Value not a number", comment: ""),
                NSLocalizedString("Input error: ", comment: "") + NSLocalizedString("Value must not be zero or negative", comment: ""),
                NSLocalizedString("Input error: ", comment: "") + NSLocalizedString("Value must not be zero or negative", comment: "")
            ]
        ))
        func absorptionBlockInitializerWithWrongMaxFPU(inputString: String, errorString: String) async throws {
            var alert: SimpleAlertType? = nil
            let absorptionBlockVM = AbsorptionBlockViewModel(maxFpuAsString: inputString, absorptionTimeAsString: BusinessLogicTests.absorptionTimeAsString, activeAlert: &alert)
            #expect(alert?.messageAsString() == errorString)
            #expect(absorptionBlockVM == nil)
        }
        
        @Test("ID 3 - Test Absorption Block initializer with wrong absorption time", arguments: zip(
            [
                "54kc",
                "-3",
                "0"
            ],
            [
                NSLocalizedString("Input error: ", comment: "") + NSLocalizedString("Value not a number", comment: ""),
                NSLocalizedString("Input error: ", comment: "") + NSLocalizedString("Value must not be zero or negative", comment: ""),
                NSLocalizedString("Input error: ", comment: "") + NSLocalizedString("Value must not be zero or negative", comment: "")
            ]
        ))
        func absorptionBlockInitializerWithWrongAbsorptionTime(inputString: String, errorString: String) async throws {
            var alert: SimpleAlertType? = nil
            let absorptionBlockVM = AbsorptionBlockViewModel(maxFpuAsString: BusinessLogicTests.maxFPUAsString, absorptionTimeAsString: inputString, activeAlert: &alert)
            #expect(alert?.messageAsString() == errorString)
            #expect(absorptionBlockVM == nil)
        }
        
        @Test("ID 4 - Absorption Scheme")
        func absorptionScheme() async throws {
            // Create AbsorptionSchemeViewModel
            let absorptionSchemeVM = AbsorptionScheme()
            for absorptionBlockJson in absorptionBlocks {
                absorptionSchemeVM.absorptionBlockVMs.append(AbsorptionBlockViewModel(from: absorptionBlockJson))
            }
            #expect(absorptionSchemeVM.absorptionBlockVMs.count == 5)
            for absorptionBlockVM in absorptionSchemeVM.absorptionBlockVMs {
                let cdAbsorptionBlock = AbsorptionBlock.getAbsorptionBlockByID(id: absorptionBlockVM.id)
                try #require(cdAbsorptionBlock != nil)
                BusinessLogicTests.compareAbsorptionBlocks(cdAbsorptionBlock: cdAbsorptionBlock!, absorptionBlockVM: absorptionBlockVM)
            }
            
            // Try to add absorption blocks with existing maxFPU
            var alert: SimpleAlertType? = nil
            for absorptionBlock in BusinessLogicTests.absorptionBlocks {
                alert = absorptionSchemeVM.add(newAbsorptionBlock: AbsorptionBlockViewModel(from: absorptionBlock))
                #expect(alert?.messageAsString() == NSLocalizedString("Maximum FPU value already exists", comment: ""))
            }
            
            // Try to add the first absorption block with an absorption time equal to the following (wrong)
            alert = nil
            alert = absorptionSchemeVM.add(newAbsorptionBlock: AbsorptionBlockViewModel(maxFpuAsString: "1", absorptionTimeAsString: "6", activeAlert: &alert)!)
            #expect(alert?.messageAsString() == NSLocalizedString("Absorption time is equals or larger than the one of the following absorption block", comment: ""))
            #expect(absorptionSchemeVM.absorptionBlockVMs.count == 5)
            
            // Try to add the first absorption block with an absorption time more than the following (wrong)
            alert = nil
            alert = absorptionSchemeVM.add(newAbsorptionBlock: AbsorptionBlockViewModel(maxFpuAsString: "1", absorptionTimeAsString: "7", activeAlert: &alert)!)
            #expect(alert?.messageAsString() == NSLocalizedString("Absorption time is equals or larger than the one of the following absorption block", comment: ""))
            #expect(absorptionSchemeVM.absorptionBlockVMs.count == 5)
            
            // Try to add the first absorption block with an absorption time less than the following (correct)
            alert = nil
            alert = absorptionSchemeVM.add(newAbsorptionBlock: AbsorptionBlockViewModel(maxFpuAsString: "1", absorptionTimeAsString: "5", activeAlert: &alert)!)
            #expect(alert == nil)
            #expect(absorptionSchemeVM.absorptionBlockVMs.count == 6)
            
            // Try to add the last absorption block with an absorption time equal to the previous (wrong)
            alert = nil
            alert = absorptionSchemeVM.add(newAbsorptionBlock: AbsorptionBlockViewModel(maxFpuAsString: "16", absorptionTimeAsString: "16", activeAlert: &alert)!)
            #expect(alert?.messageAsString() == NSLocalizedString("Absorption time is equals or less than the one of the block before", comment: ""))
            #expect(absorptionSchemeVM.absorptionBlockVMs.count == 6)
            
            // Try to add the first absorption block with an absorption time less than the previous (wrong)
            alert = nil
            alert = absorptionSchemeVM.add(newAbsorptionBlock: AbsorptionBlockViewModel(maxFpuAsString: "16", absorptionTimeAsString: "15", activeAlert: &alert)!)
            #expect(alert?.messageAsString() == NSLocalizedString("Absorption time is equals or less than the one of the block before", comment: ""))
            #expect(absorptionSchemeVM.absorptionBlockVMs.count == 6)
            
            // Try to add the last absorption block with an absorption time more than the previous (correct)
            alert = nil
            alert = absorptionSchemeVM.add(newAbsorptionBlock: AbsorptionBlockViewModel(maxFpuAsString: "16", absorptionTimeAsString: "20", activeAlert: &alert)!)
            #expect(alert == nil)
            #expect(absorptionSchemeVM.absorptionBlockVMs.count == 7)
            
            // Try to add the last absorption block with an absorption time equal to the previous (wrong)
            alert = nil
            alert = absorptionSchemeVM.add(newAbsorptionBlock: AbsorptionBlockViewModel(maxFpuAsString: "7", absorptionTimeAsString: "10", activeAlert: &alert)!)
            #expect(alert?.messageAsString() == NSLocalizedString("Absorption time must be between previous and following block", comment: ""))
            #expect(absorptionSchemeVM.absorptionBlockVMs.count == 7)
            
            // Try to add the first absorption block with an absorption time less than the previous (wrong)
            alert = nil
            alert = absorptionSchemeVM.add(newAbsorptionBlock: AbsorptionBlockViewModel(maxFpuAsString: "7", absorptionTimeAsString: "12", activeAlert: &alert)!)
            #expect(alert?.messageAsString() == NSLocalizedString("Absorption time must be between previous and following block", comment: ""))
            #expect(absorptionSchemeVM.absorptionBlockVMs.count == 7)
            
            // Try to add the last absorption block with an absorption time more than the previous (correct)
            alert = nil
            alert = absorptionSchemeVM.add(newAbsorptionBlock: AbsorptionBlockViewModel(maxFpuAsString: "7", absorptionTimeAsString: "11", activeAlert: &alert)!)
            #expect(alert == nil)
            #expect(absorptionSchemeVM.absorptionBlockVMs.count == 8)
            
            // Try resetting
            var errorMessage = ""
            #expect(absorptionSchemeVM.resetToDefaultAbsorptionBlocks(errorMessage: &errorMessage))
            #expect(absorptionSchemeVM.absorptionBlockVMs.count == 5)
            #expect(absorptionSchemeVM.absorptionBlockVMs[0].maxFpu == Int(absorptionBlocks[0].maxFpu / 2))
            #expect(absorptionSchemeVM.absorptionBlockVMs[0].absorptionTime == Int(absorptionBlocks[0].absorptionTime / 2))
            #expect(absorptionSchemeVM.absorptionBlockVMs[1].maxFpu == Int(absorptionBlocks[1].maxFpu / 2))
            #expect(absorptionSchemeVM.absorptionBlockVMs[1].absorptionTime == Int(absorptionBlocks[1].absorptionTime / 2))
            #expect(absorptionSchemeVM.absorptionBlockVMs[2].maxFpu == Int(absorptionBlocks[2].maxFpu / 2))
            #expect(absorptionSchemeVM.absorptionBlockVMs[2].absorptionTime == Int(absorptionBlocks[2].absorptionTime / 2))
            #expect(absorptionSchemeVM.absorptionBlockVMs[3].maxFpu == Int(absorptionBlocks[3].maxFpu / 2))
            #expect(absorptionSchemeVM.absorptionBlockVMs[3].absorptionTime == Int(absorptionBlocks[3].absorptionTime / 2))
            #expect(absorptionSchemeVM.absorptionBlockVMs[4].maxFpu == Int(absorptionBlocks[4].maxFpu / 2))
            #expect(absorptionSchemeVM.absorptionBlockVMs[4].absorptionTime == Int(absorptionBlocks[4].absorptionTime / 2))
            
            // Try replacing blocks from back to front
            alert = nil
            alert = absorptionSchemeVM.replace(existingAbsorptionBlockID: absorptionSchemeVM.absorptionBlockVMs[4].id, newMaxFpuAsString: String(absorptionBlocks[4].maxFpu), newAbsorptionTimeAsString: String(absorptionBlocks[4].absorptionTime))
            #expect(alert == nil)
            
            alert = nil
            alert = absorptionSchemeVM.replace(existingAbsorptionBlockID: absorptionSchemeVM.absorptionBlockVMs[3].id, newMaxFpuAsString: String(absorptionBlocks[3].maxFpu), newAbsorptionTimeAsString: String(absorptionBlocks[3].absorptionTime))
            #expect(alert == nil)
            
            alert = nil
            alert = absorptionSchemeVM.replace(existingAbsorptionBlockID: absorptionSchemeVM.absorptionBlockVMs[2].id, newMaxFpuAsString: String(absorptionBlocks[2].maxFpu), newAbsorptionTimeAsString: String(absorptionBlocks[2].absorptionTime))
            #expect(alert == nil)
            
            alert = nil
            alert = absorptionSchemeVM.replace(existingAbsorptionBlockID: absorptionSchemeVM.absorptionBlockVMs[1].id, newMaxFpuAsString: String(absorptionBlocks[1].maxFpu), newAbsorptionTimeAsString: String(absorptionBlocks[1].absorptionTime))
            #expect(alert == nil)
            
            alert = nil
            alert = absorptionSchemeVM.replace(existingAbsorptionBlockID: absorptionSchemeVM.absorptionBlockVMs[0].id, newMaxFpuAsString: String(absorptionBlocks[0].maxFpu), newAbsorptionTimeAsString: String(absorptionBlocks[0].absorptionTime))
            #expect(alert == nil)
            
            // Try to replace first with last block
            #expect(absorptionSchemeVM.replace(existingAbsorptionBlockID: absorptionSchemeVM.absorptionBlockVMs[0].id, newMaxFpuAsString: "14", newAbsorptionTimeAsString: "20") == nil)
            #expect(absorptionSchemeVM.absorptionBlockVMs.count == 5)
            #expect(absorptionSchemeVM.absorptionBlockVMs[0].maxFpu == absorptionBlocks[1].maxFpu)
            #expect(absorptionSchemeVM.absorptionBlockVMs[0].absorptionTime == absorptionBlocks[1].absorptionTime)
            #expect(absorptionSchemeVM.absorptionBlockVMs[1].maxFpu == absorptionBlocks[2].maxFpu)
            #expect(absorptionSchemeVM.absorptionBlockVMs[1].absorptionTime == absorptionBlocks[2].absorptionTime)
            #expect(absorptionSchemeVM.absorptionBlockVMs[2].maxFpu == absorptionBlocks[3].maxFpu)
            #expect(absorptionSchemeVM.absorptionBlockVMs[2].absorptionTime == absorptionBlocks[3].absorptionTime)
            #expect(absorptionSchemeVM.absorptionBlockVMs[3].maxFpu == absorptionBlocks[4].maxFpu)
            #expect(absorptionSchemeVM.absorptionBlockVMs[3].absorptionTime == absorptionBlocks[4].absorptionTime)
            #expect(absorptionSchemeVM.absorptionBlockVMs[4].maxFpu == 14)
            #expect(absorptionSchemeVM.absorptionBlockVMs[4].absorptionTime == 20)
            #expect(AbsorptionBlock.fetchAll().count == 5)
            
            // Remove one block outside index
            #expect(!absorptionSchemeVM.removeAbsorptionBlock(at: 6))
            #expect(AbsorptionBlock.fetchAll().count == 5)
            
            // Remove one block inside index
            #expect(absorptionSchemeVM.resetToDefaultAbsorptionBlocks(errorMessage: &errorMessage))
            #expect(absorptionSchemeVM.removeAbsorptionBlock(at: 3))
            #expect(AbsorptionBlock.fetchAll().count == 4)
            #expect(absorptionSchemeVM.absorptionBlockVMs[0].maxFpu == Int(absorptionBlocks[0].maxFpu / 2))
            #expect(absorptionSchemeVM.absorptionBlockVMs[0].absorptionTime == Int(absorptionBlocks[0].absorptionTime / 2))
            #expect(absorptionSchemeVM.absorptionBlockVMs[1].maxFpu == Int(absorptionBlocks[1].maxFpu / 2))
            #expect(absorptionSchemeVM.absorptionBlockVMs[1].absorptionTime == Int(absorptionBlocks[1].absorptionTime / 2))
            #expect(absorptionSchemeVM.absorptionBlockVMs[2].maxFpu == Int(absorptionBlocks[2].maxFpu / 2))
            #expect(absorptionSchemeVM.absorptionBlockVMs[2].absorptionTime == Int(absorptionBlocks[2].absorptionTime / 2))
            #expect(absorptionSchemeVM.absorptionBlockVMs[3].maxFpu == Int(absorptionBlocks[4].maxFpu / 2))
            #expect(absorptionSchemeVM.absorptionBlockVMs[3].absorptionTime == Int(absorptionBlocks[4].absorptionTime / 2))
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
    
    private static func checkTypicalAmountValues(typicalAmountVM: TypicalAmountViewModel) {
        #expect(typicalAmountVM.amount == BusinessLogicTests.amount)
        #expect(typicalAmountVM.comment == BusinessLogicTests.comment)
        #expect(typicalAmountVM.amountAsString == String(BusinessLogicTests.amount))
    }
    
    private static func compareAbsorptionBlocks(cdAbsorptionBlock: AbsorptionBlock, absorptionBlockVM: AbsorptionBlockViewModel) {
        #expect(cdAbsorptionBlock.maxFpu == absorptionBlockVM.maxFpu)
        #expect(cdAbsorptionBlock.absorptionTime == absorptionBlockVM.absorptionTime)
    }
        
    private static func roundToFiveDecimals(_ value: Double) -> Double {
        return Double(round(100000 * value) / 100000)
    }
}
