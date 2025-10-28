//
//  ImportExportTests.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 27/10/2024.
//  Copyright © 2024 Ulrich Rüth. All rights reserved.
//

import Foundation
import Testing
import SwiftyJSON
@testable import EasyFPU

@Suite("Import/Export Tests")
class ImportExportTests {
    private static let dataModelVersion1FileName = "EasyFPU_FoodList_DataModel1"
    private static let dataModelVersion2FileName = "EasyFPU_FoodList_DataModel2"
    
    @Test("ID: 1 - Import", arguments: zip(
        [ImportExportTests.dataModelVersion1FileName, ImportExportTests.dataModelVersion2FileName],
        [(41, 0), (60, 1)]
    ))
    func importData(dataModelFileName: String, numberOfItems: (Int, Int)) throws {
        // Get the file URL
        let fileUrl = Bundle(for: ImportExportTests.self).url(forResource: dataModelFileName, withExtension: "json")
        try #require(fileUrl != nil)
        
        // Prepare arrays to store imported FoodItemPersistences and ComposedFoodItemPersistences
        var errorMessage = ""
        
        // Import
        let importData = DataHelper.importFoodData(fileUrl!, errorMessage: &errorMessage)
        try #require(importData != nil, "Import data should not be nil")
        #expect(errorMessage.isEmpty, "There should be no error message")
        
        // Check number of ComposedFoodItemVMs and FoodItemVMs
        #expect(importData!.foodItemVMsToBeImported?.count == numberOfItems.0, "The number of FoodItemVMs should be \(numberOfItems.0).")
        if numberOfItems.1 == 0 {
            #expect(importData!.composedFoodItemVMsToBeImported == nil || importData!.composedFoodItemVMsToBeImported!.isEmpty, "ComposedFoodItemVM array should be nil or empty.")
        } else {
            #expect(importData!.composedFoodItemVMsToBeImported!.count == numberOfItems.1, "The number of ComposedFoodItemVMs should be \(numberOfItems.1).")
        }
    }

    @Test("ID: 2 - Export data")
    func exportData() throws {
        // Get ComposedFoodItem and save
        let composedFoodItemVM = try DataFactory.shared.createComposedFoodItemPersistence()
        let composedFoodItemVMs = [composedFoodItemVM]
        
        // Get FoodItems and save
        let foodItemVM = try DataFactory.shared.createFoodItemPersistence()
        try DataFactory.shared.addTypicalAmounts(to: foodItemVM)
        
        // Collect all FoodItems
        var foodItemVMs: [FoodItemPersistence] = [foodItemVM]
        foodItemVMs.append(contentsOf: composedFoodItemVM.ingredients)
        
        // Prepare the DataWrapper
        let dataWrapper = DataWrapper(dataModelVersion: .version2, foodItemVMs: foodItemVMs, composedFoodItemVMs: composedFoodItemVMs)
        
        // Create json contents
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let contents = try encoder.encode(dataWrapper)

        // Create the JSON object
        let json = JSON(contents)
        
        // Check correct data model version
        #expect(json["dataModelVersion"].string == DataModelVersion.version2.rawValue, "The model version is not correct.")
        
        // Get the FoodItems
        let allFoodItems = json["foodItems"].arrayValue
        let foodItemIDs = allFoodItems.map { $0["foodItem"]["id"].stringValue }
        
        // Iterate through FoodItems and check them in the JSON
        for foodItemVM in foodItemVMs {
            try ImportExportTests.checkFoodItem(foodItemVM: foodItemVM, foodItemIDs: foodItemIDs, allFoodItems: allFoodItems)
        }
        
        // Get the ComposedFoodItems
        let allComposedFoodItems = json["recipes"].arrayValue
        let composedFoodItemIDs = allComposedFoodItems.map { $0["composedFoodItem"]["id"].stringValue }
        
        // Iterate through ComposedFoodItems and check them in the JSON
        for composedFoodItemVM in composedFoodItemVMs {
            // Try to find the elements in JSON
            let index = composedFoodItemIDs.firstIndex(of: composedFoodItemVM.id.uuidString)
            try #require(index != nil, "The ComposedFoodItem ID could not be found.")
            
            // Compare values
            #expect(allComposedFoodItems[index!]["composedFoodItem"]["amount"].intValue == composedFoodItemVM.amount)
            #expect(allComposedFoodItems[index!]["composedFoodItem"]["name"].stringValue == composedFoodItemVM.name)
            #expect(allComposedFoodItems[index!]["composedFoodItem"]["favorite"].boolValue == composedFoodItemVM.favorite)
            #expect(allComposedFoodItems[index!]["composedFoodItem"]["numberOfPortions"].intValue == composedFoodItemVM.numberOfPortions)
            
            // Get ingredients
            let composedFoodItemIngredients = allComposedFoodItems[index!]["composedFoodItem"]["ingredients"].arrayValue
            let ingredientIDs = composedFoodItemIngredients.map { $0["foodItem"]["id"].stringValue }
            
            // Iterate through ingredients and check them in the JSON
            for ingredient in composedFoodItemVM.ingredients {
                try ImportExportTests.checkFoodItem(foodItemVM: ingredient, foodItemIDs: ingredientIDs, allFoodItems: composedFoodItemIngredients)
                
                // The ingredient ID needs to match a FoodItem ID
                #expect(foodItemIDs.firstIndex(of: ingredient.id.uuidString) != nil, "The ingredient needs to have a corresponding FoodItem.")
            }
        }
    }
    
    private static func checkFoodItem(foodItemVM: FoodItemPersistence, foodItemIDs: [String], allFoodItems: [JSON]) throws {
        // Try to find the elements in JSON
        let index = foodItemIDs.firstIndex(of: foodItemVM.id.uuidString)
        try #require(index != nil, "The FoodItem ID could not be found.")
        
        // Compare values
        #expect(allFoodItems[index!]["foodItem"]["amount"].intValue == foodItemVM.amount)
        #expect(allFoodItems[index!]["foodItem"]["name"].stringValue == foodItemVM.name)
        #expect(allFoodItems[index!]["foodItem"]["category"].stringValue == foodItemVM.category.rawValue)
        #expect(allFoodItems[index!]["foodItem"]["favorite"].boolValue == foodItemVM.favorite)
        #expect(allFoodItems[index!]["foodItem"]["caloriesPer100g"].doubleValue == foodItemVM.caloriesPer100g)
        #expect(allFoodItems[index!]["foodItem"]["carbsPer100g"].doubleValue == foodItemVM.carbsPer100g)
        #expect(allFoodItems[index!]["foodItem"]["sugarsPer100g"].doubleValue == foodItemVM.sugarsPer100g)
        
        // Get the TypicalAmounts
        let allTypicalAmounts = allFoodItems[index!]["foodItem"]["typicalAmounts"].arrayValue
        #expect(allTypicalAmounts.count == foodItemVM.typicalAmounts.count, "The number of TypicalAmounts does not match.")
        let allTypicalAmountAmounts = allTypicalAmounts.map { $0["amount"].intValue }
        let allTypicalAmountComments = allTypicalAmounts.map { $0["comment"].stringValue }
        
        // Iterate through TypicalAmounts
        for typicalAmount in foodItemVM.typicalAmounts {
            let amountIndex = allTypicalAmountAmounts.firstIndex(of: typicalAmount.amount)
            try #require(amountIndex != nil)
            let commentIndex = allTypicalAmountComments.firstIndex(of: typicalAmount.comment)
            try #require(commentIndex != nil)
            #expect(amountIndex == commentIndex, "The amount and the related comment do not match.")
        }
    }
}
