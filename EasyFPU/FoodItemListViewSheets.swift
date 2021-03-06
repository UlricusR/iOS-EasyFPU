//
//  FoodItemListViewSheets.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 01.11.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class FoodItemListViewSheets {
    enum State: Identifiable {
        case addFoodItem
        case productsListHelp
        case ingredientsListHelp
        
        var id: State { self }
    }
}
