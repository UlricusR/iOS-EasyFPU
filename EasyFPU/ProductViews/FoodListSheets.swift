//
//  FoodListSheets.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 14.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class FoodListSheets {
    enum State: Identifiable {
        case addFoodItem
        case mealDetails
        case help
        
        var id: State { self }
    }
}
