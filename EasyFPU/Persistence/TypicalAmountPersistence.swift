//
//  TypicalAmountViewModel.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 24.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class TypicalAmountPersistence: Hashable, Comparable, Codable, Identifiable {
    var id = UUID()
    var comment: String
    var amount: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case amount, comment
    }
    
    init(from cdTypicalAmount: TypicalAmount) {
        self.amount = Int(cdTypicalAmount.amount)
        self.comment = cdTypicalAmount.comment ?? ""
    }
    
    /// Initializes the TypicalAmountViewModel with an Integer amount. The string representation is automatically generated.
    /// - Parameters:
    ///   - amount: The amount.
    ///   - comment: The related comment.
    init(amount: Int, comment: String) {
        self.amount = amount
        self.comment = comment
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        amount = try container.decode(Int.self, forKey: .amount)
        comment = try container.decode(String.self, forKey: .comment)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(amount, forKey: .amount)
        try container.encode(comment, forKey: .comment)
    }
    
    static func == (lhs: TypicalAmountPersistence, rhs: TypicalAmountPersistence) -> Bool {
        lhs.id == rhs.id
    }
    
    static func < (lhs: TypicalAmountPersistence, rhs: TypicalAmountPersistence) -> Bool {
        lhs.amount < rhs.amount
    }
    
    static func sampleData() -> [TypicalAmountPersistence] {
        [
            TypicalAmountPersistence(amount: 100, comment: "Sample comment"),
            TypicalAmountPersistence(amount: 200, comment: "Another sample comment"),
            TypicalAmountPersistence(amount: 300, comment: "Yet another sample comment")
        ]
    }
}
