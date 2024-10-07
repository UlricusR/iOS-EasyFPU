//
//  HelpFoodItemComposer.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 02.11.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct HelpFoodItemComposer: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("This view summarizes your recipe. It shows the selected ingredients and lets you edit the following details:").padding()
            
            Text("- The name of the composed product / recipe").padding(.horizontal)
            Text("- The total weight of the final product").padding(.horizontal)
            Text("- Whether or not the recipe is a favorite").padding(.horizontal)
            Text("- The number of portions").padding(.horizontal)
			
			HStack {
					Image(systemName: "checkmark.circle.fill")
					Text("Saves your recipe to the recipe list and creates a new dish in the list of dishes.")
			}.padding()
			
			HStack {
					Image(systemName: "pencil.circle")
					Text("Lets you add and edit the ingredients included in the dish.")
			}.padding()
        }
    }
}
