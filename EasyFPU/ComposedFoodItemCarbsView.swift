//
//  MealCarbsView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 22.09.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct ComposedFoodItemCarbsView: View {
    @ObservedObject var composedFoodItem: ComposedFoodItemViewModel
    @ObservedObject var userSettings = UserSettings.shared
    var regularCarbsTimeAsString: String {
        let time = Date().addingTimeInterval(TimeInterval((userSettings.absorptionTimeCarbsDelayInMinutes + userSettings.mealDelayInMinutes) * 60))
        return HealthExportCarbsPreviewChart.timeStyle.string(from: time)
    }
    static let color = UIColor.green
    
    var body: some View {
        HStack {
            VStack(alignment: .center) {
                Image(systemName: "hare.fill")
                Text("Regular Carbs").font(.headline).fontWeight(.bold).lineLimit(2)
            }
            .multilineTextAlignment(.center)
            .foregroundColor(Color(ComposedFoodItemCarbsView.color))
            .padding(.trailing)
            
            VStack(alignment: .trailing) { // Questions
                Text("How much?")
                Text("When?")
                Text("How long?")
            }.foregroundColor(Color(ComposedFoodItemCarbsView.color))
            
            VStack(alignment: .leading) { // Answers
                HStack {
                    Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: self.composedFoodItem.getRegularCarbs(when: userSettings.treatSugarsSeparately)))!)
                    Text("g Carbs")
                }
                HStack {
                    Text("In")
                    Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: userSettings.absorptionTimeCarbsDelayInMinutes + userSettings.mealDelayInMinutes))!)
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
