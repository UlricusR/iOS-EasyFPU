//
//  FoodDatabase.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 17.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

protocol FoodDatabase {
    var databaseType: FoodDatabaseType { get }
    func search(for term: String, completion: @escaping (Result<[FoodDatabaseEntry]?, FoodDatabaseError>) -> Void)
    func prepare(_ id: String, completion: @escaping (Result<FoodDatabaseEntry?, FoodDatabaseError>) -> Void)
}

enum FoodDatabaseType: String, CaseIterable, Identifiable {
    case openFoodFacts = "Open Food Facts"
    
    var id: String { self.rawValue }
    
    static func getFoodDatabase(type: FoodDatabaseType) -> FoodDatabase {
        switch type {
        case .openFoodFacts:
            return OpenFoodFacts()
        }
    }
    
    static func getDefaultFoodDatabaseType() -> FoodDatabaseType {
        return .openFoodFacts
    }
    
    static let key = "FoodDatabase"
}

enum FoodDatabaseError: Error {
    case incompleteData(String)
    case decodingError(String)
    case noSearchResults
    case networkError(String)
    case inputError(String)
}
