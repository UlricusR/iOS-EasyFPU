//
//  MealCarbsView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 22.09.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct MealCarbsView: View {
    var meal: MealViewModel
    var regularCarbsTimeAsString: String {
        let time = Date().addingTimeInterval(TimeInterval(UserSettings.shared.absorptionTimeCarbsDelayInMinutes * 60))
        return ChartBar.timeStyle.string(from: time)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .center) {
                Image(systemName: "hare.fill")
                Text("Regular Carbs").font(.headline).fontWeight(.bold).lineLimit(2)
            }
            .multilineTextAlignment(.center)
            .foregroundColor(.green)
            .padding(.trailing)
            
            VStack(alignment: .trailing) { // Questions
                Text("How much?")
                Text("When?")
                Text("How long?")
            }.foregroundColor(.green)
            
            VStack(alignment: .leading) { // Answers
                HStack {
                    Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: self.meal.getRegularCarbs()))!)
                    Text("g Carbs")
                }
                HStack {
                    Text("In")
                    Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: UserSettings.shared.absorptionTimeCarbsDelayInMinutes))!)
                    Text("min at")
                    Text(self.regularCarbsTimeAsString)
                }
                HStack {
                    Text("For")
                    Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: UserSettings.shared.absorptionTimeCarbsDurationInHours))!)
                    Text("h")
                }
            }
        }
    }
}
