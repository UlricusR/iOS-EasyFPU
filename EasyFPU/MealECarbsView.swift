//
//  MealECarbsView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 22.09.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct MealECarbsView: View {
    var meal: MealViewModel
    var absorptionScheme: AbsorptionScheme
    var absorptionTimeAsString: String {
        if meal.fpus.getAbsorptionTime(absorptionScheme: absorptionScheme) != nil {
            return NumberFormatter().string(from: NSNumber(value: meal.fpus.getAbsorptionTime(absorptionScheme: absorptionScheme)!))!
        } else {
            return "..."
        }
    }
    @ObservedObject var userSettings = UserSettings.shared
    var extendedCarbsTimeAsString: String {
        let time = Date().addingTimeInterval(TimeInterval((userSettings.absorptionTimeECarbsDelayInMinutes + userSettings.mealDelayInMinutes) * 60))
        return ChartBar.timeStyle.string(from: time)
    }
    static var color = UIColor.blue
    
    var body: some View {
        HStack {
            VStack(alignment: .center) {
                Image(systemName: "tortoise.fill")
                Text("e-Carbs").font(.headline).fontWeight(.bold).lineLimit(2)
            }
            .multilineTextAlignment(.center)
            .foregroundColor(Color(MealECarbsView.color))
            .padding(.trailing)
            
            VStack(alignment: .trailing) { // Questions
                Text("How much?")
                Text("When?")
                Text("How long?")
            }.foregroundColor(Color(MealECarbsView.color))
            
            VStack(alignment: .leading) { // Answers
                HStack {
                    Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: self.meal.fpus.getExtendedCarbs()))!)
                    Text("g Carbs")
                }
                HStack {
                    Text("In")
                    Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: userSettings.absorptionTimeECarbsDelayInMinutes + userSettings.mealDelayInMinutes))!)
                    Text("min at")
                    Text(self.extendedCarbsTimeAsString)
                }
                HStack {
                    Text("For")
                    Text(self.absorptionTimeAsString)
                    Text("h")
                }
            }
        }
    }
}
