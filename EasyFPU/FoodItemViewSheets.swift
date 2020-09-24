//
//  FoodListSheets.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 14.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class FoodItemViewSheets: SheetState<FoodItemViewSheets.State> {
    enum State {
        case editFoodItem
        case selectFoodItem
    }
}
