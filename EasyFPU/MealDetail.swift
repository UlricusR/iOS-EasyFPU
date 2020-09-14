//
//  MealDetail.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 23.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct MealDetail: View {
    @ObservedObject var absorptionScheme: AbsorptionScheme
    var meal: MealViewModel
    private let helpScreen = HelpScreen.mealDetails
    @State var activeSheet = ActiveMealDetailSheet.help
    @State private var showingSheet = false
    var absorptionTimeAsString: String {
        if meal.fpus.getAbsorptionTime(absorptionScheme: absorptionScheme) != nil {
            return NumberFormatter().string(from: NSNumber(value: meal.fpus.getAbsorptionTime(absorptionScheme: absorptionScheme)!))!
        } else {
            return "..."
        }
    }
    
    var body: some View {
        NavigationView {
            VStack() {
                VStack() {
                    HStack {
                        Text(NumberFormatter().string(from: NSNumber(value: self.meal.amount))!)
                        Text("g")
                        Text("Amount consumed")
                    }
                    
                    HStack {
                        Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: self.meal.calories))!)
                        Text("kcal")
                        
                        Text("|")
                        
                        Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: self.meal.carbs))!)
                        Text("g Carbs")
                    }
                    
                    HStack {
                        Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: self.meal.fpus.fpu))!)
                        Text("FPU")
                        
                        Text("|")
                        
                        Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: self.meal.fpus.getExtendedCarbs()))!)
                        Text("g Extended Carbs")
                    }
                    
                    HStack {
                        Text(self.absorptionTimeAsString)
                        Text("h Absorption Time")
                        
                        Text("|")
                        
                        Text(DataHelper.doubleFormatter(numberOfDigits: 0).string(from: NSNumber(value: UserSettings.shared.absorptionTimeLongDelay))!)
                        Text("min")
                        Text("Delay")
                    }
                }.padding().foregroundColor(.red)
                
                if HealthDataHelper.healthKitIsAvailable() {
                    Button(action: {
                        self.activeSheet = .exportToHealth
                        self.showingSheet = true
                    }) {
                        Image(systemName: "square.and.arrow.up").imageScale(.large)
                        Text("Export to Apple Health")
                    }.padding([.leading, .trailing, .bottom])
                }
                
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
