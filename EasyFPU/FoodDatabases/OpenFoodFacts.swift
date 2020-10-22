//
//  OpenFoodFacts.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 17.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class OpenFoodFacts: FoodDatabase {
    var databaseType = FoodDatabaseType.openFoodFacts
    private var countrycode: CountryCode {
        if let countryCodeString = UserSettings.shared.countryCode {
            if let countryCode = CountryCode.init(rawValue: countryCodeString) {
                return countryCode
            }
        }
        
        if let countryCodeString = Locale.current.regionCode?.lowercased() {
            if let countryCode = CountryCode.init(rawValue: countryCodeString) {
                return countryCode
            }
        }
        
        return CountryCode.world
    }
    //private let languagecode = "en"
    private let userAgent = "EasyFPU - iOS - Version \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)"
    private var productFields: [String] {
        var fields = [String]()
        for field in OpenFoodFactsProduct.CodingKeys.allCases {
            fields.append(field.rawValue)
        }
        return fields
    }
    
    enum CountryCode: String, CaseIterable {
        case world = "world"
        case de = "de"
        case us = "us"
    }
    
    func search(for term: String, foodDatabaseResults: FoodDatabaseResults) {
        guard let urlSearchTerm = term.trimmingCharacters(in: .whitespacesAndNewlines).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            foodDatabaseResults.errorMessage = NSLocalizedString("Unable to convert your search string into a valid URL", comment: "")
            return
        }
        //let urlString = "https://\(countrycode.rawValue)-\(languagecode).openfoodfacts.org/cgi/search.pl?action=process&search_terms=\(urlSearchTerm)&sort_by=unique_scans_n&json=true" // Version with language code
        let urlString = "https://\(countrycode.rawValue).openfoodfacts.org/cgi/search.pl?action=process&search_terms=\(urlSearchTerm)&sort_by=unique_scans_n&json=true" // Version without language code
        let request = prepareRequest(urlString)
        
        let session = URLSession.shared
        session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
            guard error == nil else {
                debugPrint(error!.localizedDescription)
                foodDatabaseResults.errorMessage = error!.localizedDescription
                return
            }
            
            if let data = data {
                do {
                    let openFoodFactsSearchResult = try JSONDecoder().decode(OpenFoodFactsSearchResult.self, from: data)
                    guard let products = openFoodFactsSearchResult.products else {
                        throw FoodDatabaseError.noSearchResults
                    }
                    
                    DispatchQueue.main.async {
                        foodDatabaseResults.searchResults = [FoodDatabaseEntry]()
                        for product in products {
                            if let foodDatabaseEntry = FoodDatabaseEntry(from: product) {
                                foodDatabaseResults.searchResults!.append(foodDatabaseEntry)
                            }
                        }
                    }
                } catch {
                    debugPrint(error.localizedDescription)
                    DispatchQueue.main.async {
                        foodDatabaseResults.errorMessage = error.localizedDescription
                    }
                }
            }
        }).resume()
    }
    
    func prepare(_ id: String, foodDatabaseResults: FoodDatabaseResults) {
        //let urlString = "https://\(countrycode.rawValue)-\(languagecode).openfoodfacts.org/api/v0/product/\(id).json?fields=\(productFields.joined(separator: ","))" // Version with language code
        let urlString = "https://\(countrycode.rawValue).openfoodfacts.org/api/v0/product/\(id).json?fields=\(productFields.joined(separator: ","))" // Version without language code
        let request = prepareRequest(urlString)
        
        let session = URLSession.shared
        session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                do {
                    let openFoodFactsObject = try JSONDecoder().decode(OpenFoodFactsObject.self, from: data)
                    
                    // Check if there's a product
                    guard let product = openFoodFactsObject.product else {
                        throw FoodDatabaseError.incompleteData(NSLocalizedString("No product found", comment: ""))
                    }
                    
                    // Fill the FoodDatabaseEntry
                    DispatchQueue.main.async {
                        do {
                            guard let foodDatabaseEntry = FoodDatabaseEntry(from: product) else {
                                throw FoodDatabaseError.incompleteData(NSLocalizedString("No food found", comment: ""))
                            }
                            foodDatabaseResults.selectedEntry = foodDatabaseEntry
                        } catch FoodDatabaseError.incompleteData(let errorMessage) {
                            foodDatabaseResults.errorMessage = errorMessage
                        } catch {
                            foodDatabaseResults.errorMessage = error.localizedDescription
                        }
                    }
                } catch {
                    debugPrint(error.localizedDescription)
                    DispatchQueue.main.async {
                        foodDatabaseResults.errorMessage = error.localizedDescription
                    }
                }
            }
        }).resume()
    }
    
    private func prepareRequest(_ urlString: String) -> URLRequest {
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        return request
    }
}

struct OpenFoodFactsObject: Decodable {
    var product: OpenFoodFactsProduct?
    
    enum CodingKeys: String, CodingKey {
        case product
    }
}

struct OpenFoodFactsSearchResult: Decodable {
    var products: [OpenFoodFactsProduct]?
    
    enum CodingKeys: String, CodingKey {
        case products
    }
}

struct OpenFoodFactsProduct: Decodable, Hashable, Identifiable {
    var id = UUID()
    var code: String?
    var productName: String?
    var brands: String?
    var genericName: String?
    var nutriments: Nutriments?
    var imageThumbUrl: String?
    var imageFrontSmallUrl: String?
    var imageFrontUrl: String?
    var imageNutritionThumbUrl: String?
    var imageNutritionSmallUrl: String?
    var imageNutritionUrl: String?
    var imageIngredientsThumbUrl: String?
    var imageSmallUrl: String?
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case code = "code"
        case productName = "product_name"
        case brands = "brands"
        case genericName = "generic_name"
        case nutriments = "nutriments"
        case imageThumbUrl = "image_thumb_url"
        case imageFrontSmallUrl = "image_front_small_url"
        case imageFrontUrl = "image_front_url"
        case imageNutritionThumbUrl = "image_nutrition_thumb_url"
        case imageNutritionSmallUrl = "image_nutrition_small_url"
        case imageNutritionUrl = "image_nutrition_url"
        case imageIngredientsThumbUrl = "image_ingredients_thumb_url"
        case imageSmallUrl = "image_small_url"
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
                // Empty by design, we just want to catch the try to decode as number
            }
            
            // Try to decode as String
            do {
                let singleValueContainer = try decoder.singleValueContainer()
                let string = try singleValueContainer.decode(String.self)
                self = .string(string)
                return
            } catch {
                // Empty by design, we just want to catch the try to decode as string
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
            throw FoodDatabaseError.incompleteData("Key not found: \(key.rawValue)")
        }
        
        switch value {
        case .number(let number):
            return number
        case .string(let string):
            guard let doubleFromString = Double(string) else {
                throw FoodDatabaseError.typeError("Wrong data type for key \(key.rawValue): Expected Double")
            }
            return doubleFromString
        }
    }
    
    func getNutrimentsStringValue(key: NutrimentsKey) throws -> String {
        guard let value = nutriments?[key.rawValue] else {
            throw FoodDatabaseError.incompleteData("Key not found: \(key.rawValue)")
        }
        
        switch value {
        case .string(let string):
            return string
        case .number(let number):
            return String(number)
        }
    }
    
    static func == (lhs: OpenFoodFactsProduct, rhs: OpenFoodFactsProduct) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    typealias Nutriments = [String: ValueType]
}
