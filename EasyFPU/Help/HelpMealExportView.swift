//
//  HelpMealExportView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 08.09.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct HelpMealExportView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("You may export nutritional data to Apple Health in this view. Choose the data to be exported using the toggles.").padding()
            
            Text("The following data are available for export:").padding()
            Text("- Sugars (if set in the Absorption Scheme editor)").padding([.leading, .trailing])
            Text("- Regular Carbs").padding([.leading, .trailing])
            Text("- Extended Carbs").padding([.leading, .trailing])
            Text("- Total Meal Calories").padding([.leading, .trailing, .bottom])
            
            Text("With the + and - buttons, you can set the time interval until your meal will start, which is normally used for setting the time between injecting insulin and starting your meal.").padding()
            
            Group {
                Text("Important information for Loop users:").font(.headline).padding()
                Text("If you want Loop to consider these carbs, make sure that it is allowed to read carbs from Apple Health in the Health settings.").padding([.leading, .trailing, .bottom])
            }
            
            Group {
                Text("How are the Extended Carbs exported?").font(.headline).padding()
                Text("- The number of e-carb entries is determined by dividing the absorption time (e.g. 5 hours) by the interval (e.g. 10 minutes, see Absorption Scheme view), i.e. 5 hours / 10 minutes = 30").padding([.leading, .trailing])
                Text("- The e-carbs amount per entry is determined by dividing the meal's e-carbs (e.g. 60 g) by the number of e-carb entries (e.g. 30), i.e. 60 g / 30 = 2 g").padding([.leading, .trailing])
                Text("- For each of these e-carb entries, an Apple Health record is created and exported to Apple Health with, starting at the current time plus the configured delay (default: 90 minutes; see Absorption Scheme view) and with the configured time interval (default: 10 minutes; see Absorption Scheme view)").padding([.leading, .trailing, .bottom])
                Text("Similar calculations are done for sugars and regular carbs.").padding()
                Text("The graph visualizes how these data are exported.").padding()
                Text("Before the actual export happens, you will be prompted for authentication for safety reasons, as the exported data may influence the insulin amount delivered by your Loop system.").padding()
            }
        }
    }
}
