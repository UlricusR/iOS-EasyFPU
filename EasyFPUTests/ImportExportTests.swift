//
//  ImportExportTests.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 27/10/2024.
//  Copyright © 2024 Ulrich Rüth. All rights reserved.
//

import Foundation
import Testing
@testable import EasyFPU

@Suite("Import/Export Tests")
class ImportExportTests {
    private static let dataModelVersion1FileName = "EasyFPU_FoodList_DataModel1"
    private static let dataModelVersion2FileName = "EasyFPU_FoodList_DataModel2"
    
    @Test("ID: 1 - Import data model version 2")
    func importDataModelVersion2() throws {
        // Get the file URL
        let version2Url = Bundle(for: ImportExportTests.self).url(forResource: ImportExportTests.dataModelVersion2FileName, withExtension: "json")
        try #require(version2Url != nil)
        
        // Prepare arrays to store imported FoodItemViewModels and ComposedFoodItemViewModels
        var foodItemVMsToBeImported: [FoodItemViewModel]? = [FoodItemViewModel]()
        var composedFoodItemVMsToBeImported: [ComposedFoodItemViewModel]? = [ComposedFoodItemViewModel]()
        var errorMessage = ""
        
        // Import
        try #require(DataHelper.importFoodItems(version2Url!, foodItemVMsToBeImported: &foodItemVMsToBeImported, composedFoodItemVMsToBeImported: &composedFoodItemVMsToBeImported, errorMessage: &errorMessage))
        #expect(errorMessage.isEmpty, "There should be no error message")
        try #require(foodItemVMsToBeImported != nil && composedFoodItemVMsToBeImported != nil, "Both FoodItemVM and ComposedFoodItemVM arrays should not be nil")
        
        // Check number of ComposedFoodItemVMs and FoodItemVMs
        #expect(composedFoodItemVMsToBeImported!.count == 1, "The number of ComposedFoodItemVMs should be 1.")
        #expect(foodItemVMsToBeImported!.count == 60, "The number of FoodItemVMs should be 60.")
    }
}
