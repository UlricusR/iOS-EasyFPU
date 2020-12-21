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
            // The Food List
            Text("The ingredients list contains the ingredients required to compose a recipe.").padding()
            
            HStack {
                Image(systemName: "plus.circle").foregroundColor(.green).imageScale(.large)
                Text("To add a new ingredient, tap on the large Plus button in the top right corner.")
            }.padding()
            
            Text("As soon as your ingredients list contains one or more ingredients, you can go ahead and create a recipe. To do so, tap once on the respective ingredient. This will open the screen to select the amount.").padding()
            
            HStack {
                Image(systemName: "plus.circle").foregroundColor(.green)
                Text("A green Plus icon indicates that the food item has not yet been selected.")
            }.padding()
            HStack {
                Image(systemName: "xmark.circle").foregroundColor(.red)
                Text("A red X icon indicates that the food item has been selected and is included in your meal. Tapping the the food item again will remove it from your meal.")
            }.padding()
            
            Group {
                Text("In case you have selected one or more ingredients, a hovering window will appear at the bottom of the screen, showing the summary of your recipe.").padding()
                
                HStack {
                    Image(systemName: "xmark.circle").foregroundColor(.red)
                    Text("Tapping the red X icon in the recipe summary will clear your recipe, i.e. remove all ingredients.")
                }.padding()
            }
        }
    }
}
