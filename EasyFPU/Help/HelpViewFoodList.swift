//
//  HelpViewFoodList.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 31.08.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct HelpViewFoodList: View {
    var body: some View {
        VStack(alignment: .leading) {
            // The Food List
            Text("The food list is the main screen of the app. It automatically appears when opening the app the first time, after you accepted the disclaimer.").padding()
            Text("The food list is empty on purpose when first opening the app, as everybody prefers different FPU relevant food.").padding()
            
            HStack {
                Image(systemName: "plus.circle").foregroundColor(.green).imageScale(.large)
                Text("To add a new food item, tap on the large Plus button in the top right corner to add a new food item.")
            }.padding()
            
            Text("As soon as your food list contains one or more food items, you can go ahead and create a meal. To do so, tap once on the respective food item. This will open the screen to select the amount consumed.").padding()
            
            HStack {
                Image(systemName: "plus.circle").foregroundColor(.green)
                Text("A green Plus icon indicates that the food item has not yet been selected.")
            }.padding()
            HStack {
                Image(systemName: "xmark.circle").foregroundColor(.red)
                Text("A red X icon indicates that the food item has been selected and is included in your meal. Tapping the the food item again will remove it from your meal.")
            }.padding()
            
            Text("In case you have selected one or more food items, the most important nutritional values of the total meal will be summarized in red on the bottom of the screen.").padding()
            
            HStack {
                Image(systemName: "square.and.arrow.up").foregroundColor(.accentColor)
                Text("Tapping the export button in the summary will open the Meal Export view.")
            }.padding()
            
            HStack {
                Image(systemName: "info.circle").foregroundColor(.accentColor)
                Text("Tapping the info icon in the summary will open the Meal Details view.")
            }.padding()
        }
    }
}
