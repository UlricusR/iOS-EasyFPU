//
//  FoodListSheets.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 14.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class FoodListSheets: SheetState<FoodListSheets.State> {
    enum State {
        case addFoodItem
        case mealDetails
        case help
    }
}
