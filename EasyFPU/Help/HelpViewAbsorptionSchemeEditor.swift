//
//  HelpViewAbsorptionSchemeEditor.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 31.08.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct HelpViewAbsorptionSchemeEditor: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("The absorption scheme defines, which absorption time is proposed for a given amount of FPUs. The pre-defined absorption scheme matches today‘s recommendations from nutrition science and is as follows:").padding()
            
            Text("1 FPU (= 10g extended carbs): 3 hours absorption time").padding([.leading, .trailing])
            Text("2 FPUs (= 20g extended carbs): 4 hours absorption time").padding([.leading, .trailing])
            Text("3 FPUs (= 30g extended carbs): 5 hours absorption time").padding([.leading, .trailing])
            Text("4 FPUs (= 40g extended carbs): 6 hours absorption time").padding([.leading, .trailing])
            Text("6 FPUs (= 60g extended carbs) and more: 8 hours absorption time").padding([.leading, .trailing])
            
            Group {
                Text("The calculation logic is as follows:").padding()

                Text("Step 1: Calculation of the total calories, e.g. for 72g Chicken McNuggets (249 kcal per 100g): 72g * 249 kcal / 100g = 179 kcal").padding()

                Text("Step 2: Calculation of the calories caused by carbs (4 kcal per 1g of carbs), e.g. for 72g Chicken McNuggets (17g carbs per 100g): 72g * 17gCarbs / 100g * 4 kcal/gCarbs = 49 kcal").padding()

                Text("Step 3: Substract the calories caused by carbs from the total calories, e.g.: 179 kcal - 49 kcal = 130 kcal").padding()

                Text("Step 4: As 100 kcal represent 1 FPU, this results in 1.3 FPUs respectively 13g of extended carbs.").padding()

                Text("Step 5: The FPUs will be rounded, in our example to 1 FPU, and the absorption time will be looked up, in our example 3 hours.").padding()

                Text("Editing the absorption scheme is only recommended for advanced users, who have experience in FPUs / absorption time. The absorption scheme can always be reset to the pre-defined scheme above.").padding()
            }
        }
    }
}
