//
//  TypicalAmountViewModel.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 24.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class TypicalAmountViewModel: ObservableObject, Hashable, Comparable, Codable, Identifiable {
    var id = UUID()
    
    @Published var amountAsString: String {
        willSet {
            let result = DataHelper.checkForPositiveInt(valueAsString: newValue, allowZero: false)
            switch result {
            case .success(let amount):
                self.amount = amount
            case .failure(let err):
                debugPrint(err.evaluate())
                return
            }
        }
    }
    @Published var comment: String
    private(set) var amount: Int = 0
    var cdTypicalAmount: TypicalAmount?
    
    enum CodingKeys: String, CodingKey {
        case amount, comment
    }
    
    init(from cdTypicalAmount: TypicalAmount) {
        self.cdTypicalAmount = cdTypicalAmount
        self.amountAsString = String(cdTypicalAmount.amount)
        self.amount = Int(cdTypicalAmount.amount)
        self.comment = cdTypicalAmount.comment ?? ""
    }
    
    /// Initializes the TypicalAmountViewModel from a string representation of the amount, which should be an whole positive number.
    /// Decimal numbers need to contain the decimal separator of the current locale and the decimal part will be cropped.
    /// - Parameters:
    ///   - amountAsString: The string representation of the amount.
    ///   - comment: The related comment.
    ///   - errorMessage: Stores the error type and message in case the amount cannot be generated from its string representation.
    init?(amountAsString: String, comment: String, errorMessage: inout String) {
        self.comment = comment
        
        // Check for valid amount
        let result = DataHelper.checkForPositiveInt(valueAsString: amountAsString, allowZero: false)
        switch result {
        case .success(let amount):
            self.amount = amount
        case .failure(let err):
            errorMessage = err.evaluate()
            return nil
        }
        self.amountAsString = amountAsString
    }
    
    /// Initializes the TypicalAmountViewModel with an Integer amount. The string representation is automatically generated.
    /// - Parameters:
    ///   - amount: The amount.
    ///   - comment: The related comment.
    init(amount: Int, comment: String) {
        self.amount = amount
        self.comment = comment
        self.amountAsString = String(amount)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        amount = try container.decode(Int.self, forKey: .amount)
        comment = try container.decode(String.self, forKey: .comment)
        amountAsString = String(amount)
    }
    
    /// Creates a new Core Data TypicalAmount and adds it to the FoodItem associated to the passed FoodItemViewModel.
    /// - Parameter foodItemVM: The FoodItemViewModel, the Core Data FoodItem of which the TypicalAmount should be added to.
    /// - Returns: False if no Core Data FoodItem was found (should not happen), otherwise true.
    func save(to foodItemVM: FoodItemViewModel) -> Bool {
        guard let cdFoodItem = foodItemVM.cdFoodItem else { return false }
        let newTypicalAmount = TypicalAmount.create(from: self)
        FoodItem.add(newTypicalAmount, to: cdFoodItem)
        return true
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(amount, forKey: .amount)
        try container.encode(comment, forKey: .comment)
    }
    
    static func == (lhs: TypicalAmountViewModel, rhs: TypicalAmountViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    static func < (lhs: TypicalAmountViewModel, rhs: TypicalAmountViewModel) -> Bool {
        lhs.amount < rhs.amount
    }
}
