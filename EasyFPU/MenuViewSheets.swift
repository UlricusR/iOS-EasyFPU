//
//  FoodListSheets.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 14.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class MenuViewSheets {
    enum State: Identifiable {
        case editAbsorptionScheme
        case pickFileToImport
        case pickExportDirectory
        case about
        
        var id: State { self }
    }
}
