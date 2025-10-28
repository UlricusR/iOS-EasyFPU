//
//  OpenFoodFacts.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 17.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

// Documentation of the OpenFoodFacts API:
// - For search, we use search-a-licious: https://search.openfoodfacts.org/docs#/default/search_get_search_get
//   Example: https://search.openfoodfacts.org/search?q=Boller%20countries_tags%3A%22en%3Agermany%22&page_size=50&page=1&fields=code%2Cproduct_name%2Cbrands%2Cnutriments%2Cimage_thumb_url
// - For details, we use API v2 with limited fields: https://openfoodfacts.github.io/openfoodfacts-server/api/ref-v2/#get-/api/v2/product/-barcode-
//   Example: https://world.openfoodfacts.org/api/v2/product/4014400929584?fields=product_name,product_quantity,product_quantity_unit,nutriments,selected_images


import Foundation

struct OpenFoodFacts: FoodDatabase {
    var databaseType = FoodDatabaseType.openFoodFacts
    
    private let userAgent = "EasyFPU - iOS - Version \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)"
    
    private var productFields: [String] {
        var fields = [String]()
        for field in OpenFoodFactsProduct.CodingKeys.allCases {
            fields.append(field.rawValue)
        }
        return fields
    }
    
    private var countrycode: String {
        if UserSettings.shared.searchWorldwide {
            return "world"
        }
        let countryCode = UserSettings.getCountryCode()?.lowercased()
        return countryCode != nil ? countryCode! : "world"
    }
    
    private var countryName: String? {
        if UserSettings.shared.searchWorldwide {
            return nil
        }
        let countryCode = UserSettings.getCountryCode()?.lowercased()
        if countryCode != nil, let countryName = OpenFoodFacts.countries[countryCode!] {
            return countryName.lowercased()
        }
        return nil
    }
    
    func search(for term: String, category: FoodItemCategory, completion: @escaping (Result<[FoodDatabaseEntry]?, FoodDatabaseError>) -> Void) {
        guard let urlSearchTerm = term.trimmingCharacters(in: .whitespacesAndNewlines).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(.failure(.inputError(NSLocalizedString("Unable to convert your search string into a valid URL", comment: ""))))
            return
        }
        
        var searchQuery = ""
        
        // Add country
        if let countryTag = countryName?.trimmingCharacters(in: .whitespacesAndNewlines).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            searchQuery = "\(urlSearchTerm)%20countries_tags%3A%22en%3A\(countryTag)%22"
        } else {
            searchQuery = "\(urlSearchTerm)"
        }
        
        let urlString = "https://search.openfoodfacts.org/search?q=\(searchQuery)&page_size=50&page=1&fields=\(productFields.joined(separator: ","))"
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
                    guard let products = openFoodFactsSearchResult.hits else {
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
    var hits: [OpenFoodFactsProduct]?
    
    enum CodingKeys: String, CodingKey {
        case hits
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
    var imageThumbURL: URL?
    var selectedImages: OpenFoodFactsSelectedProductImages?
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case code = "code"
        case productName = "product_name"
        case brands = "brands"
        case genericName = "generic_name"
        case quantity = "product_quantity"
        case quantityUnit = "product_quantity_unit"
        case nutriments = "nutriments"
        case imageThumbURL = "image_thumb_url"
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
        genericName = try? product.decode(String.self, forKey: .genericName)
        quantity = (try? product.decode(ValueType.self, forKey: .quantity)) ?? ValueType.number(0.0)
        quantityUnit = (try? FoodItemUnit(rawValue: product.decode(String.self, forKey: .quantityUnit))) ?? .gram
        imageThumbURL = try? product.decode(URL.self, forKey: .imageThumbURL)
        
        // Brands can be a string (in API V2) or an array of strings (in search-a-licious)
        brands = try? product.decode(String.self, forKey: .brands)
        if brands == nil {
            let brandsArray = try? product.decode([String].self, forKey: .brands)
            if brandsArray != nil, !brandsArray!.isEmpty {
                brands = brandsArray![0]
            }
        }
        
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

extension OpenFoodFacts {
    static let countries: [String: String] = [
       "ad" : "Andorra",
       "ae" : "United Arab Emirates",
       "af" : "Afghanistan",
       "ag" : "Antigua and Barbuda",
       "ai" : "Anguilla",
       "al" : "Albania",
       "am" : "Armenia",
       "ao" : "Angola",
       "aq" : "Antarctic",
       "ar" : "Argentina",
       "as" : "American Samoa",
       "at" : "Austria",
       "au" : "Australia",
       "aw" : "Aruba",
       "ax" : "Åland Islands",
       "az" : "Azerbaijan",
       "ba" : "Bosnia and Herzegovina",
       "bb" : "Barbados",
       "bd" : "Bangladesh",
       "be" : "Belgium",
       "bf" : "Burkina Faso",
       "bg" : "Bulgaria",
       "bh" : "Bahrain",
       "bi" : "Burundi",
       "bj" : "Benin",
       "bl" : "Saint-Barthélemy",
       "bm" : "Bermuda",
       "bn" : "Brunei",
       "bo" : "Bolivia",
       "bq" : "Caribbean Netherlands",
       "br" : "Brazil",
       "bs" : "The Bahamas",
       "bt" : "Bhutan",
       "bv" : "Bouvet Island",
       "bw" : "Botswana",
       "by" : "Belarus",
       "bz" : "Belize",
       "ca" : "Canada",
       "cc" : "Cocos (Keeling) Islands",
       "cd" : "Democratic Republic of the Congo",
       "cf" : "Central African Republic",
       "cg" : "Republic of the Congo",
       "ch" : "Switzerland",
       "ci" : "Côte d'Ivoire",
       "ck" : "Cook Islands",
       "cl" : "Chile",
       "cm" : "Cameroon",
       "cn" : "China",
       "co" : "Colombia",
       "cr" : "Costa Rica",
       "cu" : "Cuba",
       "cv" : "Cape Verde",
       "cw" : "Curaçao",
       "cx" : "Christmas Island",
       "cy" : "Cyprus",
       "cz" : "Czech Republic",
       "de" : "Germany",
       "dj" : "Djibouti",
       "dk" : "Denmark",
       "dm" : "Dominica",
       "do" : "Dominican Republic",
       "dz" : "Algeria",
       "ec" : "Ecuador",
       "ee" : "Estonia",
       "eg" : "Egypt",
       "eh" : "Western Sahara",
       "er" : "Eritrea",
       "es" : "Spain",
       "et" : "Ethiopia",
       "fi" : "Finland",
       "fj" : "Fiji",
       "fk" : "Falkland Islands",
       "fm" : "Federated States of Micronesia",
       "fo" : "Faroe Islands",
       "fr" : "France",
       "ga" : "Gabon",
       "gd" : "Grenada",
       "ge" : "Georgia",
       "gf" : "French Guiana",
       "gg" : "Guernsey",
       "gh" : "Ghana",
       "gi" : "Gibraltar",
       "gl" : "Greenland",
       "gm" : "Gambia",
       "gn" : "Guinea",
       "gp" : "Guadeloupe",
       "gq" : "Equatorial Guinea",
       "gr" : "Greece",
       "gs" : "South Georgia and the South Sandwich Islands",
       "gt" : "Guatemala",
       "gu" : "Guam",
       "gw" : "Guinea-Bissau",
       "gy" : "Guyana",
       "hk" : "Hong Kong",
       "hm" : "Heard Island and McDonald Islands",
       "hn" : "Honduras",
       "hr" : "Croatia",
       "ht" : "Haiti",
       "hu" : "Hungary",
       "id" : "Indonesia",
       "ie" : "Ireland",
       "il" : "Israel",
       "im" : "Isle of Man",
       "in" : "India",
       "io" : "British Indian Ocean Territory",
       "iq" : "Iraq",
       "ir" : "Iran",
       "is" : "Iceland",
       "it" : "Italy",
       "je" : "Jersey",
       "jm" : "Jamaica",
       "jo" : "Jordan",
       "jp" : "Japan",
       "ke" : "Kenya",
       "kg" : "Kyrgyzstan",
       "kh" : "Cambodia",
       "ki" : "Kiribati",
       "km" : "Comoros",
       "kn" : "Saint Kitts and Nevis",
       "kp" : "North Korea",
       "kr" : "South Korea",
       "kw" : "Kuwait",
       "ky" : "Cayman Islands",
       "kz" : "Kazakhstan",
       "la" : "Laos",
       "lb" : "Lebanon",
       "lc" : "Saint Lucia",
       "li" : "Liechtenstein",
       "lk" : "Sri Lanka",
       "lr" : "Liberia",
       "ls" : "Lesotho",
       "lt" : "Lithuania",
       "lu" : "Luxembourg",
       "lv" : "Latvia",
       "ly" : "Libya",
       "ma" : "Morocco",
       "mc" : "Monaco",
       "md" : "Moldova",
       "me" : "Montenegro",
       "mf" : "Saint Martin",
       "mg" : "Madagascar",
       "mh" : "Marshall Islands",
       "mk" : "North Macedonia",
       "ml" : "Mali",
       "mm" : "Myanmar",
       "mn" : "Mongolia",
       "mo" : "Macau",
       "mp" : "Northern Mariana Islands",
       "mq" : "Martinique",
       "mr" : "Mauritania",
       "ms" : "Montserrat",
       "mt" : "Malta",
       "mu" : "Mauritius",
       "mv" : "Maldives",
       "mw" : "Malawi",
       "mx" : "Mexico",
       "my" : "Malaysia",
       "mz" : "Mozambique",
       "na" : "Namibia",
       "nc" : "New Caledonia",
       "ne" : "Niger",
       "nf" : "Norfolk Island",
       "ng" : "Nigeria",
       "ni" : "Nicaragua",
       "nl" : "Netherlands",
       "no" : "Norway",
       "np" : "Nepal",
       "nr" : "Nauru",
       "nu" : "Niue",
       "nz" : "New Zealand",
       "om" : "Oman",
       "pa" : "Panama",
       "pe" : "Peru",
       "pf" : "French Polynesia",
       "pg" : "Papua New Guinea",
       "ph" : "Philippines",
       "pk" : "Pakistan",
       "pl" : "Poland",
       "pm" : "Saint Pierre and Miquelon",
       "pn" : "Pitcairn",
       "pr" : "Puerto Rico",
       "ps" : "State of Palestine",
       "pt" : "Portugal",
       "pw" : "Palau",
       "py" : "Paraguay",
       "qa" : "Qatar",
       "re" : "Réunion",
       "ro" : "Romania",
       "rs" : "Serbia",
       "ru" : "Russia",
       "rw" : "Rwanda",
       "sa" : "Saudi Arabia",
       "sb" : "Solomon Islands",
       "sc" : "Seychelles",
       "sd" : "Sudan",
       "se" : "Sweden",
       "sg" : "Singapore",
       "sh" : "Saint Helena",
       "si" : "Slovenia",
       "sj" : "Svalbard and Jan Mayen",
       "sk" : "Slovakia",
       "sl" : "Sierra Leone",
       "sm" : "San Marino",
       "sn" : "Senegal",
       "so" : "Somalia",
       "sr" : "Suriname",
       "ss" : "South Sudan",
       "st" : "Sao Tomé and Príncipe",
       "sv" : "El Salvador",
       "sx" : "Sint Maarten",
       "sy" : "Syria",
       "sz" : "Swaziland",
       "tc" : "Turks and Caicos Islands",
       "td" : "Chad",
       "tf" : "French Southern and Antarctic Lands",
       "tg" : "Togo",
       "th" : "Thailand",
       "tj" : "Tajikistan",
       "tk" : "Tokelau",
       "tl" : "Timor-Leste",
       "tm" : "Turkmenistan",
       "tn" : "Tunisia",
       "to" : "Tonga",
       "tr" : "Turkey",
       "tt" : "Trinidad and Tobago",
       "tv" : "Tuvalu",
       "tw" : "Taiwan",
       "tz" : "Tanzania",
       "ua" : "Ukraine",
       "ug" : "Uganda",
       "uk" : "United Kingdom",
       "um" : "United States Minor Outlying Islands",
       "us" : "United States",
       "uy" : "Uruguay",
       "uz" : "Uzbekistan",
       "va" : "Vatican City",
       "vc" : "Saint Vincent and the Grenadines",
       "ve" : "Venezuela",
       "vg" : "British Virgin Islands",
       "vi" : "Virgin Islands of the United States",
       "vn" : "Vietnam",
       "vu" : "Vanuatu",
       "wf" : "Wallis and Futuna",
       "world" : "World",
       "ws" : "Samoa",
       "xk" : "Kosovo",
       "ye" : "Yemen",
       "yt" : "Mayotte",
       "yu" : "Yugoslavia",
       "za" : "South Africa",
       "zm" : "Zambia",
       "zw" : "Zimbabwe"
    ]
}
