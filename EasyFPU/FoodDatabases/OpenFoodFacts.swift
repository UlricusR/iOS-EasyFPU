//
//  OpenFoodFacts.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 17.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class OpenFoodFacts: ObservableObject {
    @Published var foodDatabaseEntry: FoodDatabaseEntry?
    @Published var searchResults = [OpenFoodFactsProduct]()
    @Published var errorMessage: String?
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
    
    func search(for term: String) {
        guard let urlSearchTerm = term.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            errorMessage = NSLocalizedString("Unable to convert your search string into a valid URL", comment: "")
            return
        }
        let urlString = "https://\(countrycode)-\(languagecode).openfoodfacts.org/cgi/search.pl?action=process&search_terms=\(urlSearchTerm)&sort_by=unique_scans_n&json=true"
        let request = prepareRequest(urlString)
        
        let session = URLSession.shared
        session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
            guard error == nil else {
                debugPrint(error!.localizedDescription)
                self.errorMessage = error!.localizedDescription
                return
            }
            
            if let data = data {
                do {
                    let openFoodFactsSearchResult = try JSONDecoder().decode(OpenFoodFactsSearchResult.self, from: data)
                    guard let products = openFoodFactsSearchResult.products else {
                        throw FoodDatabaseError.noSearchResults
                    }
                    
                    DispatchQueue.main.async {
                        self.searchResults = products
                        self.objectWillChange.send()
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.errorMessage = error.localizedDescription
                        self.objectWillChange.send()
                    }
                }
            }
        }).resume()
    }
    
    func prepare(_ id: String) {
        let urlString = "https://\(countrycode)-\(languagecode).openfoodfacts.org/api/v0/product/\(id).json?fields=\(productFields.joined(separator: ","))"
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
                            self.foodDatabaseEntry = try product.fill(foodDatabase: self)
                            self.objectWillChange.send()
                        } catch FoodDatabaseError.incompleteData(let errorMessage) {
                            self.errorMessage = errorMessage
                        } catch {
                            self.errorMessage = error.localizedDescription
                        }
                    }
                } catch {
                    debugPrint(error.localizedDescription)
                    DispatchQueue.main.async {
                        self.errorMessage = error.localizedDescription
                        self.objectWillChange.send()
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

struct OpenFoodFactsProduct: Decodable, Hashable {
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
    
    static func == (lhs: OpenFoodFactsProduct, rhs: OpenFoodFactsProduct) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func fill(foodDatabase: OpenFoodFacts) throws -> FoodDatabaseEntry {
        // First address the mandatory values
        guard let productName = productName else {
            throw FoodDatabaseError.incompleteData(NSLocalizedString("Entry has no name", comment: ""))
        }
        
        guard let code = code else {
            throw FoodDatabaseError.incompleteData(NSLocalizedString("Entry has no code", comment: ""))
        }
        
        let caloriesPer100g = try getNutrimentsDoubleValue(key: OpenFoodFactsProduct.NutrimentsKey.caloriesPer100g)
        let carbsPer100g = try getNutrimentsDoubleValue(key: OpenFoodFactsProduct.NutrimentsKey.carbsPer100g)
        
        var foodDatabaseEntry = FoodDatabaseEntry(
            productName: productName,
            caloriesPer100g: caloriesPer100g,
            carbsPer100g: carbsPer100g,
            source: foodDatabase,
            sourceId: code
        )
        
        // Append optional values if available
        if let sugarsPer100g = try? getNutrimentsDoubleValue(key: OpenFoodFactsProduct.NutrimentsKey.sugarsPer100g) {
            foodDatabaseEntry.sugarsPer100g = sugarsPer100g
        }
        
        if genericName != nil {
            foodDatabaseEntry.genericName = genericName!
        }
        
        if brands != nil {
            foodDatabaseEntry.brand = brands!
        }
        
        // Return the resulting entry
        return foodDatabaseEntry
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
    
    typealias Nutriments = [String: ValueType]
}
