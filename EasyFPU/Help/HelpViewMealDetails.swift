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
            Text("This view displays the details of your meal in a way that you can easily send a screenshot to e.g. your kid. It displays the same information as the Meal Summary on the Food List view, plus - on request - the details about all selected food items.").padding()
            
            Text("For each of the three carbs type, the same set of information is displayed:").padding()
            
            Group {
                Text("- How much? - The total amount of carbs of that type").padding([.leading, .trailing])
                Text("- When? - The time when these carbs start to impact your blood glucose level").padding([.leading, .trailing])
                Text("- How long? - The time interval during which these carbs will be absorbed, impacting your blood glucose level").padding([.leading, .trailing])
            }
            
            HStack {
                Image(systemName: "square.and.arrow.up").imageScale(.large)
                Text("You may export the extended carbs to the Apple Health app")
            }.padding()
            
            Text("Below the total meal details, a list of the individual food items considered in the calculation is displayed, containing the same information as above.").padding()
        }
    }
}
