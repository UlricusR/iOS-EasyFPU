//
//  ColorModels.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 01/01/2025.
//  Copyright © 2025 Ulrich Rüth. All rights reserved.
//

import SwiftUI

//
// Button Styles
//

struct ActionButton: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    static let safeButtonSpace: CGFloat = 80
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .foregroundColor(.blue)
            .background(.yellow)
            .cornerRadius(20)
            .saturation(isEnabled ? 1 : 0)
    }
}

struct CancelButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .foregroundColor(.black)
            .background(.gray)
            .cornerRadius(20)
    }
}

//
// Custom Buttons
//

struct NumberButton<T: VariableAmountItem>: View {
    var number: Int64
    var variableAmountItem: T
    var width: CGFloat
    
    var body: some View {
        Button("+\(self.number)") {
            self.variableAmountItem.amount += self.number
        }
        .frame(width: width, height: 40, alignment: .center)
        .background(Color.green)
        .foregroundStyle(.white)
        .buttonStyle(.borderless)
        .cornerRadius(20)
    }
}

struct AmountEntryButtons<T: VariableAmountItem>: View {
    var variableAmountItem: T
    var geometry: GeometryProxy
    
    var body: some View {
        HStack {
            Spacer()
            NumberButton(number: 100, variableAmountItem: variableAmountItem, width: geometry.size.width / 7)
                .accessibilityIdentifierLeaf("Add100Button")
            NumberButton(number: 50, variableAmountItem: variableAmountItem, width: geometry.size.width / 7)
                .accessibilityIdentifierLeaf("Add50Button")
            NumberButton(number: 10, variableAmountItem: variableAmountItem, width: geometry.size.width / 7)
                .accessibilityIdentifierLeaf("Add10Button")
            NumberButton(number: 5, variableAmountItem: variableAmountItem, width: geometry.size.width / 7)
                .accessibilityIdentifierLeaf("Add5Button")
            NumberButton(number: 1, variableAmountItem: variableAmountItem, width: geometry.size.width / 7)
                .accessibilityIdentifierLeaf("Add1Button")
            Spacer()
        }
    }
}
