//
//  MealDetail.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 23.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct MealDetail: View {
    var absorptionScheme: AbsorptionScheme
    var meal: MealViewModel
    @State private var showingSheet = false
    private let helpScreen = HelpScreen.mealDetails
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(NSLocalizedString(self.meal.name, comment: "")).font(.headline).multilineTextAlignment(.center)
                
                Button(action: {
                    self.showingSheet = true
                }) {
                    Image(systemName: "questionmark.circle").imageScale(.large)
                }
            }.padding([.leading, .trailing, .bottom])
            
            VStack(alignment: .leading) {
                Text("Total nutritional values").font(.headline)
            
                HStack {
                    Text(NumberFormatter().string(from: NSNumber(value: self.meal.amount))!)
                    Text("g")
                    Text("Amount consumed")
                }
                
                HStack {
                    Text(FoodItemViewModel.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: self.meal.calories))!)
                    Text("kcal")
                }
                
                HStack {
                    Text(FoodItemViewModel.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: self.meal.carbs))!)
                    Text("g Carbs")
                }
                
                HStack {
                    Text(FoodItemViewModel.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: self.meal.fpus.fpu))!)
                    Text("FPU")
                }
                
                HStack {
                    Text(FoodItemViewModel.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: self.meal.fpus.getExtendedCarbs()))!)
                    Text("g Extended Carbs")
                }
                
                HStack {
                    Text(NumberFormatter().string(from: NSNumber(value: self.meal.fpus.getAbsorptionTime(absorptionScheme: self.absorptionScheme)))!)
                    Text("h Absorption Time")
                }
                
                HStack {
                    Text("Recommended delay of extended carbs:")
                    Text("1.5h")
                }.padding(.top)
            }.padding().foregroundColor(.red)
            
            List {
                Text("Included food items:").font(.headline)
                ForEach(meal.foodItems, id: \.self) { foodItem in
                    MealItemView(foodItem: foodItem, absorptionScheme: self.absorptionScheme, fontSizeDetails: .caption, foregroundColorName: Color.blue)
                }
            }
            
            Spacer()
        }
        .sheet(isPresented: self.$showingSheet) {
            HelpView(isPresented: self.$showingSheet, helpScreen: self.helpScreen)
        }
    }
}
