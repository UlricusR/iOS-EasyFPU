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
            Text("This view displays the details of your meal in a way that you can easily send a screenshot to e.g. your kid.").padding()
            
            Text("With the + and - buttons, you can set the time interval until your meal will start, which is normally used for setting the time between injecting insulin and starting your meal.").padding()
            
            Group {
                HStack {
                    Image(systemName: "cube.fill").foregroundColor(Color(ComposedFoodItemSugarsView.color))
                    Text("Carbs from sugars are usually the fastest to be absorbed. You can set the parameters in the Absorption Scheme settings dialog.")
                }.padding()
                
                HStack {
                    Image(systemName: "hare.fill").foregroundColor(Color(ComposedFoodItemCarbsView.color))
                    Text("Regular carbs are absorbed slower than sugars. You may as well modify the parameters in the Absorption Scheme settings dialog.")
                }.padding()
                
                HStack {
                    Image(systemName: "tortoise.fill").foregroundColor(Color(ComposedFoodItemECarbsView.color))
                    Text("Extended carbs, aka. e-Carbs or Fake Carbs, do not stem from carbs, but from fat and proteins. That's why their absorption can take very long and starts late.")
                }.padding()
                
                Text("Tapping 'Clear' will clear your meal, i.e. remove all food items and reset the time period the meal will start in to zero.")
                .padding()
                
                HStack {
                    Image(systemName: "square.and.arrow.up").foregroundColor(.accentColor)
                    Text("Tapping the export button in the summary will open the Meal Export view.")
                }.padding()
                
                Text("Tapping 'More Details' will open the Meal Details view.")
                .padding()
            }
        }
    }
}
