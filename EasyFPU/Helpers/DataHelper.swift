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

enum InvalidNumberError: Error {
    case inputError(String)
}

class DataHelper {
    
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
    
    // MARK: - Exporting food items as JSON
    
    static func exportFoodItems(_ dir: URL, fileName: inout String) -> Bool {
        let cdFoodItems = FoodItem.fetchAll()
        var foodItems = [FoodItemViewModel]()
        for cdFoodItem in cdFoodItems {
            foodItems.append(FoodItemViewModel(from: cdFoodItem))
        }
        fileName = "\(UUID().uuidString).json"
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let contents = try encoder.encode(foodItems)
            let fileURL = dir.appendingPathComponent(fileName)
            try contents.write(to: fileURL)
            return true
        } catch {
            debugPrint(error)
            return false
        }
    }
    
    // MARK: - Data checker and formatter
    
    static func doubleFormatter(numberOfDigits: Int) -> NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = numberOfDigits
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
        guard let valueAsNumber = NumberFormatter().number(from: valueAsString.isEmpty ? "0" : valueAsString) else {
            return .failure(.inputError(NSLocalizedString("Value not a number", comment: "")))
        }
        guard allowZero ? valueAsNumber.intValue >= 0 : valueAsNumber.intValue > 0 else {
            return .failure(.inputError(NSLocalizedString(allowZero ? "Value must not be negative" : "Value must not be zero or negative", comment: "")))
        }
        return .success(valueAsNumber.intValue)
    }
    
    static func getErrorMessage(from error: InvalidNumberError) -> String {
        switch error {
        case .inputError(let errorMessage):
            return errorMessage
        }
    }
    
    static func gcdRecursiveEuklid(_ m: Int, _ n: Int) -> Int {
        let r: Int = m % n
        if r != 0 {
            return gcdRecursiveEuklid(n, r)
        } else {
            return n
        }
    }
}
