//
//  IngredientsListSheets.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 29.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class IngredientsListSheets2 {
    enum State: Identifiable {
        case addIngredient
        case composedProductDetail
        case help
        
        var id: State { self }
    }
}
