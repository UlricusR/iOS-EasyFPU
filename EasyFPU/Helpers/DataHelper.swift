//
//  DataHelper.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 04.08.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices
import SwiftUI
import UniformTypeIdentifiers

/// Publishes the main bundle internally - required to access the data model for unit testing
internal enum DataModel {
    internal static let bundle = Bundle.main
}

enum InvalidNumberError: Error {
    case inputError(String)
    
    func evaluate() -> String {
        switch self {
        case .inputError(let storedErrorMessage):
            return (NSLocalizedString("Input error: ", comment: "") + storedErrorMessage)
        }
    }
}

enum ImportExportError: Error {
    case wrongFileExtension
    case noFileAccess
}

struct ImportData: Identifiable {
    var id = UUID()
    let foodItemVMsToBeImported: [FoodItemPersistence]?
    let composedFoodItemVMsToBeImported: [ComposedFoodItemPersistence]?
    
    /// Returns the number of FoodItemViewModels and ComposedFoodItemViewModels.
    /// - Returns: The number of FoodItemViewModels and ComposedFoodItemViewModels (in this order).
    func countItems() -> (Int, Int) {
        (
            foodItemVMsToBeImported == nil ? 0 : foodItemVMsToBeImported!.count,
            composedFoodItemVMsToBeImported == nil ? 0 : composedFoodItemVMsToBeImported!.count
        )
    }
    
    func save() {
        if let foodItemVMs = foodItemVMsToBeImported {
            for foodItemVM in foodItemVMs {
                foodItemVM.save()
            }
        }
        
        if let composedFoodItemVMs = composedFoodItemVMsToBeImported {
            for composedFoodItemVM in composedFoodItemVMs {
                _ = composedFoodItemVM.save()
            }
        }
    }
}

struct DataHelper {
    
    // MARK: - Reading the default absorption block JSON
    
    static func loadDefaultAbsorptionBlocks(errorMessage: inout String) -> [AbsorptionBlockFromJson]? {
        // Load default absorption scheme
        let absorptionSchemeDefaultFile = "absorptionscheme_default.json"
        guard let file = Bundle.main.url(forResource: absorptionSchemeDefaultFile, withExtension: nil) else {
            errorMessage = "Unable to load \(absorptionSchemeDefaultFile)"
            return nil
        }
        do {
            let data = try Data(contentsOf: file)
            return DataHelper.decode(json: data, strategy: .convertFromSnakeCase, errorMessage: &errorMessage) as [AbsorptionBlockFromJson]?
        } catch {
            errorMessage = ("Could not decode data of \(absorptionSchemeDefaultFile):\n\(error.localizedDescription)")
            return nil
        }
    }
    
    static private func decode<T: Decodable>(json data: Data, strategy: JSONDecoder.KeyDecodingStrategy, errorMessage: inout String) -> T? {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = strategy
            return try decoder.decode(T.self, from: data)
        } catch {
            errorMessage = "Couldn't parse data as \(T.self):\n\(error.localizedDescription)"
            return nil
        }
    }
    
    // MARK: - Importing and exporting food items as JSON
    
    /// Stores all FoodItems and ComposedFoodItems in an array.
    /// - Returns: A two-dimensional array with FoodItemViewModels and ComposedFoodItemViewModels (in that order).
    static func getAllFoodData() -> [[Any]] {
        // Get Core Data FoodItems and load them into FoodItemViewModels
        let cdFoodItems = FoodItem.fetchAll()
        var foodItems = [FoodItemPersistence]()
        for cdFoodItem in cdFoodItems {
            foodItems.append(FoodItemPersistence(from: cdFoodItem))
        }
        
        // Get Core Data ComposedFoodItems and load them into ComposedFoodItemViewModels
        let cdComposedFoodItems = ComposedFoodItem.fetchAll()
        var composedFoodItems = [ComposedFoodItemPersistence]()
        for cdComposedFoodItem in cdComposedFoodItems {
            composedFoodItems.append(ComposedFoodItemPersistence(from: cdComposedFoodItem))
        }
        
        return [foodItems, composedFoodItems]
    }
    
    static func importFoodData(
        _ file: URL,
        errorMessage: inout String
    ) -> ImportData? {
        debugPrint("Trying to import following file: \(file)")
        
        // Make sure we can access file
        guard file.startAccessingSecurityScopedResource() else {
            debugPrint("Failed to access \(file)")
            errorMessage = "Failed to access \(file)"
            return nil
        }
        defer { file.stopAccessingSecurityScopedResource() }
        
        // Read data
        var jsonData: Data
        do {
            jsonData = try Data(contentsOf: file)
        } catch {
            debugPrint(error.localizedDescription)
            errorMessage = error.localizedDescription
            return nil
        }
        
        // Decode JSON
        return decodeFoodData(jsonData: jsonData, errorMessage: &errorMessage)
    }
    
    static func decodeFoodData(jsonData: Data, errorMessage: inout String) -> ImportData? {
        // Decode JSON
        let decoder = JSONDecoder()
        
        // JSON model has changed, so we must determine data model version first
        var dataModelVersion: DataModelVersion
        var dataVersionFinder: DataVersionFinder
        do {
            dataVersionFinder = try decoder.decode(DataVersionFinder.self, from: jsonData)
            dataModelVersion = dataVersionFinder.dataModelVersion
        } catch DataVersionFinder.DataModelError.invalidDataModelVersion(let message) {
            errorMessage = message
            return nil
        } catch {
            errorMessage = NSLocalizedString("Failed to decode - ", comment: "") + error.localizedDescription
            return nil
        }
        
        do {
            var importData: ImportData
            switch dataModelVersion {
            case .version1:
                let foodItemVMsToBeImported = try decoder.decode([FoodItemPersistence].self, from: jsonData)
                importData = ImportData(foodItemVMsToBeImported: foodItemVMsToBeImported, composedFoodItemVMsToBeImported: nil)
            case .version2:
                let wrappedData = try decoder.decode(DataWrapper.self, from: jsonData)
                importData = ImportData(foodItemVMsToBeImported: wrappedData.foodItemVMs, composedFoodItemVMsToBeImported: wrappedData.composedFoodItemVMs)
            }
            // All has gone fine, we return true
            return importData
        } catch DecodingError.keyNotFound(let key, let context) {
            errorMessage = NSLocalizedString("Failed to decode due to missing key ", comment: "") + key.stringValue + " - " + context.debugDescription
            return nil
        } catch DecodingError.typeMismatch(_, let context) {
            errorMessage = NSLocalizedString("Failed to decode due to type mismatch - ", comment: "") + context.debugDescription
            return nil
        } catch DecodingError.valueNotFound(let type, let context) {
            errorMessage = NSLocalizedString("Failed to decode due to missing value - ", comment: "") + "\(type)" + " - " + context.debugDescription
            return nil
        } catch DecodingError.dataCorrupted(_) {
            errorMessage = NSLocalizedString("Failed to decode because it appears to be invalid JSON", comment: "")
            return nil
        } catch {
            errorMessage = NSLocalizedString("Failed to decode - ", comment: "") + error.localizedDescription
            return nil
        }
    }
    
    /// Deletes all Core Data ComposedFoodItems (and with them Ingredients)
    /// and FoodItems (and with them TypicalAmounts)
    static func deleteAllFood() {
        ComposedFoodItem.deleteAll()
        FoodItem.deleteAll()
    }
    
    /// Checks if either FoodItems or ComposedFoodItems exist in the database.
    /// - Returns: True if either of them exist.
    static func hasData() -> Bool {
        !ComposedFoodItem.fetchAll().isEmpty || !FoodItem.fetchAll().isEmpty
    }
    
    // MARK: - Data checker and formatter
    
    static func doubleFormatter(numberOfDigits: Int) -> NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = numberOfDigits
        return numberFormatter
    }
    
    static var intFormatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale.current
        return numberFormatter
    }
    
    static func checkForPositiveDouble(valueAsString: String, allowZero: Bool) -> Result<Double, InvalidNumberError> {
        guard let valueAsNumber = DataHelper.doubleFormatter(numberOfDigits: 5).number(from: valueAsString.isEmpty ? "0" : valueAsString) else {
            return .failure(.inputError(NSLocalizedString("Value not a number", comment: "")))
        }
        guard allowZero ? valueAsNumber.doubleValue >= 0.0 : valueAsNumber.doubleValue > 0.0 else {
            return .failure(.inputError(NSLocalizedString(allowZero ? "Value must not be negative" : "Value must not be zero or negative", comment: "")))
        }
        return .success(valueAsNumber.doubleValue)
    }
    
    static func checkForPositiveInt(valueAsString: String, allowZero: Bool) -> Result<Int, InvalidNumberError> {
        // First remove group separator
        let groupingSeparator = intFormatter.groupingSeparator!
        var valueWithoutGroupingSeparator = valueAsString
        valueWithoutGroupingSeparator.removeAll(where: { $0 == Character(groupingSeparator) })
        
        guard let valueAsNumber = intFormatter.number(from: valueWithoutGroupingSeparator.isEmpty ? "0" : valueWithoutGroupingSeparator) else {
            return .failure(.inputError(NSLocalizedString("Value not a number", comment: "")))
        }
        guard allowZero ? valueAsNumber.intValue >= 0 : valueAsNumber.intValue > 0 else {
            return .failure(.inputError(NSLocalizedString(allowZero ? "Value must not be negative" : "Value must not be zero or negative", comment: "")))
        }
        return .success(valueAsNumber.intValue)
    }
    
    static func gcd(_ numbers: [Int]) -> Int {
        var result = 0
        for element in numbers {
            result = gcd(result, element)
            if result == 1 { return 1 }
        }
        
        return result
    }
    
    static func gcd(_ a: Int, _ b: Int) -> Int {
        if a == 0 { return b }
        return gcd(b % a, a)
    }
}
