//
//  HelpViewFoodList.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 31.08.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct HelpViewProductsList: View {
    var body: some View {
        VStack(alignment: .leading) {
            // The product selection list
            Text("The dishes list contains all dishes available to compose a meal. Here you select which dishes to include in your meal. If the list is empty, you need to first add dishes.").padding()
            
            Text("As soon as your dishes list contains one or more dishes, you can go ahead and create a meal. To do so, tap once on the respective dish. This will open the screen to select the amount.").padding()
            
            Text("Once done adding all dishes, hit the yellow Finished button to return to your meal overview. You can always come back to edit or add dishes.").padding()
            
            HStack {
                Image(systemName: "plus.circle").foregroundStyle(.gray)
                Text("Indicates that the dish is available for being added to your meal.")
            }.padding()
			
            HStack {
                Image(systemName: "xmark.circle").foregroundStyle(.red)
                Text("Indicates that the dish has been selected and is included in your meal. Tapping it again will remove it from your meal.")
            }.padding()
            
            Text("Menu bar").font(.headline).padding()
			
            HStack {
                Image(systemName: "plus.circle").foregroundStyle(.green).imageScale(.large)
                Text("Adds new dishes to the list. This is not selecting it, this needs to be done separately.")
            }.padding()
            
            HStack {
				Image(systemName: "xmark.circle").foregroundStyle(.red).imageScale(.large)
				Text("The red X at the top of the screen lets you remove all selected dishes at once.")
            }.padding()
            
            HStack {
                Image(systemName: "star").foregroundStyle(Color.blue).imageScale(.large)
                Text("Filters by your favorite dishes.")
            }.padding()
        }
    }
}
