//
//  FoodDatabase.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 17.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

enum FoodDatabaseError: Error {
    case incompleteData(String)
    case typeError(String)
    case noSearchResults
    case networkError(String)
    case inputError(String)
}
