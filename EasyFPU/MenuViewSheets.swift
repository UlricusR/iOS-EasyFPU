//
//  FoodListSheets.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 14.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class MenuViewSheets: SheetState<MenuViewSheets.State> {
    enum State {
        case editAbsorptionScheme
        case pickFileToImport
        case pickExportDirectory
        case about
        case disclaimer
    }
}
