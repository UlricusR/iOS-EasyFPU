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
    @Published var amountAsString: String
    @Published var comment: String
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
    
    func getAmount() -> Int {
        var value = 0
        if !FoodItemViewModel.checkForPositiveInt(valueAsString: amountAsString, valueAsInt: &value) {
            return 0
        }
        return value
    }
    
    func updateCDTypicalAmount(foodItem: FoodItem?) -> Bool {
        if cdTypicalAmount == nil { return false }
        cdTypicalAmount!.amount = Int64(getAmount())
        cdTypicalAmount!.comment = comment
        cdTypicalAmount!.foodItem = foodItem
        return true
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: TypicalAmountViewModel, rhs: TypicalAmountViewModel) -> Bool {
        lhs.getAmount() == rhs.getAmount()
    }
    
    static func < (lhs: TypicalAmountViewModel, rhs: TypicalAmountViewModel) -> Bool {
        lhs.getAmount() < rhs.getAmount()
    }
}
