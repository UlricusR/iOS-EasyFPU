//
//  CarbsEntry.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 20.09.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

enum CarbsEntryType {
    case sugars, carbs, eCarbs
}

class CarbsEntry {
    var type: CarbsEntryType
    var value: Double
    var date: Date
    
    init(type: CarbsEntryType, value: Double, date: Date) {
        self.type = type
        self.value = value
        self.date = date
    }
}
