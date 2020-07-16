//
//  TextFieldDouble.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 16.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct TextFieldDouble: View {
    var title: String
    @Binding var value: Double
    
    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        formatter.isPartialStringValidationEnabled = true
        formatter.isLenient = true
        return formatter
    }()
    
    var body: some View {
        TextField(title, value: $value.asNSNumber(), formatter: type(of: self).numberFormatter)
            .keyboardType(.decimalPad)
    }
}

extension Binding where Value == Double {
    func asNSNumber() -> Binding<NSNumber> {
        return Binding<NSNumber>(get: {
            NSNumber(value: self.wrappedValue)
        }, set: {
            self.wrappedValue = $0.doubleValue
        })
    }
}
