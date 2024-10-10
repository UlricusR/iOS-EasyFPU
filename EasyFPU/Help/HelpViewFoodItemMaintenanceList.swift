//
//  HelpViewFoodList.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 31.08.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct HelpViewFoodItemMaintenanceList: View {
    var body: some View {
        VStack(alignment: .leading) {
            // The food item maintenance list
            Text("Here you maintain your dishes or ingredients.").padding()
            
            Text("To edit, duplicate, share, move or delete a dish or ingredient, swipe left or right.").padding()
            
            Text("Menu bar").font(.headline).padding()
            
            HStack {
                Image(systemName: "plus.circle").foregroundStyle(.green)
                Text("Adds a new dish or ingredient to the list.")
            }.padding()
            
			HStack {
                Image(systemName: "star").foregroundStyle(Color.blue).imageScale(.large)
                Text("Filters by favorite dishes or ingredients.")
            }.padding()
        }
    }
}
