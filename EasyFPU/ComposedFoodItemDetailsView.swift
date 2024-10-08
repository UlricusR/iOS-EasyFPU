//
//  ComposedFoodItemDetailsView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 30/07/2023.
//  Copyright © 2023 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct ComposedFoodItemDetailsView: View {
    @Environment(\.presentationMode) var presentation
    @ObservedObject var absorptionScheme: AbsorptionScheme
    @ObservedObject var composedFoodItem: ComposedFoodItemViewModel
    @ObservedObject var userSettings = UserSettings.shared
    
    var absorptionTimeAsString: String {
        if composedFoodItem.fpus.getAbsorptionTime(absorptionScheme: absorptionScheme) != nil {
            return DataHelper.intFormatter.string(from: NSNumber(value: composedFoodItem.fpus.getAbsorptionTime(absorptionScheme: absorptionScheme)!))!
        } else {
            return "..."
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack(alignment: .leading) {
                    //
                    // Composed Meal
                    //
                    
                    // Amount and name
                    HStack {
                        Text(String(composedFoodItem.amount))
                        Text("g")
                        Text(NSLocalizedString(composedFoodItem.name, comment: ""))
                    }.foregroundStyle(Color.accentColor)
                    
                    // Calories
                    HStack {
                        Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: composedFoodItem.calories))!)
                        Text("kcal")
                    }.font(.caption)
                    
                    // Sugars
                    if userSettings.treatSugarsSeparately {
                        HStack {
                            Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: composedFoodItem.getSugars(when: userSettings.treatSugarsSeparately)))!)
                            Text("g Sugars")
                            Text("in")
                            Text(String(userSettings.absorptionTimeSugarsDelayInMinutes + userSettings.mealDelayInMinutes))
                            Text("min for")
                            Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: userSettings.absorptionTimeSugarsDurationInHours))!)
                            Text("h")
                        }.font(.caption)
                    }
                    
                    // Regular Carbs
                    HStack {
                        Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: composedFoodItem.getRegularCarbs(when: userSettings.treatSugarsSeparately)))!)
                        Text("g Regular Carbs")
                        Text("in")
                        Text(String(userSettings.absorptionTimeCarbsDelayInMinutes + userSettings.mealDelayInMinutes))
                        Text("min for")
                        Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: userSettings.absorptionTimeCarbsDurationInHours))!)
                        Text("h")
                    }.font(.caption)
                    
                    // Extended carbs
                    HStack {
                        Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: composedFoodItem.fpus.fpu))!)
                        Text("FPU")
                        Text("/")
                        Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: composedFoodItem.fpus.getExtendedCarbs()))!)
                        Text("g Extended Carbs")
                        Text("in")
                        Text(String(userSettings.absorptionTimeECarbsDelayInMinutes + userSettings.mealDelayInMinutes))
                        Text("min for")
                        Text(self.absorptionTimeAsString)
                        Text("h")
                    }.font(.caption)
                }.padding()
                
                List {
                    // Food items
                    ForEach(composedFoodItem.foodItems, id: \.self) { foodItem in
                        ComposedFoodItemView(foodItem: foodItem, absorptionScheme: self.absorptionScheme, fontSizeDetails: .caption, foregroundStyleName: Color.accentColor)
                    }
                }
            }
            .navigationBarTitle(Text(self.composedFoodItem.name))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentation.wrappedValue.dismiss()
                    }) {
                        Text("Close")
                    }
                }
            }
        }
    }
}
