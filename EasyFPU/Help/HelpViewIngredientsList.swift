//
//  HelpViewIngredientsList.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 29.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct HelpViewIngredientsList: View {
    var body: some View {
        VStack(alignment: .leading) {
            // The ingredients selection
            Text("The ingredients list contains all ingredients available to compose a recipe. Here you select which ingredients to include in your recipe. If the list is empty, you need to first add ingredients.").padding()
            
            Text("As soon as your ingredients list contains one or more ingredients, you can go ahead and create a recipe. To do so, tap once on the respective ingredient. This will open the screen to select the amount.").padding()
            
            Text("Once done adding all ingredients, hit the yellow Finished button to return to your recipe overview. You can always come back to edit or add ingredients.").padding()
            
            HStack {
                Image(systemName: "plus.circle").foregroundStyle(.green)
                Text("Adds new ingredients to the list. This is not selecting it, this needs to be done separately.")
            }.padding()
            
            HStack {
                Image(systemName: "plus.circle").foregroundStyle(.gray)
                Text("Indicates that the ingredient is available for being added to your recipe.")
            }.padding()
			
            HStack {
                Image(systemName: "xmark.circle").foregroundStyle(.red)
                Text("Indicates that the ingredient has been selected and is included in your recipe. Tapping it again will remove it from your recipe.")
            }.padding()
        }
    }
}
