//
//  CountryCodes.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 23.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class OpenFoodFactsCountryCodes: Decodable {
    static var alpha2Codes: CountryCodesType = load()
    
    static func load() -> CountryCodesType {
        do {
            if
                let filePath = Bundle.main.path(forResource: "ISO3166-1.alpha2", ofType: "json"),
                let jsonData = try String(contentsOfFile: filePath).data(using: .utf8)
            {
                let decodeData = try JSONDecoder().decode(CountryCodesType.self, from: jsonData)
                return decodeData
            }
        } catch {
            debugPrint(error)
        }
        return CountryCodesType()
    }
    
    static func getAllCodes() -> [String] {
        Array(alpha2Codes.keys.sorted())
    }
    
    static func getAllCountries() -> [String] {
        Array(alpha2Codes.values.sorted())
    }
    
    static func getDefault() -> (code: String, country: String)? {
        if let locale = Locale.current.regionCode?.lowercased() {
            let allCodesInCapitals = getAllCodes().map({ $0.uppercased() })
            if allCodesInCapitals.contains(locale.uppercased()) {
                return (code: locale, country: alpha2Codes[locale.uppercased()]!)
            }
        }
        
        return nil
    }
    
    typealias CountryCodesType = [String: String]
}
