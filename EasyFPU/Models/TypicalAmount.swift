//
//  TypicalAmount.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 11.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class TypicalAmount {
    var amount: Int
    var comment: String
    var defaultComment: String
    
    init(amount: Int, comment: String, defaultComment: String) {
        self.amount = amount
        self.comment = comment
        self.defaultComment = defaultComment
    }
}
