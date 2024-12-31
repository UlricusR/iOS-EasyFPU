//
//  HelpViewFoodItemSelector.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 31.08.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct HelpViewFoodItemSelector: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("You may enter the consumed amount in three different ways.").padding()
            
            Text("1. You directly enter it in the text field.").padding()
            Text("2. You use the green number fields to add to the amount already displayed in the text field.").padding()
            Text("3. In case you have stored typical values for the food item, you tap on one of those typical amounts. This will overwrite any existing value.").padding()
            HStack {
                Image(systemName: "xmark.circle").foregroundStyle(.red)
                Text("Clears the entered amount.")
            }.padding()
            
            Text("You may also add a new typical amount by clicking 'Add to typical amounts'. This will take over the currently active amount from the text field and ask you for a comment.").padding()
            HStack {
                Image(systemName: "checkmark.circle.fill").foregroundStyle(.blue)
                Text("Saves the typical amount.")
            }.padding()
            Text("Use the food item editor to maintain existing typical amounts.").padding()
        }
    }
}
