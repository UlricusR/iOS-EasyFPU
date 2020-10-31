//
//  VariableAmountItem.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 31.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

protocol VariableAmountItem: ObservableObject {
    var amountAsString: String { get set }
    var amount: Int { get set }
}
