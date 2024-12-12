//
//  FoodDatabaseResults.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 22.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class FoodDatabaseResults: ObservableObject, Hashable {
    @Published var selectedEntry: FoodDatabaseEntry?
    @Published var searchResults: [FoodDatabaseEntry]?
    @Published var selectionWasConfirmed: Bool = false
    
    static func == (lhs: FoodDatabaseResults, rhs: FoodDatabaseResults) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
