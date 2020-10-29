//
//  MealDetailSheets.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 08.09.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class MealDetailSheets {
    enum State: Identifiable {
        case help
        case exportToHealth
        
        var id: State { self }
    }
}
