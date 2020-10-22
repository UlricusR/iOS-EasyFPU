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
    func search(for term: String, foodDatabaseResults: FoodDatabaseResults)
    func prepare(_ id: String, foodDatabaseResults: FoodDatabaseResults)
}

enum FoodDatabaseType: String {
    case openFoodFacts = "OpenFoodFacts"
    
    static let key = "FoodDatabase"
}

enum FoodDatabaseError: Error {
    case incompleteData(String)
    case typeError(String)
    case noSearchResults
    case networkError(String)
    case inputError(String)
}
