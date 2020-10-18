//
//  FoodDatabaseEntry.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 17.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

struct FoodDatabaseEntry {
    var productName: String
    var caloriesPer100g: Double
    var carbsPer100g: Double
    var source: FoodDatabase
    var sourceId: String
    
    var sugarsPer100g: Double?
    var genericName: String?
    var brand: String?
}
