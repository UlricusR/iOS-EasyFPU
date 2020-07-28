//
//  TypicalAmountViewModel.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 24.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class TypicalAmountViewModel: ObservableObject, Hashable, Comparable {
    var id = UUID()
    @Published var amountAsString: String {
        willSet {
            guard FoodItemViewModel.checkForPositiveInt(valueAsString: newValue, valueAsInt: &amount) else {
                return
            }
        }
    }
    @Published var comment: String
    private(set) var amount: Int = 0
    var cdTypicalAmount: TypicalAmount?
    
    init(from cdTypicalAmount: TypicalAmount) {
        self.cdTypicalAmount = cdTypicalAmount
        self.amountAsString = String(cdTypicalAmount.amount)
        self.comment = cdTypicalAmount.comment ?? ""
    }
    
    init?(amountAsString: String, comment: String, errorMessage: inout String) {
        self.comment = comment
        
        // Check for valid amount
        var amount = 0
        guard FoodItemViewModel.checkForPositiveInt(valueAsString: amountAsString, valueAsInt: &amount) else {
            errorMessage = NSLocalizedString("Amount not a valid number or negative", comment: "")
            return nil
        }
        self.amountAsString = amountAsString
    }
    
    func updateCDTypicalAmount(foodItem: FoodItem?) -> Bool {
        if cdTypicalAmount == nil { return false }
        cdTypicalAmount!.amount = Int64(amount)
        cdTypicalAmount!.comment = comment
        cdTypicalAmount!.foodItem = foodItem
        return true
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: TypicalAmountViewModel, rhs: TypicalAmountViewModel) -> Bool {
        lhs.amount == rhs.amount
    }
    
    static func < (lhs: TypicalAmountViewModel, rhs: TypicalAmountViewModel) -> Bool {
        lhs.amount < rhs.amount
    }
}
