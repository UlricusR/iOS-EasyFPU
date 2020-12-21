//
//  FoodDatabaseResults.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 22.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class FoodDatabaseResults: ObservableObject {
    @Published var selectedEntry: FoodDatabaseEntry?
    @Published var searchResults: [FoodDatabaseEntry]?
    @Published var selectionWasConfirmed: Bool = false
}
