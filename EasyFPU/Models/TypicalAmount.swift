//
//  TypicalAmount.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 11.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class TypicalAmount: Codable {
    var amount: Int
    var comment: String
    
    init(amount: Int, comment: String, defaultComment: String) {
        self.amount = amount
        self.comment = comment
    }
}
