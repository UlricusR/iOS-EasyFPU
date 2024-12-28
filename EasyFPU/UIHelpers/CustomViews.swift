//
//  CustomViews.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 29.09.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI
import Combine

/// A TextField that only allows certain characters to be entered.
/// If keyboardType is .numberPad, only digits are allowed.
/// If keyboardType is .decimalPad, only digits and the localized decimal separator are allowed.
struct CustomTextField: View {
    var titleKey: String
    @Binding var text: String
    var keyboardType: UIKeyboardType
    
    var body: some View {
        AnyView(TextField(titleKey, text: $text)
        .keyboardType(keyboardType))
        .onReceive(Just(text)) { newValue in
            let filtered = newValue.filter {
                if keyboardType == .numberPad {
                    return "0123456789".contains($0)
                } else if keyboardType == .decimalPad {
                    return "0123456789\(String(describing: Locale.current.decimalSeparator))".contains($0)
                } else {
                    return true
                }
            }
            if filtered != newValue {
                text = filtered
            }
        }
    }
}

struct NumberButton<T: VariableAmountItem>: View {
    var number: Int
    var variableAmountItem: T
    var width: CGFloat
    
    var body: some View {
        Button("+\(self.number)") {
            let newValue = self.variableAmountItem.amount + self.number
            self.variableAmountItem.amountAsString = DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: newValue))!
        }
        .frame(width: width, height: 40, alignment: .center)
        .background(Color.green)
        .foregroundStyle(.white)
        .buttonStyle(.borderless)
        .cornerRadius(20)
    }
}
