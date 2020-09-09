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
    private let helpScreen = HelpScreen.mealDetails
    @State var activeSheet = ActiveMealDetailSheet.help
    @State private var showingSheet = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
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
                        Text(FoodItemViewModel.doubleFormatter(numberOfDigits: 0).string(from: NSNumber(value: UserSettings.getValue(for: UserSettings.UserDefaultsDoubleKey.absorptionTimeLongDelay) ?? AbsorptionSchemeViewModel.absorptionTimeLongDelayDefault))!)
                        Text("min")
                        Text("Delay of Extended Carbs")
                    }.padding(.top)
                }.padding().foregroundColor(.red)
                
                Button(action: {
                    self.activeSheet = .exportToHealth
                    self.showingSheet = true
                }) {
                    Image(systemName: "square.and.arrow.up").imageScale(.large)
                    Text("Export to Apple Health")
                }.padding()
                
                List {
                    Text("Included food items:").font(.headline)
                    ForEach(meal.foodItems, id: \.self) { foodItem in
                        MealItemView(foodItem: foodItem, absorptionScheme: self.absorptionScheme, fontSizeDetails: .caption, foregroundColorName: Color.accentColor)
                    }
                }
                
                Spacer()
            }
            .navigationBarTitle(NSLocalizedString(self.meal.name, comment: ""))
            .navigationBarItems(trailing: Button(action: {
                self.activeSheet = .help
                self.showingSheet = true
            }) {
                Image(systemName: "questionmark.circle").imageScale(.large)
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: self.$showingSheet) {
            MealDetailSheet(activeSheet: self.activeSheet, isPresented: self.$showingSheet, meal: self.meal, absorptionScheme: self.absorptionScheme, helpScreen: self.helpScreen)
        }
    }
}
