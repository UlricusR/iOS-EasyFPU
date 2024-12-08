//
//  ComposedFoodItemDetailsView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 30/07/2023.
//  Copyright © 2023 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct ComposedFoodItemDetailsView: View {
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
        VStack {
            VStack(alignment: .leading) {
                //
                // Composed Meal
                //
                
                // Amount and name
                HStack {
                    Text(String(composedFoodItem.amount))
                        .accessibilityIdentifierLeaf("AmountValue")
                    Text("g")
                        .accessibilityIdentifierLeaf("AmountUnit")
                    Text(NSLocalizedString(composedFoodItem.name, comment: ""))
                        .accessibilityIdentifierLeaf("FoodItemName")
                }
                .foregroundStyle(Color.accentColor)
                
                // Calories
                HStack {
                    Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: composedFoodItem.calories))!)
                        .accessibilityIdentifierLeaf("CaloriesValue")
                    Text("kcal")
                        .accessibilityIdentifierLeaf("CaloriesUnit")
                }.font(.caption)
                
                // Sugars
                if userSettings.treatSugarsSeparately {
                    HStack {
                        Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: composedFoodItem.getSugars(treatSugarsSeparately: userSettings.treatSugarsSeparately)))!)
                            .accessibilityIdentifierLeaf("SugarsValue")
                        Text("g Sugars")
                            .accessibilityIdentifierLeaf("SugarsUnit")
                        Text("in")
                        Text(String(userSettings.absorptionTimeSugarsDelayInMinutes + userSettings.mealDelayInMinutes))
                            .accessibilityIdentifierLeaf("SugarsDelayValue")
                        Text("min for")
                            .accessibilityIdentifierLeaf("SugarsDelayUnit")
                        Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: userSettings.absorptionTimeSugarsDurationInHours))!)
                            .accessibilityIdentifierLeaf("SugarsTimeValue")
                        Text("h")
                            .accessibilityIdentifierLeaf("SugarsTimeUnit")
                    }.font(.caption)
                }
                
                // Regular Carbs
                HStack {
                    Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: composedFoodItem.getRegularCarbs(treatSugarsSeparately: userSettings.treatSugarsSeparately)))!)
                        .accessibilityIdentifierLeaf("CarbsValue")
                    Text("g Regular Carbs")
                        .accessibilityIdentifierLeaf("CarbsUnit")
                    Text("in")
                    Text(String(userSettings.absorptionTimeCarbsDelayInMinutes + userSettings.mealDelayInMinutes))
                        .accessibilityIdentifierLeaf("CarbsDelayValue")
                    Text("min for")
                        .accessibilityIdentifierLeaf("CarbsDelayUnit")
                    Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: userSettings.absorptionTimeCarbsDurationInHours))!)
                        .accessibilityIdentifierLeaf("CarbsTimeValue")
                    Text("h")
                        .accessibilityIdentifierLeaf("CarbsTimeUnit")
                }.font(.caption)
                
                // Extended carbs
                HStack {
                    Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: composedFoodItem.fpus.fpu))!)
                        .accessibilityIdentifierLeaf("FPUValue")
                    Text("FPU")
                        .accessibilityIdentifierLeaf("FPUUnit")
                    Text("/")
                    Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: composedFoodItem.fpus.getExtendedCarbs()))!)
                        .accessibilityIdentifierLeaf("ECarbsValue")
                    Text("g Extended Carbs")
                        .accessibilityIdentifierLeaf("ECarbsUnit")
                    Text("in")
                    Text(String(userSettings.absorptionTimeECarbsDelayInMinutes + userSettings.mealDelayInMinutes))
                        .accessibilityIdentifierLeaf("ECarbsDelayValue")
                    Text("min for")
                        .accessibilityIdentifierLeaf("ECarbsDelayUnit")
                    Text(self.absorptionTimeAsString)
                        .accessibilityIdentifierLeaf("ECarbsAbsorptionTimeValue")
                    Text("h")
                        .accessibilityIdentifierLeaf("ECarbsAbsorptionTimeUnit")
                }.font(.caption)
            }.padding()
            
            List {
                // Food items
                ForEach(composedFoodItem.foodItemVMs, id: \.self) { foodItem in
                    ComposedFoodItemView(foodItem: foodItem, absorptionScheme: self.absorptionScheme, fontSizeDetails: .caption, foregroundStyleName: Color.accentColor)
                        .accessibilityIdentifierBranch(String(foodItem.name.prefix(10)))
                }
            }
        }
        .navigationTitle(Text("Total meal"))
    }
}
