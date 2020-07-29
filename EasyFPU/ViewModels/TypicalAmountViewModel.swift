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
            let result = FoodItemViewModel.checkForPositiveInt(valueAsString: newValue, allowZero: false)
            switch result {
            case .success(let amount):
                self.amount = amount
            case .failure(let err):
                debugPrint(err.localizedDescription)
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
        self.amount = Int(cdTypicalAmount.amount)
        self.comment = cdTypicalAmount.comment ?? ""
    }
    
    init?(amountAsString: String, comment: String, errorMessage: inout String) {
        self.comment = comment
        
        // Check for valid amount
        let result = FoodItemViewModel.checkForPositiveInt(valueAsString: amountAsString, allowZero: false)
        switch result {
        case .success(let amount):
            self.amount = amount
        case .failure(let err):
            errorMessage = err.localizedDescription
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
        lhs.id == rhs.id
    }
    
    static func < (lhs: TypicalAmountViewModel, rhs: TypicalAmountViewModel) -> Bool {
        lhs.amount < rhs.amount
    }
}
