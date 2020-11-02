//
//  FoodPreviewSheets.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 27.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class FoodPreviewContentSheets {
    enum State: Identifiable {
        case front
        case nutriments
        case ingredients
        
        var id: State { self }
    }
}
