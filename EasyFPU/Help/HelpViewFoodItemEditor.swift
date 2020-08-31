//
//  HelpViewFoodItemEditor.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 31.08.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct HelpViewFoodItemEditor: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("This dialog allows you to edit a food item.").padding()
            Text("All fields are mandatory, but you may leave away typical amounts.").padding()
            Text("Be aware that 1 gram of carbs accounts for approximately 4 kcal, so the number carbs entered here multiplied by four may not exceed the total amount of energy in kcal.").padding()
            
            HStack {
                Image(systemName: "plus.circle").foregroundColor(.green)
                Text("To add a new typical amount, enter the amount and a comment in the respective fields and confirm by pressing the green Plus button.")
            }.padding()
            
            HStack {
                Image(systemName: "checkmark.circle").foregroundColor(.yellow)
                Text("To edit an existing typical amount, tap on it, modify the values as desired, and confirm by pressing the yellow Checkmark button.")
            }.padding()
            
            Text("Swipe left to remove a typical amount.").padding()
        }
    }
}
