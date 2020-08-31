//
//  HelpViewMealDetails.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 31.08.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct HelpViewMealDetails: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("This view displays the details of your meal.").padding()
            
            Text("In the upper part, printed in red, you see the nutritional values of the total meal. This includes:").padding().foregroundColor(.red)
            
            Text("- The total amount consumed in grams").padding([.leading, .trailing])
            Text("- The total energy consumed in kcal").padding([.leading, .trailing])
            Text("- The total amount of carbs consumed in grams").padding([.leading, .trailing])
            Text("- The amount of Food Protein Units").padding([.leading, .trailing])
            Text("- The corresponding amount of extended carbs in grams").padding([.leading, .trailing])
            Text("- The corresponding absorption time").padding([.leading, .trailing])
            
            Text("Below the total meal details, a list of the individual food items considered in the calculation is displayed, containing the same information as above.").padding()
        }
    }
}
