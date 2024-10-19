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
        
        @Test("ID: 1/2 - Create FoodItem - no FoodItem", arguments: [false, true])
        func createFoodItemDuplicateFalseNoFoodItem(allowDuplicate: Bool) throws {
            // Save a new FoodItem to the DB
            let foodItemVM = DataFactory.shared.tests14FoodItem1
            foodItemVM.save(allowDuplicate: allowDuplicate)
            
            // Check results in DB
            #expect(FoodItem.fetchAll().count == 1)
            
            // Check for identical IDs
            let foodItem = FoodItem.getFoodItemByID(id: foodItemVM.id)
            try #require(foodItem != nil)
            #expect(foodItem!.id == foodItemVM.id)
            assessFoodItemValues(foodItemVM: foodItemVM, foodItem: foodItem!)
            
            // Remove FoodItem from DB
            FoodItem.delete(foodItem!)
            try #require(FoodItem.fetchAll().count == 0)
            
            // Reset DB
            CoreDataTests.resetDB()
        }
        
        @Test("ID: 3 - Create FoodItem - allowDuplicate=false - existing identical FoodItem")
        func createFoodItemDuplicateFalseIdenticalFoodItem() throws {
            // Save a new FoodItem to the DB
            let foodItemVM = DataFactory.shared.tests14FoodItem1
            foodItemVM.save(allowDuplicate: false)
            
            // Check results in DB
            #expect(FoodItem.fetchAll().count == 1)
            
            // Add duplicate with same ID
            let duplicateFoodItemVM = DataFactory.shared.tests14FoodItem1duplicate
            duplicateFoodItemVM.save(allowDuplicate: false)
            
            // Check results in DB - we still expect 1
            let allFoodItems = FoodItem.fetchAll()
            #expect(allFoodItems.count == 1)
            
            // Check for identical IDs
            let foodItem = FoodItem.getFoodItemByName(name: foodItemVM.name)
            try #require(foodItem != nil)
            #expect(foodItem!.id == foodItemVM.id)
            assessFoodItemValues(foodItemVM: foodItemVM, foodItem: foodItem!)
            
            // Remove FoodItem from DB
            FoodItem.deleteAll()
            try #require(FoodItem.fetchAll().count == 0)
            
            // Reset DB
            CoreDataTests.resetDB()
        }
        
        @Test("ID: 4 - Create FoodItem - allowDuplicate=true - existing identical FoodItem")
        func createFoodItemDuplicateTrueIdenticalFoodItem() throws {
            // Save a new FoodItem to the DB
            let foodItemVM = DataFactory.shared.tests14FoodItem1
            foodItemVM.save(allowDuplicate: false)
            
            // Check results in DB
            #expect(FoodItem.fetchAll().count == 1)
            
            // Add duplicate with same ID
            let duplicateFoodItemVM = DataFactory.shared.tests14FoodItem1duplicate
            duplicateFoodItemVM.save(allowDuplicate: true)
            
            // Check results in DB - we expect 2
            #expect(FoodItem.fetchAll().count == 2)
            
            // Check for different IDs
            let foodItems = FoodItem.fetchAll()
            #expect(foodItems[0].id != foodItems[1].id)
            
            // Assess values
            assessFoodItemValues(foodItemVM: foodItemVM, foodItem: foodItems[0])
            assessFoodItemValues(foodItemVM: duplicateFoodItemVM, foodItem: foodItems[1])
            
            // Remove FoodItem from DB
            FoodItem.deleteAll()
            try #require(FoodItem.fetchAll().count == 0)
            
            // Reset DB
            CoreDataTests.resetDB()
        }
        
        @Test("ID: 5 - Create FoodItem from ComposedFoodItemVM - no existing related FoodItem")
        func createFoodItemFromComposedFoodItemVMNoExistingRelatedFoodItem() throws {
            // Get ComposedFoodItemViewModel and create the related FoodItem
            let composedFoodItemVM = DataFactory.shared.tests56CreateComposedFoodItem3()
            let relatedFoodItem = FoodItem.create(from: composedFoodItemVM)
            
            // Check for correct ID
            #expect(relatedFoodItem.id == composedFoodItemVM.id)
            
            // Check for typical amounts, 8 are expected, relating to the relatedFoodItem
            let typicalAmounts = TypicalAmount.fetchAll()
            #expect(typicalAmounts.count == 8)
            for typicalAmount in typicalAmounts {
                #expect(typicalAmount.foodItem == relatedFoodItem)
            }
            
            // Delete FoodItem and (cascading) TypicalAmounts
            FoodItem.delete(relatedFoodItem)
            #expect(FoodItem.fetchAll().count == 0)
            #expect(TypicalAmount.fetchAll().count == 0)
            
            // Reset DB
            CoreDataTests.resetDB()
        }
        
        @Test("ID: 6 - Create FoodItem from ComposedFoodItemVM - existing related FoodItem")
        func createFoodItemFromComposedFoodItemVMExistingRelatedFoodItem() throws {
            // Save related FoodItem
            let relatedFoodItemVM = DataFactory.shared.tests56FoodItemForComposedFoodItem3
            relatedFoodItemVM.save(allowDuplicate: false)
            
            // Check if FoodItem exists with correct ID
            let existingFoodItem = FoodItem.getFoodItemByID(id: relatedFoodItemVM.id)
            try #require(existingFoodItem != nil)
            
            // Get ComposedFoodItemViewModel and create the related FoodItem, which must be the existingFoodItem
            let composedFoodItemVM = DataFactory.shared.tests56CreateComposedFoodItem3()
            let relatedFoodItem = FoodItem.create(from: composedFoodItemVM)
            #expect(relatedFoodItem == existingFoodItem)
            
            // Check for correct ID
            #expect(relatedFoodItem.id == composedFoodItemVM.id)
            
            // Check for typical amounts, 8 are expected, relating to the relatedFoodItem
            let typicalAmounts = TypicalAmount.fetchAll()
            #expect(typicalAmounts.count == 8)
            for typicalAmount in typicalAmounts {
                try #require(typicalAmount.foodItem != nil)
                #expect(typicalAmount.foodItem == relatedFoodItem)
            }
            
            // Delete FoodItem and (cascading) TypicalAmounts
            FoodItem.delete(relatedFoodItem)
            #expect(FoodItem.fetchAll().count == 0)
            #expect(TypicalAmount.fetchAll().count == 0)
            
            // Reset DB
            CoreDataTests.resetDB()
        }
        
        @Test("ID: 7 - Update FoodItem - no associated Ingredients - no TypicalAmounts to be deleted")
        func updateFoodItemNoAssociatedIngredientsNoTypicalAmountsToBeDeleted() throws {
            let foodItemVM = DataFactory.shared.test710FoodItem
            foodItemVM.save(allowDuplicate: false)
            
            // Check results in DB and get the FoodItem
            let allCDFoodItems = FoodItem.fetchAll()
            try #require(allCDFoodItems.count == 1)
            let cdFoodItem = allCDFoodItems.first!
            
            // Modify the foodItemVM
            let nameAppendix = " - Updated"
            foodItemVM.name += nameAppendix
            foodItemVM.caloriesPer100gAsString = String(foodItemVM.caloriesPer100g / 2)
            foodItemVM.carbsPer100gAsString = String(foodItemVM.carbsPer100g / 2)
            foodItemVM.sugarsPer100gAsString = String(foodItemVM.sugarsPer100g / 2)
            
            // Update the cdFoodItem
            FoodItem.update(cdFoodItem, with: foodItemVM, [])
            
            // Check results in DB and get the FoodItem
            let allCDFoodItemsAfterUpdate = FoodItem.fetchAll()
            try #require(allCDFoodItemsAfterUpdate.count == 1)
            let cdFoodItemAfterUpdate = allCDFoodItemsAfterUpdate.first!
            
            // Compare values
            assessFoodItemValues(foodItemVM: foodItemVM, foodItem: cdFoodItemAfterUpdate)
            
            // Delete FoodItem and (cascading) TypicalAmounts
            FoodItem.delete(cdFoodItemAfterUpdate)
            #expect(FoodItem.fetchAll().count == 0)
            #expect(TypicalAmount.fetchAll().count == 0)
            
            // Reset DB
            CoreDataTests.resetDB()
        }
        
        @Test("ID: 8 - Update FoodItem - no associated Ingredients - TypicalAmounts to be deleted")
        func updateFoodItemNoAssociatedIngredientsTypicalAmountsToBeDeleted() throws {
            // Get and save a FoodItem with TypicalAmounts
            let foodItemVM = DataFactory.shared.tests78CreateFoodItemWithTypicalAmounts()
            foodItemVM.save(allowDuplicate: false)
            
            // Check FoodItem results in DB and get the FoodItem
            let allCDFoodItems = FoodItem.fetchAll()
            try #require(allCDFoodItems.count == 1)
            let cdFoodItem = allCDFoodItems.first!
            
            // Check TypicalAmount results in DB
            try #require(TypicalAmount.fetchAll().count == 4)
            
            // Create the FoodItemViewModel from the Core Data FoodItem (including the TypicalAmounts)
            let newFoodItemVM = FoodItemViewModel(from: cdFoodItem)
            
            // Check that we have 4 TypicalAmounts
            try #require(newFoodItemVM.typicalAmounts.count == 4)
            
            // Modify the foodItemVM
            let nameAppendix = " - Updated"
            newFoodItemVM.name += nameAppendix
            newFoodItemVM.caloriesPer100gAsString = String(newFoodItemVM.caloriesPer100g / 2)
            newFoodItemVM.carbsPer100gAsString = String(newFoodItemVM.carbsPer100g / 2)
            newFoodItemVM.sugarsPer100gAsString = String(newFoodItemVM.sugarsPer100g / 2)
            
            // Extract no 2 and no 4
            let sortedTypicalAmounts = newFoodItemVM.typicalAmounts.sorted { $0.amount < $1.amount }
            let typicalAmountsToBeDeleted = [sortedTypicalAmounts[1], sortedTypicalAmounts[3]]
            
            // Update the cdFoodItem and pass the TypicalAmounts to be deleted
            FoodItem.update(cdFoodItem, with: newFoodItemVM, typicalAmountsToBeDeleted)
            
            // Check results in DB and get the FoodItem
            let allCDFoodItemsAfterUpdate = FoodItem.fetchAll()
            try #require(allCDFoodItemsAfterUpdate.count == 1)
            let cdFoodItemAfterUpdate = allCDFoodItemsAfterUpdate.first!
            
            // Compare values
            assessFoodItemValues(foodItemVM: newFoodItemVM, foodItem: cdFoodItemAfterUpdate)
            
            // Check that there are only TypicalAmount 1 and 3 left
            let remainingTypicalAmounts = cdFoodItemAfterUpdate.typicalAmounts
            try #require(remainingTypicalAmounts != nil)
            try #require(remainingTypicalAmounts!.count == 2)
            
            // Check that the values are those of the initial TypicalAmount 1 and 3
            let remainingTypicalAmountsArray = remainingTypicalAmounts!.sorted {
                ($0 as! TypicalAmount).amount < ($1 as! TypicalAmount).amount
            }
            
            assessTypicalAmountValues(typicalAmountVM: DataFactory.shared.test710TypicalAmount1, typicalAmount: remainingTypicalAmountsArray[0] as! TypicalAmount)
            assessTypicalAmountValues(typicalAmountVM: DataFactory.shared.test710TypicalAmount3, typicalAmount: remainingTypicalAmountsArray[1] as! TypicalAmount)
            
            // Delete FoodItem and (cascading) TypicalAmounts
            FoodItem.delete(cdFoodItemAfterUpdate)
            #expect(FoodItem.fetchAll().count == 0)
            #expect(TypicalAmount.fetchAll().count == 0)
            
            // Reset DB
            CoreDataTests.resetDB()
        }
        
        @Test("ID: 9 - Duplicate FoodItem - with TypicalAmounts")
        func duplicateFoodItemWithTypicalAmounts() throws {
            // Get and save a FoodItem with TypicalAmounts
            let foodItemVM = DataFactory.shared.tests78CreateFoodItemWithTypicalAmounts()
            foodItemVM.save(allowDuplicate: false)
            
            // Check FoodItem results in DB and get the FoodItem
            let allCDFoodItems = FoodItem.fetchAll()
            try #require(allCDFoodItems.count == 1)
            let cdFoodItem = allCDFoodItems.first!
            
            // Check TypicalAmount results in DB
            try #require(TypicalAmount.fetchAll().count == 4)
            
            // Duplicate the cdFoodItem
            let duplicatedCDFoodItem = FoodItem.duplicate(cdFoodItem)
            
            // Check duplicated FoodItem results in DB and get the FoodItem
            let allCDFoodItemsAfterDuplication = FoodItem.fetchAll()
            try #require(allCDFoodItemsAfterDuplication.count == 2)
            
            // Check TypicalAmount results in DB - there should be 2x4 now
            try #require(TypicalAmount.fetchAll().count == 8)
            
            // Cross-check sum of all amounts of both FoodItems
            var foodItemTypicalAmountSum = 0
            for typicalAmount in cdFoodItem.typicalAmounts!  {
                foodItemTypicalAmountSum += Int((typicalAmount as! TypicalAmount).amount)
            }
            var duplicatedFoodItemTypicalAmountSum = 0
            for typicalAmount in duplicatedCDFoodItem.typicalAmounts!  {
                duplicatedFoodItemTypicalAmountSum += Int((typicalAmount as! TypicalAmount).amount)
            }
            #expect(foodItemTypicalAmountSum == duplicatedFoodItemTypicalAmountSum)
            
            // Check values
            assessFoodItemValues(foodItem1: cdFoodItem, foodItem2: duplicatedCDFoodItem, sameName: false)
            
            // Delete FoodItems and (cascading) TypicalAmounts
            FoodItem.delete(cdFoodItem)
            #expect(FoodItem.fetchAll().count == 0)
            #expect(TypicalAmount.fetchAll().count == 0)
            
            // Reset DB
            CoreDataTests.resetDB()
        }
        
        @Test("ID: 10 - Add TypicalAmount")
        func addTypicalAmount() throws {
            let foodItemVM = DataFactory.shared.test710FoodItem
            foodItemVM.save(allowDuplicate: false)
            
            // Check FoodItem results in DB and get the FoodItem
            let allCDFoodItems = FoodItem.fetchAll()
            try #require(allCDFoodItems.count == 1)
            let cdFoodItem = allCDFoodItems.first!
            
            // Create (unlinked) typicalAmounts in DB
            let cdTypicalAmount1 = TypicalAmount.create(from: DataFactory.shared.test710TypicalAmount1)
            let cdTypicalAmount2 = TypicalAmount.create(from: DataFactory.shared.test710TypicalAmount2)
            let cdTypicalAmount3 = TypicalAmount.create(from: DataFactory.shared.test710TypicalAmount3)
            let cdTypicalAmount4 = TypicalAmount.create(from: DataFactory.shared.test710TypicalAmount4)
            
            // Add to FoodItem
            FoodItem.add(cdTypicalAmount1, to: cdFoodItem)
            FoodItem.add(cdTypicalAmount2, to: cdFoodItem)
            FoodItem.add(cdTypicalAmount3, to: cdFoodItem)
            FoodItem.add(cdTypicalAmount4, to: cdFoodItem)
            
            // Check DB for TypicalAmounts
            try #require(cdFoodItem.typicalAmounts != nil)
            #expect(cdFoodItem.typicalAmounts!.count == 4)
            #expect(TypicalAmount.fetchAll().count == 4)
            
            // Delete FoodItem and (cascading) TypicalAmounts
            FoodItem.delete(cdFoodItem)
            #expect(FoodItem.fetchAll().count == 0)
            #expect(TypicalAmount.fetchAll().count == 0)
            
            // Reset DB
            CoreDataTests.resetDB()
        }
        
        @Test("ID: 11 - Change category")
        func changeCategory() throws {
            let foodItemVM = DataFactory.shared.test710FoodItem
            foodItemVM.save(allowDuplicate: false)
            
            // Check FoodItem results in DB and get the FoodItem
            let allCDFoodItems = FoodItem.fetchAll()
            try #require(allCDFoodItems.count == 1)
            let cdFoodItem = allCDFoodItems.first!
            
            // Change category to FoodItemCategory.product
            FoodItem.setCategory(cdFoodItem, to: FoodItemCategory.product.rawValue)
            #expect(cdFoodItem.category == FoodItemCategory.product.rawValue)
            
            // Change category to FoodItemCategory.ingredient
            FoodItem.setCategory(cdFoodItem, to: FoodItemCategory.ingredient.rawValue)
            #expect(cdFoodItem.category == FoodItemCategory.ingredient.rawValue)
            
            // Delete FoodItem
            FoodItem.delete(cdFoodItem)
            #expect(FoodItem.fetchAll().count == 0)
            
            // Reset DB
            CoreDataTests.resetDB()
        }
    }
    
    struct ComposedFoodItemBehavior {
        @Test("ID: 12 - Create ComposedFoodItem - import = true")
        func createComposedFoodItemImportTrue() throws {
            // Get the VM and and save as Core Data ComposedFoodItem
            let composedFoodItemVM = DataFactory.shared.tests56CreateComposedFoodItem3() // Pizzateig with 5 Ingredients
            try #require(composedFoodItemVM.save(isImport: true))
            
            // Check and get ComposedFoodItem from DB
            let allCDComposedFoodItems = ComposedFoodItem.fetchAll()
            try #require(allCDComposedFoodItems.count == 1)
            let cdComposedFoodItem = allCDComposedFoodItems.first!
            let cdFoodItem = cdComposedFoodItem.foodItem
            #expect(cdFoodItem != nil)
            
            // Check and get FoodItem from DB (5 for ingredients, 1 for the ComposedFoodItem)
            let allCDFoodItems = FoodItem.fetchAll()
            try #require(allCDFoodItems.count == 6)
            
            // Check for correct reference
            #expect(cdComposedFoodItem.foodItem == cdFoodItem!)
            
            // Check for identical IDs
            #expect(cdComposedFoodItem.id == cdFoodItem!.id)
            
            // Check and get associated Ingredients from DB
            let allIngredients = cdComposedFoodItem.ingredients
            #expect(allIngredients.count == 5)
            for case let ingredient as Ingredient in allIngredients {
                #expect(ingredient.composedFoodItem == cdComposedFoodItem)
                #expect(ingredient.foodItem != nil)
                try assessIngredientValues(ingredient: ingredient)
            }
            
            // Delete ComposedFoodItem (and with it Ingredients)
            ComposedFoodItem.delete(cdComposedFoodItem)
            #expect(ComposedFoodItem.fetchAll().count == 0)
            #expect(Ingredient.fetchAll().count == 0)
            
            // Delete FoodItem - 5 FoodItems for Ingredients should remain
            FoodItem.delete(cdFoodItem!)
            #expect(FoodItem.fetchAll().count == 5)
            
            // Delete the remaining FoodItems
            FoodItem.deleteAll()
            #expect(FoodItem.fetchAll().count == 0)
            
            // Reset DB
            CoreDataTests.resetDB()
        }
        
        @Test("ID: 13 - Create ComposedFoodItem - import = false")
        func createComposedFoodItemImportFalse() throws {
            // Get the VM and and save as Core Data ComposedFoodItem
            let composedFoodItemVM = DataFactory.shared.tests56CreateComposedFoodItem3() // Pizzateig with 5 Ingredients
            
            // Create FoodItems for ingredients
            for foodItemVM in composedFoodItemVM.foodItemVMs {
                // Get existing or new FoodItem
                let relatedFoodItem = FoodItem.create(from: foodItemVM, allowDuplicate: false)
                foodItemVM.cdFoodItem = relatedFoodItem
            }
            
            // Check FoodItems in DB - it should be 5 (the 5 ingredients)
            #expect(FoodItem.fetchAll().count == 5)
            
            // Save the ComposedFoodItem
            try #require(composedFoodItemVM.save(isImport: false))
            
            // Check and get ComposedFoodItem from DB
            let allCDComposedFoodItems = ComposedFoodItem.fetchAll()
            try #require(allCDComposedFoodItems.count == 1)
            let cdComposedFoodItem = allCDComposedFoodItems.first!
            let cdFoodItem = cdComposedFoodItem.foodItem
            #expect(cdFoodItem != nil)
            
            // Check and get FoodItem from DB - now it should be 6, as one for the ComposedFoodItem has been created
            let allCDFoodItems = FoodItem.fetchAll()
            try #require(allCDFoodItems.count == 6)
            
            // Check for correct reference
            #expect(cdComposedFoodItem.foodItem == cdFoodItem!)
            
            // Check for identical IDs
            #expect(cdComposedFoodItem.id == cdFoodItem!.id)
            
            // Check and get associated Ingredients from DB
            let allIngredients = cdComposedFoodItem.ingredients
            #expect(allIngredients.count == 5)
            for case let ingredient as Ingredient in allIngredients {
                #expect(ingredient.composedFoodItem == cdComposedFoodItem)
                #expect(ingredient.foodItem != nil)
                try assessIngredientValues(ingredient: ingredient)
            }
            
            // Delete ComposedFoodItem (and with it Ingredients)
            ComposedFoodItem.delete(cdComposedFoodItem)
            #expect(ComposedFoodItem.fetchAll().count == 0)
            #expect(Ingredient.fetchAll().count == 0)
            
            // Delete FoodItem - 5 FoodItems for Ingredients should remain
            FoodItem.delete(cdFoodItem!)
            #expect(FoodItem.fetchAll().count == 5)
            
            // Delete the remaining FoodItems
            FoodItem.deleteAll()
            #expect(FoodItem.fetchAll().count == 0)
            
            // Reset DB
            CoreDataTests.resetDB()
        }
        
        @Test("ID: 14 - Update ComposedFoodItem - related FoodItem")
        func updateComposedFoodItemRelatedFoodItem() throws {
            // Get the VM and and save as Core Data ComposedFoodItem
            let composedFoodItemVM = DataFactory.shared.tests56CreateComposedFoodItem3() // Pizzateig with 5 Ingredients
            try #require(composedFoodItemVM.save(isImport: true))
            try #require(composedFoodItemVM.foodItemVMs.count == 5)
            
            // Modify the composedFoodItemVM - we remove 2 and add 1 ingredient, so we have 4 in total
            let nameAppendix = " - Updated"
            composedFoodItemVM.name += nameAppendix
            composedFoodItemVM.numberOfPortions = composedFoodItemVM.numberOfPortions * 2
            composedFoodItemVM.remove(foodItem: composedFoodItemVM.foodItemVMs[4])
            composedFoodItemVM.remove(foodItem: composedFoodItemVM.foodItemVMs[0])
            let newIngredient = DataFactory.shared.foodItem3
            newIngredient.cdFoodItem = FoodItem.create(from: newIngredient, allowDuplicate: false)
            newIngredient.amount = 220
            composedFoodItemVM.add(foodItem: newIngredient)
            
            // Run the Core Data update
            #expect(composedFoodItemVM.update())
            
            // Check and get ComposedFoodItem from DB
            let allCDComposedFoodItems = ComposedFoodItem.fetchAll()
            try #require(allCDComposedFoodItems.count == 1)
            let cdComposedFoodItem = allCDComposedFoodItems.first!
            let cdFoodItem = cdComposedFoodItem.foodItem
            #expect(cdFoodItem != nil)
            
            // Check and get FoodItem from DB - 6 for the ingredients (5 initial ones plus one new one),
            // 1 for the ComposedFoodItem, so 7 in total
            let allCDFoodItems = FoodItem.fetchAll()
            try #require(allCDFoodItems.count == 7)
            
            // Check for correct reference
            #expect(cdComposedFoodItem.foodItem == cdFoodItem!)
            
            // Check for identical IDs
            #expect(cdComposedFoodItem.id == cdFoodItem!.id)
            
            // Check and get associated Ingredients from DB
            let allIngredients = cdComposedFoodItem.ingredients
            #expect(allIngredients.count == 4)
            for case let ingredient as Ingredient in allIngredients {
                #expect(ingredient.composedFoodItem == cdComposedFoodItem)
                #expect(ingredient.foodItem != nil)
                try CoreDataTests.assessIngredientValues(ingredient: ingredient)
            }
            
            // Delete ComposedFoodItem (and with it Ingredients)
            ComposedFoodItem.delete(cdComposedFoodItem)
            #expect(ComposedFoodItem.fetchAll().count == 0)
            #expect(Ingredient.fetchAll().count == 0)
            
            // Delete FoodItem - 6 FoodItems for Ingredients should remain
            FoodItem.delete(cdFoodItem!)
            #expect(FoodItem.fetchAll().count == 6)
            
            // Delete the remaining FoodItems
            FoodItem.deleteAll()
            #expect(FoodItem.fetchAll().count == 0)
            
            // Reset DB
            CoreDataTests.resetDB()
        }
    }
    
    
        
    /*
    @Test("ID: 8 - Update FoodItem - associated Ingredients - no TypicalAmounts to be deleted")
    func updateFoodItemAssociatedIngredientsNoTypicalAmountsToBeDeleted() throws {
    }*/
        
        
    private static func assessFoodItemValues(foodItemVM: FoodItemViewModel, foodItem: FoodItem) {
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
    
    private static func assessIngredientValues(ingredient: Ingredient) throws {
        try #require(ingredient.foodItem != nil)
        #expect(ingredient.id == ingredient.foodItem!.id)
        #expect(ingredient.name == ingredient.foodItem!.name)
        #expect(ingredient.favorite == ingredient.foodItem!.favorite)
        #expect(ingredient.caloriesPer100g == ingredient.foodItem!.caloriesPer100g)
        #expect(ingredient.carbsPer100g == ingredient.foodItem!.carbsPer100g)
        #expect(ingredient.sugarsPer100g == ingredient.foodItem!.sugarsPer100g)
    }
    
    private static func assessTypicalAmountValues(typicalAmountVM: TypicalAmountViewModel, typicalAmount: TypicalAmount) {
        #expect(typicalAmount.amount == typicalAmountVM.amount)
        #expect(typicalAmount.comment == typicalAmountVM.comment)
    }
    
    private static func resetDB() {
        FoodItem.deleteAll()
        ComposedFoodItem.deleteAll()
        Ingredient.deleteAll()
        TypicalAmount.deleteAll()
    }
}
