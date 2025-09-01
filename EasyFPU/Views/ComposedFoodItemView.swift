//
//  MealFoodItemView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 27.08.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct ComposedFoodItemView: View {
    var ingredient: Ingredient
    @ObservedObject var absorptionScheme: AbsorptionScheme
    var fontSizeName: Font?
    var fontSizeDetails: Font?
    var foregroundStyleName: Color
    @ObservedObject var userSettings = UserSettings.shared
    var absorptionTimeAsString: String {
        if ingredient.fpus.getAbsorptionTime(absorptionScheme: absorptionScheme) != nil {
            return DataHelper.intFormatter.string(from: NSNumber(value: ingredient.fpus.getAbsorptionTime(absorptionScheme: absorptionScheme)!))!
        } else {
            return "..."
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            // Amount and name
            HStack {
                Text(String(ingredient.amount))
                    .accessibilityIdentifierLeaf("FoodItemAmountValue")
                Text("g")
                    .accessibilityIdentifierLeaf("FoodItemAmountUnit")
                Text(ingredient.name)
                    .accessibilityIdentifierLeaf("FoodItemName")
            }
            .font(fontSizeName)
            .foregroundStyle(foregroundStyleName)
            
            // Calories
            HStack {
                Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: ingredient.calories))!)
                    .accessibilityIdentifierLeaf("CaloriesValue")
                Text("kcal")
                    .accessibilityIdentifierLeaf("CaloriesUnit")
            }
            .font(fontSizeDetails)
            
            // Sugars
            if userSettings.treatSugarsSeparately {
                HStack {
                    Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: ingredient.getSugars(treatSugarsSeparately: userSettings.treatSugarsSeparately)))!)
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
                }.font(fontSizeDetails)
            }
            
            // Regular Carbs
            HStack {
                Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: ingredient.getRegularCarbs(treatSugarsSeparately: userSettings.treatSugarsSeparately)))!)
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
            }.font(fontSizeDetails)
            
            // Extended carbs
            HStack {
                Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: ingredient.fpus.fpu))!)
                    .accessibilityIdentifierLeaf("FPUValue")
                Text("FPU")
                    .accessibilityIdentifierLeaf("FPUUnit")
                Text("/")
                Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: ingredient.fpus.getExtendedCarbs()))!)
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
            }.font(fontSizeDetails)
        }
    }
}
