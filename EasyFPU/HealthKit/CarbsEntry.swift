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

struct CarbsEntry: Hashable {
    var type: CarbsEntryType
    var value: Double
    var date: Date
    
    static var `default` = CarbsEntry(type: .carbs, value: 1.0, date: Date())
    
    init(type: CarbsEntryType, value: Double, date: Date) {
        self.type = type
        self.value = value
        self.date = date
    }
    
    static func == (lhs: CarbsEntry, rhs: CarbsEntry) -> Bool {
        if lhs.type != rhs.type { return false }
        if lhs.date != rhs.date { return false }
        return lhs.value == rhs.value
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(date)
        hasher.combine(value)
    }
}
