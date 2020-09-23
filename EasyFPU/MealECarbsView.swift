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
    var extendedCarbsTimeAsString: String {
        let time = Date().addingTimeInterval(TimeInterval(UserSettings.shared.absorptionTimeECarbsDelayInMinutes * 60))
        return ChartBar.timeStyle.string(from: time)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .center) {
                Image(systemName: "tortoise.fill")
                Text("e-Carbs").font(.headline).fontWeight(.bold).lineLimit(2)
            }
            .multilineTextAlignment(.center)
            .foregroundColor(.blue)
            .padding(.trailing)
            
            VStack(alignment: .trailing) { // Questions
                Text("How much?")
                Text("When?")
                Text("How long?")
            }.foregroundColor(.blue)
            
            VStack(alignment: .leading) { // Answers
                HStack {
                    Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: self.meal.fpus.getExtendedCarbs()))!)
                    Text("g Carbs")
                }
                HStack {
                    Text("In")
                    Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: UserSettings.shared.absorptionTimeECarbsDelayInMinutes))!)
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
