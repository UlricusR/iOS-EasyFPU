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
    func getLink(for id: String) throws -> URL
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
    case noSearchResults(String)
    case networkError(String)
    case inputError(String)
    
    func evaluate() -> String {
        switch self {
        case .incompleteData(let storedErrorMessage):
            return (NSLocalizedString("Incomplete data: ", comment: "") + storedErrorMessage)
        case .decodingError(let storedErrorMessage):
            return(NSLocalizedString("Decoding error: ", comment: "") + storedErrorMessage)
        case .noSearchResults(let storedErrorMessage):
            return (NSLocalizedString("No search results: ", comment: "") + storedErrorMessage)
        case .networkError(let storedErrorMessage):
            return (NSLocalizedString("Network error: ", comment: "") + storedErrorMessage)
        case .inputError(let storedErrorMessage):
            return (NSLocalizedString("Input error: ", comment: "") + storedErrorMessage)
        }
    }
}

enum EnergyType: Equatable {
    case kJ(Double)
    case kcal(Double)
    
    func getEnergyInKcal() -> Double {
        switch self {
        case .kJ(let energy):
            return 0.2388 * energy
        case .kcal(let energy):
            return energy
        }
    }
}
