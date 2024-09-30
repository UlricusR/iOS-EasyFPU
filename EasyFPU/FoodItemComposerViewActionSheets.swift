//
//  FoodItemComposerViewActionSheets.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 30.09.24.
//  Copyright © 2024 Ulrich Rüth. All rights reserved.
//

import Foundation

class FoodItemComposerViewActionSheets {
    enum State: Identifiable {
        case weightDifference
        case existingProduct
        case missingProduct
        
        var id: State { self }
    }
}
