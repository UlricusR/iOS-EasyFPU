//
//  FoodDatabase.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 17.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

protocol FoodDatabase {
    func search(for name: String) -> [String]
    func get(_ id: String)
}

protocol FoodDatabaseObject {
    func fill(foodDatabase: FoodDatabase, id: String) throws -> FoodDatabaseEntry
}

enum FoodDatabaseError: Error {
    case incompleteData(String)
    case typeError(String)
}
