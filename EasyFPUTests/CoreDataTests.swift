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

@Suite("Core Data Tests")
struct CoreDataTests {
    
    @Suite("FoodItem behavior")
    struct FoodItemBehavior {
        
        @Test("ID: 1 - Create FoodItem - no FoodItem")
        func createFoodItemDuplicateFalseNoFoodItem() throws {
            // Create new FoodItem in DB
            let foodItemVM = try DataFactory.shared.createFoodItemPersistence()
            foodItemVM.save()
            
            // Check if FoodItem was created in DB
            let foodItem = FoodItem.getFoodItemByID(id: foodItemVM.id)
            try #require(foodItem != nil, "The saved FoodItem should be found in the DB by its ID.")
            assessFoodItemValues(foodItemVM: foodItemVM, foodItem: foodItem!)
            
            // Remove FoodItem from DB
            try CoreDataTests.deleteFoodItemFromDB(foodItem!)
        }
        
        @Test("ID: 3 - Create FoodItem - existing FoodItem with identical ID and nutritional values")
        func createFoodItemIdenticalFoodItem() throws {
            // Create new FoodItem in DB
            let foodItemVM = try DataFactory.shared.createFoodItemPersistence()
            let cdFoodItem = try CoreDataTests.createFoodItemInDB(from: foodItemVM, withTypicalAmounts: false)
            
            // Add duplicate with same ID and same nutritional values
            let duplicateFoodItemVM = try DataFactory.shared.createFoodItemPersistence(id: foodItemVM.id)
            duplicateFoodItemVM.save()
            
            // Check for all FoodItems with this name - we still only expect one
            let foodItems = FoodItem.getFoodItemsByName(name: foodItemVM.name)
            try #require(foodItems != nil, "The FoodItem should be found in the DB by its name.")
            #expect(foodItems!.count == 1, "Only one FoodItem should be found by the given name.")
            
            // Check for identical IDs
            #expect(cdFoodItem.id == foodItemVM.id, "The IDs of the FoodItem and the FoodItemVM should be identical.")
            assessFoodItemValues(foodItemVM: foodItemVM, foodItem: cdFoodItem)
            
            // Remove FoodItem from DB
            try CoreDataTests.deleteFoodItemFromDB(cdFoodItem)
        }
        
        @Test("ID: 4 - Create FoodItem - existing FoodItem with identical ID but different nutritional values")
        func createFoodItemIdenticalFoodItemIDOnly() throws {
            // Create a new FoodItem in the DB
            let foodItemVM = try DataFactory.shared.createFoodItemPersistence()
            _ = try CoreDataTests.createFoodItemInDB(from: foodItemVM, withTypicalAmounts: false)
            
            // Add duplicate with same ID
            let duplicateFoodItemVM = try DataFactory.shared.createFoodItemPersistence(id: foodItemVM.id)
            
            // Modify nutritional values
            duplicateFoodItemVM.carbsPer100g = 45
            
            // Save the duplicate
            duplicateFoodItemVM.save()
            
            // Check if duplicated FoodItem was created in DB
            let bothFoodItems = FoodItem.getFoodItemsByName(name: duplicateFoodItemVM.name)
            try #require(bothFoodItems != nil, "There need to be FoodItems with the given name in the DB.")
            try #require(bothFoodItems!.count == 2, "There need to be two FoodItems with the given name in the DB.")
            
            // Check for different IDs
            let foodItem1ID = bothFoodItems![0].id
            let foodItem2ID = bothFoodItems![1].id
            #expect(foodItem1ID != foodItem2ID)
            
            // Assess values
            assessFoodItemValues(foodItemVM: foodItemVM, foodItem: bothFoodItems![0])
            assessFoodItemValues(foodItemVM: duplicateFoodItemVM, foodItem: bothFoodItems![1])
            
            // Remove FoodItems from DB
            try CoreDataTests.deleteFoodItemFromDB(bothFoodItems![0])
            try CoreDataTests.deleteFoodItemFromDB(bothFoodItems![1])
        }
        
        @Test("ID: 5 - Create FoodItem from ComposedFoodItemVM - no existing related FoodItem")
        func createFoodItemFromComposedFoodItemVMNoExistingRelatedFoodItem() throws {
            // Get ComposedFoodItemPersistence and create the related FoodItem
            let composedFoodItemVM = try DataFactory.shared.createComposedFoodItemPersistence()
            let relatedFoodItem = FoodItem.create(from: composedFoodItemVM, saveContext: false)
            
            // Check if FoodItem was created in DB
            let cdFoodItem = FoodItem.getFoodItemByID(id: composedFoodItemVM.id)
            try #require(cdFoodItem != nil, "The saved FoodItem should be found in the DB by its ID.")
            #expect(relatedFoodItem == cdFoodItem, "The FoodItems should be identical.")
            
            // Check for typical amounts, 8 are expected, relating to the relatedFoodItem
            let typicalAmounts = relatedFoodItem.typicalAmounts.array(of: TypicalAmount.self)
            #expect(typicalAmounts.count == 8, "8 TypicalAmounts should have been created.")
            
            // Delete FoodItem
            try CoreDataTests.deleteFoodItemFromDB(cdFoodItem!)
        }
        
        @Test("ID: 6 - Create FoodItem from ComposedFoodItemVM - existing related FoodItem")
        func createFoodItemFromComposedFoodItemVMExistingRelatedFoodItem() throws {
            // Get the ComposedFoodItemPersistence
            let composedFoodItemVM = try DataFactory.shared.createComposedFoodItemPersistence()
            
            // Create a corresponding FoodItemPersistence
            let existingFoodItemVM = try DataFactory.shared.createFoodItemPersistence(for: composedFoodItemVM)
            
            // Save related FoodItem
            existingFoodItemVM.save()
            
            // Check if FoodItem exists with identical ID as ComposedFoodItemPersistence
            let existingCDFoodItem = FoodItem.getFoodItemByID(id: composedFoodItemVM.id)
            try #require(existingCDFoodItem != nil)
            
            // Create the related FoodItem, which must be the existingFoodItem
            let relatedCDFoodItem = FoodItem.create(from: composedFoodItemVM, saveContext: false)
            #expect(relatedCDFoodItem == existingCDFoodItem, "The related FoodItem must be identical to the existing FoodItem")
            
            // Check for correct ID
            #expect(relatedCDFoodItem.id == composedFoodItemVM.id)
            
            // Check for typical amounts, 8 are expected, relating to the relatedFoodItem
            let typicalAmounts = relatedCDFoodItem.typicalAmounts.array(of: TypicalAmount.self)
            #expect(typicalAmounts.count == 8)
            for typicalAmount in typicalAmounts {
                #expect(typicalAmount.foodItem == relatedCDFoodItem)
            }
            
            // Delete FoodItem
            try CoreDataTests.deleteFoodItemFromDB(relatedCDFoodItem)
        }
        
        @Test("ID: 9 - Duplicate FoodItem - with TypicalAmounts")
        func duplicateFoodItemWithTypicalAmounts() throws {
            // Create new FoodItem with TypicalAmounts in DB
            let foodItemVM = try DataFactory.shared.createFoodItemPersistence()
            let cdFoodItem = try CoreDataTests.createFoodItemInDB(from: foodItemVM, withTypicalAmounts: true)
            let foodItemID = cdFoodItem.id
            
            // Check TypicalAmount results of FoodItem in DB
            let foodItemTypicalAmounts = cdFoodItem.typicalAmounts.array(of: TypicalAmount.self)
            #expect(foodItemTypicalAmounts.count == 4, "There should be 4 TypicalAmounts associated with the FoodItem.")
            
            // Duplicate the cdFoodItem
            let duplicatedCDFoodItem = cdFoodItem.duplicate(saveContext: false)
            #expect(duplicatedCDFoodItem != nil, "The duplication should have been successful.")
            
            // Check results in DB and get the FoodItem
            let duplicatedCDFoodItemInDB = FoodItem.getFoodItemByID(id: duplicatedCDFoodItem!.id)
            try #require(duplicatedCDFoodItemInDB != nil, "The duplicated FoodItem should be found in the DB by its ID.")
            #expect(duplicatedCDFoodItem == duplicatedCDFoodItemInDB, "The FoodItems need to be identical.")
            let duplicatedFoodItemID = duplicatedCDFoodItem!.id
            #expect(foodItemID != duplicatedFoodItemID, "The IDs of the FoodItem and the duplicated FoodItem need to be different.")
            
            // Check TypicalAmount results of duplicated FoodItem in DB
            let duplicatedFoodItemTypicalAmounts = duplicatedCDFoodItem!.typicalAmounts.array(of: TypicalAmount.self)
            #expect(duplicatedFoodItemTypicalAmounts.count == 4, "There should be 4 TypicalAmounts associated with the duplicated FoodItem.")
            
            // Cross-check sum of all amounts of both FoodItems
            var foodItemTypicalAmountSum = 0
            for typicalAmount in cdFoodItem.typicalAmounts!  {
                foodItemTypicalAmountSum += Int((typicalAmount as! TypicalAmount).amount)
            }
            var duplicatedFoodItemTypicalAmountSum = 0
            for typicalAmount in duplicatedCDFoodItem!.typicalAmounts!  {
                duplicatedFoodItemTypicalAmountSum += Int((typicalAmount as! TypicalAmount).amount)
            }
            #expect(foodItemTypicalAmountSum == duplicatedFoodItemTypicalAmountSum, "The sum of amounts of both FoodItems needs to be identical.")
            
            // Check values
            assessFoodItemValues(foodItem1: cdFoodItem, foodItem2: duplicatedCDFoodItem!, sameName: false)
            
            // Delete FoodItem and (cascading) TypicalAmounts
            try CoreDataTests.deleteFoodItemFromDB(cdFoodItem)
            
            // Delete duplicated FoodItem and (cascading) TypicalAmounts
            try CoreDataTests.deleteFoodItemFromDB(duplicatedCDFoodItem!)
        }
        
        @Test("ID: 10 - Add TypicalAmount")
        func addTypicalAmount() throws {
            // Create new FoodItem in DB
            let foodItemVM = try DataFactory.shared.createFoodItemPersistence()
            let cdFoodItem = try CoreDataTests.createFoodItemInDB(from: foodItemVM, withTypicalAmounts: false)
            
            // Create (unlinked) typicalAmounts in DB and add them to the FoodItem
            let typicalAmountVMs = try DataFactory.shared.getTypicalAmounts()
            for typicalAmountVM in typicalAmountVMs {
                let cdTypicalAmount = TypicalAmount.create(from: typicalAmountVM, saveContext: false)
                FoodItem.add(cdTypicalAmount, to: cdFoodItem, saveContext: false)
            }
            
            // Check DB for TypicalAmounts
            try #require(cdFoodItem.typicalAmounts != nil)
            #expect(cdFoodItem.typicalAmounts!.count == 4)
            
            // Delete FoodItem and (cascading) TypicalAmounts
            try CoreDataTests.deleteFoodItemFromDB(cdFoodItem)
        }
        
        @Test("ID: 11 - Change category")
        func changeCategory() throws {
            // Create new FoodItem in DB
            let foodItemVM = try DataFactory.shared.createFoodItemPersistence()
            let cdFoodItem = try CoreDataTests.createFoodItemInDB(from: foodItemVM, withTypicalAmounts: false)
            
            // Change category to FoodItemCategory.product
            cdFoodItem.setCategory(to: FoodItemCategory.product.rawValue, saveContext: false)
            #expect(cdFoodItem.category == FoodItemCategory.product.rawValue)
            
            // Change category to FoodItemCategory.ingredient
            cdFoodItem.setCategory(to: FoodItemCategory.ingredient.rawValue, saveContext: false)
            #expect(cdFoodItem.category == FoodItemCategory.ingredient.rawValue)
            
            // Delete FoodItem and (cascading) TypicalAmounts
            try CoreDataTests.deleteFoodItemFromDB(cdFoodItem)
        }
    }
    
    @Suite("ComposedFoodItem behavior")
    struct ComposedFoodItemBehavior {
        @Test("ID: 12 - Create ComposedFoodItem - import = true")
        func createComposedFoodItemImportTrue() throws {
            // Get the VM and and save as Core Data ComposedFoodItem
            let composedFoodItemVM = try DataFactory.shared.createComposedFoodItemPersistence() // Pizzateig with 5 Ingredients
            let cdComposedFoodItem = try CoreDataTests.createComposedFoodItemInDB(from: composedFoodItemVM)
            let cdFoodItem = cdComposedFoodItem.foodItem
            
            // Get the IDs of the FoodItems
            var foodItemIDs = [UUID]()
            foodItemIDs.append(cdFoodItem!.id) // The ID of the FoodItem related to the ComposedFoodItem
            
            // Get the Ingredients - for each of them, a corresponding FoodItem with identical ID should have been created
            let allIngredients = cdComposedFoodItem.ingredients.allObjects as! [Ingredient]
            #expect(allIngredients.count == 5, "There should be 5 ingredients.")
            for ingredient in allIngredients {
                let relatedFoodItemID = ingredient.relatedFoodItemID
                try #require(relatedFoodItemID != nil)
                foodItemIDs.append(relatedFoodItemID!)
                #expect(FoodItem.getFoodItemByID(id: relatedFoodItemID!) != nil, "A FoodItem with identical ID than the Ingredient should be in the DB.")
            }
            
            // Check number of FoodItems (5 for ingredients, 1 for the ComposedFoodItem)
            #expect(foodItemIDs.count == 6, "We expect 6 FoodItems: 5 for ingredients, 1 for the ComposedFoodItem")
            
            // Check if the FoodItem related to the ComposedFoodItem is in the DB
            try #require(FoodItem.getFoodItemByID(id: foodItemIDs[0]) != nil, "The FoodItem related to the ComposedFoodItem should be found in the DB.")
            // Check if the FoodItems created from an ingredient are in DB and linked to an Ingredient
            for i in 1...5 {
                let foodItem = FoodItem.getFoodItemByID(id: foodItemIDs[i])
                try #require(foodItem != nil, "The FoodItem related to the Ingredient should be found in the DB.")
                try #require(foodItem!.ingredients != nil, "The FoodItem should have Ingredients.")
                #expect(foodItem!.ingredients!.count >= 1, "The FoodItem should be linked to at least one Ingredient.")
            }
            
            // Check for correct reference
            #expect(cdComposedFoodItem.foodItem == cdFoodItem!, "The ComposedFoodItem should have a reference to a FoodItem.")
            
            // Check for identical IDs
            #expect(cdComposedFoodItem.id == cdFoodItem!.id, "The IDs of the ComposedFoodItem and the FoodItem should be identical.")
            
            // Check and get associated Ingredients from DB
            for ingredient in allIngredients {
                #expect(ingredient.composedFoodItem == cdComposedFoodItem, "The Ingredient should have a reference to a ComposedFoodItem.")
                #expect(ingredient.foodItem != nil, "The ingredient should have a reference to a FoodItem.")
                try assessIngredientValues(ingredient: ingredient)
            }
            
            // Delete ComposedFoodItem and (cascading) Ingredients
            try CoreDataTests.deleteComposedFoodItemFromDB(cdComposedFoodItem)
            
            // The FoodItems created for the Ingredients should still be in the DB; their IDs are index 1 to 5 in the foodItemIDs array
            for i in 1...5 {
                let foodItem = FoodItem.getFoodItemByID(id: foodItemIDs[i])
                #expect(foodItem != nil, "The FoodItem should still be in the DB.")
                if let foodItem {
                    try CoreDataTests.deleteFoodItemFromDB(foodItem)
                }
            }
            
            // Delete FoodItem - 5 FoodItems for Ingredients should remain
            try CoreDataTests.deleteFoodItemFromDB(cdFoodItem!)
        }
        
        @Test("ID: 13 - Create ComposedFoodItem - import = false")
        func createComposedFoodItemImportFalse() throws {
            // Get the VM and and save as Core Data ComposedFoodItem
            let composedFoodItemVM = try DataFactory.shared.createComposedFoodItemPersistence() // Pizzateig with 5 Ingredients
            
            // Create FoodItems for ingredients
            var foodItemIDs = [UUID]()
            for foodItemVM in composedFoodItemVM.ingredients {
                // Get existing or new FoodItem
                var dataError: FoodItemDataError = .none
                let relatedFoodItem = FoodItem.create(from: foodItemVM, saveContext: false, dataError: &dataError)
                #expect(dataError == .none, "There should be no data error.")
                #expect(relatedFoodItem != nil, "A FoodItem should have been created.")
                foodItemIDs.append(relatedFoodItem!.id)
            }
            
            // Check FoodItems in DB - it should be 5 (the 5 ingredients)
            #expect(foodItemIDs.count == 5, "There should be 5 FoodItems.")
            for foodItemId in foodItemIDs {
                #expect(FoodItem.getFoodItemByID(id: foodItemId) != nil, "A FoodItem with this ID should exist.")
            }
            
            // Save the ComposedFoodItem
            let cdComposedFoodItem = try CoreDataTests.createComposedFoodItemInDB(from: composedFoodItemVM)
            let cdFoodItem: FoodItem = cdComposedFoodItem.foodItem!
            
            // Check and get FoodItem from DB
            let foodItemInDB = FoodItem.getFoodItemByID(id: cdFoodItem.id)
            try #require(foodItemInDB != nil, "The FoodItem should be in the DB.")
            
            // Check for correct reference
            #expect(cdFoodItem == foodItemInDB!)
            
            // Check for identical IDs
            #expect(cdComposedFoodItem.id == cdFoodItem.id)
            
            // Check and get associated Ingredients from DB
            let allIngredients = cdComposedFoodItem.ingredients
            #expect(allIngredients.count == 5)
            for case let ingredient as Ingredient in allIngredients {
                #expect(ingredient.composedFoodItem == cdComposedFoodItem)
                #expect(ingredient.foodItem != nil)
                try assessIngredientValues(ingredient: ingredient)
            }
            
            // Delete ComposedFoodItem (and with it Ingredients)
            try CoreDataTests.deleteComposedFoodItemFromDB(cdComposedFoodItem)
            
            // The FoodItems created for the Ingredients should still be in the DB
            for foodItemID in foodItemIDs {
                let foodItem = FoodItem.getFoodItemByID(id: foodItemID)
                #expect(foodItem != nil, "The FoodItem should still be in the DB.")
                if let foodItem {
                    try CoreDataTests.deleteFoodItemFromDB(foodItem)
                }
            }
            
            // Delete FoodItem - 5 FoodItems for Ingredients should remain
            try CoreDataTests.deleteFoodItemFromDB(cdFoodItem)
            FoodItem.delete(cdFoodItem)
        }
        
        @Test("ID: 14 - Update ComposedFoodItem - related FoodItem")
        func updateComposedFoodItemRelatedFoodItem() throws {
            // Get the VM and and save as Core Data ComposedFoodItem
            let composedFoodItemVM = try DataFactory.shared.createComposedFoodItemPersistence() // Pizzateig with 5 Ingredients
            let cdComposedFoodItem = try CoreDataTests.createComposedFoodItemInDB(from: composedFoodItemVM)
            let cdRelatedFoodItem: FoodItem = cdComposedFoodItem.foodItem!
            try #require(composedFoodItemVM.ingredients.count == 5)
            
            // Store the related FoodItem's ID in the DB
            var foodItemIDs = [UUID]()
            foodItemIDs.append(cdRelatedFoodItem.id)
            
            // Store the FoodItem IDs of the FoodItems (should be identical with those of their view models)
            for foodItem in composedFoodItemVM.ingredients {
                foodItemIDs.append(foodItem.id)
            }
            
            // Modify the composedFoodItemVM - we remove 3 and add 2 ingredient, so we have 4 in total
            let nameAppendix = " - Updated"
            cdComposedFoodItem.name += nameAppendix
            cdComposedFoodItem.numberOfPortions = Int16(composedFoodItemVM.numberOfPortions * 2)
            cdComposedFoodItem.removeFromIngredients(cdComposedFoodItem.ingredients.allObjects[4] as! Ingredient)
            cdComposedFoodItem.removeFromIngredients(cdComposedFoodItem.ingredients.allObjects[1] as! Ingredient)
            cdComposedFoodItem.removeFromIngredients(cdComposedFoodItem.ingredients.allObjects[0] as! Ingredient)
            
            // Get the two new ingredients, create them in the DB and add the IDs to the array of IDs
            let newIngredients = try DataFactory.shared.getTwoIngredients()
            for newIngredient in newIngredients {
                var dataError: FoodItemDataError = .none
                let foodItem = FoodItem.create(from: newIngredient, saveContext: false, dataError: &dataError)
                #expect(foodItem != nil, "The new FoodItem should have been created in the DB.")
                let ingredient = Ingredient.create(from: foodItem!)
                foodItemIDs.append(newIngredient.id)
                cdComposedFoodItem.addToIngredients(ingredient)
            }
            
            // Run the Core Data update
            cdComposedFoodItem.updateRelatedFoodItem()
            
            // Check and get ComposedFoodItem from DB
            let cdComposedFoodItemAfterUpdate = ComposedFoodItem.getComposedFoodItemByID(id: composedFoodItemVM.id)
            try #require(cdComposedFoodItemAfterUpdate != nil, "The ComposedFoodItem needs to be found in the DB by the same ID as the initial view model.")
            let cdFoodItemAfterUpdate = cdComposedFoodItemAfterUpdate!.foodItem
            #expect(cdFoodItemAfterUpdate != nil, "The related FoodItem should still be found in the DB.")
            #expect(cdFoodItemAfterUpdate == cdRelatedFoodItem, "The Core Data FoodItem should be identical before and after update.")
            
            // Check for identical IDs
            #expect(cdComposedFoodItem.id == cdFoodItemAfterUpdate!.id)
            
            // Check for correct reference
            #expect(cdComposedFoodItem.foodItem == cdFoodItemAfterUpdate!)
            
            // Check and get FoodItem from DB - 7 for the ingredients (5 initial ones plus 2 new ones),
            // 1 for the ComposedFoodItem, so 8 in total
            #expect(foodItemIDs.count == 8)
            for foodItemID in foodItemIDs {
                let cdFoodItem = FoodItem.getFoodItemByID(id: foodItemID)
                try #require(cdFoodItem != nil, "The FoodItem needs to be found in the DB by its ID.")
            }
            
            // Check and get associated Ingredients from DB
            let allIngredients = cdComposedFoodItem.ingredients
            #expect(allIngredients.count == 4)
            for case let ingredient as Ingredient in allIngredients {
                #expect(ingredient.composedFoodItem == cdComposedFoodItem)
                #expect(ingredient.foodItem != nil)
                try CoreDataTests.assessIngredientValues(ingredient: ingredient)
            }
            
            // Delete ComposedFoodItem (and with it Ingredients)
            try CoreDataTests.deleteComposedFoodItemFromDB(cdComposedFoodItem)
            
            for foodItemID in foodItemIDs {
                // Delete FoodItem
                let cdFoodItem = FoodItem.getFoodItemByID(id: foodItemID)
                FoodItem.delete(cdFoodItem!)
                if let deletedFoodItem = FoodItem.getFoodItemByID(id: foodItemID) {
                    #expect(deletedFoodItem.isDeleted == true, "The FoodItem should not be found in the DB after deletion.")
                }
            }
        }
        
        @Test("ID: 16 - Duplicate ComposedFoodItem")
        func duplicateComposedFoodItem() throws {
            // Create new ComposedFoodItem with Ingredients in DB
            let composedFoodItemVM = try DataFactory.shared.createComposedFoodItemPersistence()
            let cdComposedFoodItem = try CoreDataTests.createComposedFoodItemInDB(from: composedFoodItemVM)
            let composedFoodItemID = cdComposedFoodItem.id
            
            // Check Ingredients results of ComposedFoodItem in DB
            let cdIngredients = cdComposedFoodItem.ingredients
            #expect(cdIngredients.count == 5, "There should be 5 Ingredients associated with the ComposedFoodItem.")
            
            // Duplicate the cdFoodItem
            let duplicatedCDComposedFoodItem = cdComposedFoodItem.duplicate(saveContext: false)
            try #require(duplicatedCDComposedFoodItem != nil, "The duplicated ComposedFoodItem should be found in the DB.")
            
            // Check results in DB and get the FoodItem
            let duplicatedCDComposedFoodItemInDB = ComposedFoodItem.getComposedFoodItemByID(id: duplicatedCDComposedFoodItem!.id)
            try #require(duplicatedCDComposedFoodItemInDB != nil, "The duplicated ComposedFoodItem should be found in the DB by its ID.")
            #expect(duplicatedCDComposedFoodItem == duplicatedCDComposedFoodItemInDB, "The ComposedFoodItems need to be identical.")
            let duplicatedComposedFoodItemID = duplicatedCDComposedFoodItem!.id
            #expect(composedFoodItemID != duplicatedComposedFoodItemID, "The IDs of the ComposedFoodItem and the duplicated ComposedFoodItem need to be different.")
            
            // Check Ingredients results of duplicated ComposedFoodItem in DB
            let duplicatedIngredients = duplicatedCDComposedFoodItem!.ingredients
            #expect(duplicatedIngredients.count == 5, "There should be 5 Ingredients associated with the duplicated ComposedFoodItem.")
            
            // Cross-check sum of all Ingredients of both ComposedFoodItems
            var ingredientSum = 0
            for ingredient in cdIngredients  {
                ingredientSum += Int((ingredient as! Ingredient).amount)
            }
            var duplicatedIngredientSum = 0
            for ingredient in duplicatedIngredients  {
                duplicatedIngredientSum += Int((ingredient as! Ingredient).amount)
            }
            #expect(ingredientSum == duplicatedIngredientSum, "The sum of amounts of Ingredients of both ComposedFoodItems needs to be identical.")
            
            // Delete ComposedFoodItem and (cascading) Ingredients
            try CoreDataTests.deleteComposedFoodItemFromDB(cdComposedFoodItem)
            
            // Delete duplicated ComposedFoodItem and (cascading) Ingredients
            try CoreDataTests.deleteComposedFoodItemFromDB(duplicatedCDComposedFoodItem!)
        }
    }

        
        
    private static func assessFoodItemValues(foodItemVM: FoodItemPersistence, foodItem: FoodItem) {
        #expect(foodItem.name == foodItemVM.name)
        #expect(foodItem.category == foodItemVM.category.rawValue)
        #expect(foodItem.favorite == foodItemVM.favorite)
        #expect(foodItem.caloriesPer100g == foodItemVM.caloriesPer100g)
        #expect(foodItem.carbsPer100g == foodItemVM.carbsPer100g)
        #expect(foodItem.sugarsPer100g == foodItemVM.sugarsPer100g)
    }
    
    private static func assessFoodItemValues(foodItem1: FoodItem, foodItem2: FoodItem, sameName: Bool) {
        #expect(foodItem1.id != foodItem2.id)
        sameName ? #expect(foodItem1.name == foodItem2.name) : #expect(foodItem1.name != foodItem2.name)
        #expect(foodItem1.category == foodItem2.category)
        #expect(foodItem1.favorite == foodItem2.favorite)
        #expect(foodItem1.caloriesPer100g == foodItem2.caloriesPer100g)
        #expect(foodItem1.carbsPer100g == foodItem2.carbsPer100g)
        #expect(foodItem1.sugarsPer100g == foodItem2.sugarsPer100g)
    }
    
    private static func assessFoodItemValues(composedFoodItemVM: ComposedFoodItemPersistence, foodItem: FoodItem) {
        #expect(composedFoodItemVM.id == foodItem.id)
        #expect(composedFoodItemVM.name == foodItem.name)
        #expect(composedFoodItemVM.category.rawValue == foodItem.category)
        #expect(composedFoodItemVM.favorite == foodItem.favorite)
        #expect(CoreDataTests.roundToThreeDecimals(composedFoodItemVM.caloriesPer100g) == CoreDataTests.roundToThreeDecimals(foodItem.caloriesPer100g))
        #expect(CoreDataTests.roundToThreeDecimals(composedFoodItemVM.carbsPer100g) == CoreDataTests.roundToThreeDecimals(foodItem.carbsPer100g))
        #expect(CoreDataTests.roundToThreeDecimals(composedFoodItemVM.sugarsPer100g) == CoreDataTests.roundToThreeDecimals(foodItem.sugarsPer100g))
    }
    
    private static func assessIngredientValues(ingredient: Ingredient) throws {
        try #require(ingredient.foodItem != nil)
        #expect(ingredient.relatedFoodItemID == ingredient.foodItem!.id)
        #expect(ingredient.name == ingredient.foodItem!.name)
        #expect(ingredient.favorite == ingredient.foodItem!.favorite)
        #expect(ingredient.caloriesPer100g == ingredient.foodItem!.caloriesPer100g)
        #expect(ingredient.carbsPer100g == ingredient.foodItem!.carbsPer100g)
        #expect(ingredient.sugarsPer100g == ingredient.foodItem!.sugarsPer100g)
    }
    
    private static func assessTypicalAmountValues(typicalAmountVM: TypicalAmountPersistence, typicalAmount: TypicalAmount) {
        #expect(typicalAmount.amount == typicalAmountVM.amount)
        #expect(typicalAmount.comment == typicalAmountVM.comment)
    }
    
    private static func roundToThreeDecimals(_ value: Double) -> Double {
        return Double(round(1000 * value) / 1000)
    }
    
    private static func createFoodItemInDB(from foodItemVM: FoodItemPersistence, withTypicalAmounts: Bool) throws -> FoodItem {
        // Add TypicalAmounts if required
        if withTypicalAmounts {
            try DataFactory.shared.addTypicalAmounts(to: foodItemVM)
        }
        
        // Save a new FoodItem to the DB
        foodItemVM.save()
        
        // Check if FoodItem was created in DB
        let foodItem = FoodItem.getFoodItemByID(id: foodItemVM.id)
        try #require(foodItem != nil, "The saved FoodItem should be found in the DB by the same ID as the FoodItemPersistence.")
        
        // Return FoodItem
        return foodItem!
    }
    
    /// Deletes the FoodItem and its associated TypicalAmounts from the DB. Verifies if deleted.
    /// - Parameter foodItem: The FoodItem to be deleted.
    private static func deleteFoodItemFromDB(_ cdFoodItem: FoodItem) throws {
        // Get the TypicalAmounts - or an empty array if none is found
        let typicalAmountIDs = cdFoodItem.typicalAmounts.array(of: TypicalAmount.self).map({ $0.id })
        
        // Get the ID of the FoodItem
        let foodItemID = cdFoodItem.id
        
        // Delete the FoodItem
        FoodItem.delete(cdFoodItem)
        if let deletedFoodItem = FoodItem.getFoodItemByID(id: foodItemID) {
            // The context is not saved yet, therefore the object is still available, but should have isDeleted=true
            #expect(deletedFoodItem.isDeleted == true, "The FoodItem should no longer be found in the DB by its ID.")
        }
        
        // The TypicalAmounts should have been deleted along with the FoodItem (cascade rule)
        for typicalAmountID in typicalAmountIDs {
            if let deletedTypicalAmount = TypicalAmount.getTypicalAmountByID(id: typicalAmountID) {
                // The context is not saved yet, therefore the object is still available, but should have isDeleted=true
                #expect(deletedTypicalAmount.isDeleted == true, "The TypicalAmount should have been deleted along with the FoodItem")
            }
        }
    }
    
    private static func createComposedFoodItemInDB(from composedFoodItemVM: ComposedFoodItemPersistence) throws -> ComposedFoodItem {
        // Get the VM and and save as Core Data ComposedFoodItem
        try #require(composedFoodItemVM.save())
        
        // Check for the ComposedFoodItem and the relatedFoodItem in the DB
        let cdComposedFoodItem = ComposedFoodItem.getComposedFoodItemByID(id: composedFoodItemVM.id)
        try #require(cdComposedFoodItem != nil, "The ComposedFoodItem must be found in the DB by the same ID as the ComposedFoodItemPersistence.")
        #expect(cdComposedFoodItem!.foodItem != nil, "A FoodItem must be associated to the ComposedFoodItem.")
        let cdRelatedFoodItem = FoodItem.getFoodItemByID(id: composedFoodItemVM.id)
        try #require(cdRelatedFoodItem != nil, "The related FoodItem must be found in the DB by the same ID as the ComposedFoodItemPersistence.")
        
        return cdComposedFoodItem!
    }
    
    private static func deleteComposedFoodItemFromDB(_ cdComposedFoodItem: ComposedFoodItem) throws {
        // Get the Ingredients
        let ingredientIDs = (cdComposedFoodItem.ingredients.allObjects as! [Ingredient]).map(\.id)
        
        // Get the ID of the ComposedFoodItem
        let composedFoodItemID = cdComposedFoodItem.id
        
        // Delete the ComposedFoodItem
        ComposedFoodItem.delete(cdComposedFoodItem, includeAssociatedFoodItem: true)
        if let deletedComposedFoodItem = ComposedFoodItem.getComposedFoodItemByID(id: composedFoodItemID) {
            // The context is not saved yet, therefore the object is still available, but should have isDeleted=true
            #expect(deletedComposedFoodItem.isDeleted == true, "The ComposedFoodItem should no longer be found in the DB by its ID.")
        }
        
        // The Ingredients should have been deleted along with the ComposedFoodItem (cascade rule)
        for ingredientID in ingredientIDs {
            if let deletedIngredient = Ingredient.getIngredientByID(id: ingredientID) {
                // The context is not saved yet, therefore the object is still available, but should have isDeleted=true
                #expect(deletedIngredient.isDeleted == true, "The Ingredient should have been deleted along with the ComposedFoodItem")
            }
        }
    }
}
