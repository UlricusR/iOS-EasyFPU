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
            Text("Be aware that 1 gram of carbs accounts for approximately 4 kcal, so the number carbs entered here multiplied by four may not exceed the total amount of energy in kcal.").padding()
            Text("A good source for nutritional values (calories and carbs per 100g) is:").padding([.leading, .trailing, .top])
            Text("Link-text-to-nutritional-values").foregroundStyle(.blue)
            .padding()
            .onTapGesture {
                UIApplication.shared.open(URL(string: NSLocalizedString("Link-URL-to-nutritional-values", comment: ""))!)
            }
            
            Text("Typical amounts can be helpful to pre-define amounts of food items, which are usually consumed or required in recipes. They ease selection, as they are displayed when selecting a food item for a meal or recipe.").padding()
        }
    }
}
