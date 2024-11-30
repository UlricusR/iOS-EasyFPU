//
//  CustomViews.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 29.09.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct CustomTextField: View {
    var titleKey: String
    @Binding var text: String
    var keyboardType: UIKeyboardType
    
    var body: some View {
        return AnyView(TextField(NSLocalizedString(titleKey, comment: ""), text: $text).ignoresSafeArea(.keyboard, edges: .bottom).keyboardType(keyboardType))
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
