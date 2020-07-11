//
//  Food.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 11.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class Food {
    var id: UUID = UUID()
    var amount: Int = 0
    var selected: Bool = false
    var name: String
    var favorite: Bool = false
    var caloriesPer100g: Double
    var carbsPer100g: Double
    var amountSmall: Int?
    var amountMedium: Int?
    var amountLarge: Int?
    var commentSmall: String?
    var commendMedium: String?
    var commentLarge: String?
    
    init(name: String, caloriesPer100g: Double, carbsPer100g: Double) {
        self.name = name
        self.caloriesPer100g = caloriesPer100g
        self.carbsPer100g = carbsPer100g
    }
}
