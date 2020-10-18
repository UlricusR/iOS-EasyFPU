//
//  OpenFoodFacts.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 17.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class OpenFoodFacts: ObservableObject, FoodDatabase {
    @Published var foodDatabaseEntry: FoodDatabaseEntry?
    private var countrycode: String
    private let languagecode = "en"
    private let userAgent = "EasyFPU - iOS - Version \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)"
    private var productFields: [String] {
        var fields = [String]()
        for field in OpenFoodFactsProduct.CodingKeys.allCases {
            fields.append(field.rawValue)
        }
        return fields
    }
    
    enum CountryCodes: String {
        case world = "world"
        case de = "de"
        case us = "us"
    }
    
    init(countrycode: CountryCodes) {
        self.countrycode = countrycode.rawValue
    }
    
    func search(for name: String) -> [String] {
        let matchingEntries = [String]()
        return matchingEntries
    }
    
    func get(_ id: String) {
        let urlString = "https://\(countrycode)-\(languagecode).openfoodfacts.org/api/v0/product/\(id).json?fields=\(productFields.joined(separator: ","))"
        let session = URLSession.shared
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                do {
                    let openFoodFactsObject = try JSONDecoder().decode(OpenFoodFactsObject.self, from: data)
                    self.foodDatabaseEntry = try openFoodFactsObject.fill(foodDatabase: self, id: id)
                    self.objectWillChange.send()
                } catch {
                    print(error)
                }
            }
        }).resume()
    }
}

struct OpenFoodFactsObject: Decodable, FoodDatabaseObject {
    var code: String?
    var status: Int?
    var product: OpenFoodFactsProduct?
    var statusVerbose: String?
    
    enum CodingKeys: String, CodingKey {
        case code
        case status
        case product
        case statusVerbose = "status_verbose"
    }
    
    func fill(foodDatabase: FoodDatabase, id: String) throws -> FoodDatabaseEntry {
        // First address the mandatory values
        guard let product = self.product else {
            throw FoodDatabaseError.incompleteData(NSLocalizedString("No product found", comment: ""))
        }
        
        guard let productName = product.productName else {
            throw FoodDatabaseError.incompleteData(NSLocalizedString("Entry has no name", comment: ""))
        }
        
        let caloriesPer100g = try product.getNutrimentsDoubleValue(key: OpenFoodFactsProduct.NutrimentsKey.caloriesPer100g)
        let carbsPer100g = try product.getNutrimentsDoubleValue(key: OpenFoodFactsProduct.NutrimentsKey.carbsPer100g)
        
        var foodDatabaseEntry = FoodDatabaseEntry(
            productName: productName,
            caloriesPer100g: caloriesPer100g,
            carbsPer100g: carbsPer100g,
            source: foodDatabase,
            sourceId: id
        )
        
        // Append optional values if available
        if let sugarsPer100g = try? product.getNutrimentsDoubleValue(key: OpenFoodFactsProduct.NutrimentsKey.sugarsPer100g) {
            foodDatabaseEntry.sugarsPer100g = sugarsPer100g
        }
        
        if product.genericName != nil {
            foodDatabaseEntry.genericName = product.genericName!
        }
        
        if product.brands != nil {
            foodDatabaseEntry.brand = product.brands!
        }
        
        // Return the resulting entry
        return foodDatabaseEntry
    }
}

struct OpenFoodFactsProduct: Decodable {
    var productName: String?
    var brands: String?
    var genericName: String?
    var nutriments: Nutriments?
    var netWeightValue: Double?
    var netWeightUnit: String?
    var servingQuanity: Double?
    var imageThumbUrl: String?
    var imageFrontSmallUrl: String?
    var imageFrontUrl: String?
    var imageNutritionThumbUrl: String?
    var imageNutritionSmallUrl: String?
    var imageNutritionUrl: String?
    var imageIngredientsThumbUrl: String?
    var imageSmallUrl: String?
    var lastModifiedInSecondsSince01Jan1970: Int? // UNIX timestamp format: Seconds since Jan 1st 1970
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case productName = "product_name"
        case brands = "brands"
        case genericName = "generic_name"
        case nutriments = "nutriments"
        case netWeightValue = "net_weight_value"
        case netWeightUnit = "net_weight_unit"
        case servingQuanity = "serving_quantity"
        case imageThumbUrl = "image_thumb_url"
        case imageFrontSmallUrl = "image_front_small_url"
        case imageFrontUrl = "image_front_url"
        case imageNutritionThumbUrl = "image_nutrition_thumb_url"
        case imageNutritionSmallUrl = "image_nutrition_small_url"
        case imageNutritionUrl = "image_nutrition_url"
        case imageIngredientsThumbUrl = "image_ingredients_thumb_url"
        case imageSmallUrl = "image_small_url"
        case lastModifiedInSecondsSince01Jan1970 = "last_modified_t"
    }
    
    enum DecodingError: Error {
        case corruptedData
    }
    
    enum ValueType: Decodable {
        case number(Double)
        case string(String)
        
        init(from decoder: Decoder) throws {
            // Try to decode as Double
            do {
                let singleValueContainer = try decoder.singleValueContainer()
                let number = try singleValueContainer.decode(Double.self)
                self = .number(number)
                return
            } catch {
                print(error)
            }
            
            // Try to decode as String
            do {
                let singleValueContainer = try decoder.singleValueContainer()
                let string = try singleValueContainer.decode(String.self)
                self = .string(string)
                return
            } catch {
                print(error)
            }
            
            throw DecodingError.corruptedData
        }
    }
    
    enum NutrimentsKey: String {
        case caloriesPer100g = "energy-kcal_100g"
        case carbsPer100g = "carbohydrates_100g"
        case sugarsPer100g = "sugars_100g"
    }
    
    func getNutrimentsDoubleValue(key: NutrimentsKey) throws -> Double {
        guard let value = nutriments?[key.rawValue] else {
            throw FoodDatabaseError.typeError("Key not found: \(key.rawValue)")
        }
        
        switch value {
        case .number(let number):
            return number
        default:
            throw FoodDatabaseError.typeError("Wrong data type for key \(key.rawValue): Expected Double")
        }
    }
    
    func getNutrimentsStringValue(key: NutrimentsKey) throws -> String {
        guard let nutriments = nutriments else {
            throw FoodDatabaseError.incompleteData(NSLocalizedString("No nutriments found", comment: ""))
        }
        
        guard let value = nutriments[key.rawValue] else {
            throw FoodDatabaseError.typeError("Key not found: \(key.rawValue)")
        }
        
        switch value {
        case .string(let string):
            return string
        default:
            throw FoodDatabaseError.typeError("Wrong data type for key \(key.rawValue): Expected String")
        }
    }
    
    typealias Nutriments = [String: ValueType]
}
