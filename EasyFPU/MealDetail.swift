//
//  MealDetail.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 23.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct MealDetail: View {
    @Binding var isPresented: Bool
    var absorptionScheme: AbsorptionScheme
    var meal: MealViewModel
    @State private var showingSheet = false
    private let helpScreen = HelpScreen.mealDetails
    
    var body: some View {
        NavigationView {
            VStack {
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
                }.padding().foregroundColor(.red)
                
                List {
                    Text("Included food items:").font(.headline)
                    ForEach(meal.foodItems, id: \.self) { foodItem in
                        MealItemView(foodItem: foodItem, absorptionScheme: self.absorptionScheme, fontSizeDetails: .caption, foregroundColorName: Color.blue)
                    }
                }
                
                Spacer()
            }
            .navigationBarTitle(NSLocalizedString(self.meal.name, comment: ""))
            .navigationBarItems(
                leading: Button(action: {
                    self.showingSheet = true
                }) {
                    Image(systemName: "questionmark.circle").imageScale(.large)
                },
                
                trailing: Button(action: {
                    self.isPresented = false
                }) {
                    Text("Done")
                }
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: self.$showingSheet) {
            HelpView(isPresented: self.$showingSheet, helpScreen: self.helpScreen)
        }
    }
}
