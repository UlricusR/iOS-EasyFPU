//
//  OpenFoodFacts.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 17.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

struct OpenFoodFacts: FoodDatabase {
    var databaseType = FoodDatabaseType.openFoodFacts
    private var countrycode: String {
        if UserSettings.shared.searchWorldwide {
            return "world"
        }
        let countryCode = UserSettings.getCountryCode()?.lowercased()
        return countryCode != nil ? countryCode! : "world"
    }
    private let userAgent = "EasyFPU - iOS - Version \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)"
    private var productFields: [String] {
        var fields = [String]()
        for field in OpenFoodFactsProduct.CodingKeys.allCases {
            fields.append(field.rawValue)
        }
        return fields
    }
    
    func search(for term: String, category: FoodItemCategory, completion: @escaping (Result<[FoodDatabaseEntry]?, FoodDatabaseError>) -> Void) {
        guard let urlSearchTerm = term.trimmingCharacters(in: .whitespacesAndNewlines).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(.failure(.inputError(NSLocalizedString("Unable to convert your search string into a valid URL", comment: ""))))
            return
        }
        let urlString = "https://\(countrycode).openfoodfacts.org/cgi/search.pl?action=process&search_terms=\(urlSearchTerm)&sort_by=unique_scans_n&json=true" // Version without language code
        let request = prepareRequest(urlString)
        
        let session = URLSession.shared
        session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
            guard error == nil else {
                debugPrint(error!.localizedDescription)
                completion(.failure(.networkError(error!.localizedDescription)))
                return
            }
            
            if let data = data {
                do {
                    let openFoodFactsSearchResult = try JSONDecoder().decode(OpenFoodFactsSearchResult.self, from: data)
                    guard let products = openFoodFactsSearchResult.products else {
                        completion(.failure(FoodDatabaseError.noSearchResults(NSLocalizedString("No products found", comment: ""))))
                        return
                    }
                    
                    let searchResults = products.compactMap( { FoodDatabaseEntry(from: $0, category: category) })
                    completion(.success(searchResults))
                } catch {
                    debugPrint(error.localizedDescription)
                    completion(.failure(.decodingError(error.localizedDescription)))
                }
            }
        }).resume()
    }
    
    func prepare(_ id: String, category: FoodItemCategory, completion: @escaping (Result<FoodDatabaseEntry?, FoodDatabaseError>) -> Void) {
        let urlString = "https://\(countrycode).openfoodfacts.org/api/v2/product/\(id).json?fields=\(productFields.joined(separator: ","))"
        let request = prepareRequest(urlString)
        
        let session = URLSession.shared
        session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                guard let openFoodFactsObject = try? JSONDecoder().decode(OpenFoodFactsObject.self, from: data) else {
                    completion(.failure(.decodingError(error?.localizedDescription ?? NSLocalizedString("Cannot decode JSON", comment: ""))))
                    return
                }
                
                // Check if there's a product
                guard let product = openFoodFactsObject.product else {
                    completion(.failure(.incompleteData(NSLocalizedString("No product found", comment: ""))))
                    return
                }
                
                // Fill the FoodDatabaseEntry
                guard let foodDatabaseEntry = FoodDatabaseEntry(from: product, category: category) else {
                    completion(.failure(.incompleteData(NSLocalizedString("No food found", comment: ""))))
                    return
                }
                
                // We have an entry
                completion(.success(foodDatabaseEntry))
            }
        }).resume()
    }
    
    private func prepareRequest(_ urlString: String) -> URLRequest {
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        return request
    }
    
    func getLink(for id: String) throws -> URL {
        let urlString = "https://\(countrycode)-en.openfoodfacts.org/product/\(id)"
        guard let url = URL(string: urlString) else {
            throw FoodDatabaseError.inputError(NSLocalizedString("Invalid URL: ", comment: "") + urlString)
        }
        return url
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
    var productName: String
    var brands: String?
    var genericName: String?
    var quantity: ValueType
    var quantityUnit: FoodItemUnit
    var nutriments: Nutriments?
    var selectedImages: OpenFoodFactsSelectedProductImages?
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case code = "code"
        case productName = "product_name"
        case brands = "brands"
        case genericName = "generic_name"
        case quantity = "product_quantity"
        case quantityUnit = "product_quantity_unit"
        case nutriments = "nutriments"
        case selectedImages = "selected_images"
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
        case caloriesPer100gInKcal = "energy-kcal_100g"
        case caloriesPer100gInKJ = "energy-kj_100g"
        case carbsPer100g = "carbohydrates_100g"
        case sugarsPer100g = "sugars_100g"
    }
    
    init(from decoder: Decoder) throws {
        let product = try decoder.container(keyedBy: CodingKeys.self)
        code = try? product.decode(String.self, forKey: .code)
        productName = (try? product.decode(String.self, forKey: .productName)) ?? NSLocalizedString("- No name -", comment: "")
        brands = try? product.decode(String.self, forKey: .brands)
        genericName = try? product.decode(String.self, forKey: .genericName)
        quantity = (try? product.decode(ValueType.self, forKey: .quantity)) ?? ValueType.number(0.0)
        quantityUnit = (try? FoodItemUnit(rawValue: product.decode(String.self, forKey: .quantityUnit))) ?? .gram
        
        nutriments = try? product.decode(Nutriments.self, forKey: .nutriments)
        selectedImages = try? product.decode(OpenFoodFactsSelectedProductImages.self, forKey: .selectedImages)
    }
    
    func getQuantity() throws -> Double {
        switch quantity {
        case .number(let number):
            return number
        case .string(let string):
            guard let doubleFromString = Double(string) else {
                throw FoodDatabaseError.decodingError("Wrong data type for key quantity: Expected Double")
            }
            return doubleFromString
        }
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
                throw FoodDatabaseError.decodingError("Wrong data type for key \(key.rawValue): Expected Double")
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

struct OpenFoodFactsSelectedProductImages: Decodable {
    var front: OpenFoodFactsProductImages?
    var nutrition: OpenFoodFactsProductImages?
    var ingredients: OpenFoodFactsProductImages?
}

struct OpenFoodFactsProductImages: Decodable {
    var small: [String: String]?
    var thumb: [String: String]?
    var display: [String: String]?
}
