//
//  FoodItemEditorSheets.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 19.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class FoodItemEditorSheets {
    enum State: Identifiable {
        case help
        case search
        case scan
        case foodPreview
        
        var id: State { self }
    }
    
    enum AlertState: Identifiable {
        case alertMessage
        case scan
        case search
        case warningUpdateIngredients
        
        var id: AlertState { self }
    }
}
