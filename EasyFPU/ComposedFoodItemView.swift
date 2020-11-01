//
//  MealFoodItemView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 27.08.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct ComposedFoodItemView: View {
    var foodItem: FoodItemViewModel
    @ObservedObject var absorptionScheme: AbsorptionScheme
    var fontSizeName: Font?
    var fontSizeDetails: Font?
    var foregroundColorName: Color?
    var absorptionTimeAsString: String {
        if foodItem.getFPU().getAbsorptionTime(absorptionScheme: absorptionScheme) != nil {
            return NumberFormatter().string(from: NSNumber(value: foodItem.getFPU().getAbsorptionTime(absorptionScheme: absorptionScheme)!))!
        } else {
            return "..."
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            // Amount and name
            HStack {
                Text(String(foodItem.amount))
                Text("g")
                Text(foodItem.name)
            }.font(fontSizeName).foregroundColor(foregroundColorName)
            
            // Calories
            HStack {
                Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: foodItem.getCalories()))!)
                Text("kcal")
            }.font(fontSizeDetails)
            
            // Sugars
            if UserSettings.shared.treatSugarsSeparately {
                HStack {
                    Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: foodItem.getSugars(when: UserSettings.shared.treatSugarsSeparately)))!)
                    Text("g Sugars")
                    Text("in")
                    Text(String(UserSettings.shared.absorptionTimeSugarsDelayInMinutes))
                    Text("min for")
                    Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: UserSettings.shared.absorptionTimeSugarsDurationInHours))!)
                    Text("h")
                }.font(fontSizeDetails)
            }
            
            // Regular Carbs
            HStack {
                Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: foodItem.getRegularCarbs(when: UserSettings.shared.treatSugarsSeparately)))!)
                Text("g Regular Carbs")
                Text("in")
                Text(String(UserSettings.shared.absorptionTimeCarbsDelayInMinutes))
                Text("min for")
                Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: UserSettings.shared.absorptionTimeCarbsDurationInHours))!)
                Text("h")
            }.font(fontSizeDetails)
            
            // Extended carbs
            HStack {
                Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: foodItem.getFPU().fpu))!)
                Text("FPU")
                Text("/")
                Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: foodItem.getFPU().getExtendedCarbs()))!)
                Text("g Extended Carbs")
                Text("in")
                Text(String(UserSettings.shared.absorptionTimeECarbsDelayInMinutes))
                Text("min for")
                Text(self.absorptionTimeAsString)
                Text("h")
            }.font(fontSizeDetails)
        }
    }
}
