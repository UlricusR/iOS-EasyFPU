//
//  HelpViewFoodList.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 01.10.24.
//  Copyright © 2024 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct HelpViewRecipeList: View {
    var body: some View {
        VStack(alignment: .leading) {
            // The Recipe list
            Text("You find your recipes on the recipe list. An EasyFPU recipe consists of a number of ingredients, which make up a final dish. Example: A cake (final dish) consists of flour, milk, sugar, eggs, etc. (its ingredients).").padding()
            
            Text("To edit, duplicate, share or delete a recipe, long-press on it.").padding()
            
            Text("Menu bar").font(.headline).padding()
            
            HStack {
                Image(systemName: "plus.circle").foregroundStyle(.green).imageScale(.large)
                Text("Start creating a new recipe.")
            }.padding()
			
			HStack {
                Image(systemName: "star").foregroundStyle(.blue).imageScale(.large)
                Text("Filter your recipes by your favorites.")
            }.padding()
        }
    }
}
