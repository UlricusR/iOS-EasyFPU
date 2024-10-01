//
//  FoodListSheets.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 30.09.24.
//  Copyright © 2024 Ulrich Rüth. All rights reserved.
//

import Foundation

class RecipeViewSheets {
    enum State: Identifiable {
        case editRecipe
        case exportRecipe
        
        var id: State { self }
    }
}
