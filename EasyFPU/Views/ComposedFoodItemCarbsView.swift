//
//  MealCarbsView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 22.09.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct ComposedFoodItemCarbsView: View {
    @ObservedObject var composedFoodItem: ComposedFoodItem
    @ObservedObject var userSettings = UserSettings.shared
    var regularCarbsTimeAsString: String {
        let time = Date().addingTimeInterval(TimeInterval((userSettings.absorptionTimeCarbsDelayInMinutes + userSettings.mealDelayInMinutes) * 60))
        return HealthExportCarbsPreviewChart.timeStyle.string(from: time)
    }
    static let color = UIColor.green
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Image(systemName: "hare.fill")
                    .accessibilityIdentifierLeaf("Symbol")
                Text("Regular Carbs").font(.headline).fontWeight(.bold).lineLimit(2)
                    .accessibilityIdentifierLeaf("Title")
            }
            .multilineTextAlignment(.center)
            .foregroundStyle(Color(ComposedFoodItemCarbsView.color))
            
            HStack {
                VStack(alignment: .trailing) { // Questions
                    Text("How much?").accessibilityIdentifierLeaf("AmountLabel")
                    Text("When?").accessibilityIdentifierLeaf("Timeabel")
                    Text("How long?").accessibilityIdentifierLeaf("DurationLabel")
                }.foregroundStyle(Color(ComposedFoodItemCarbsView.color))
                
                VStack(alignment: .leading) { // Answers
                    HStack {
                        Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: ComposedFoodItem.getRegularCarbs(composedFoodItem: composedFoodItem, treatSugarsSeparately: userSettings.treatSugarsSeparately)))!)
                            .accessibilityIdentifierLeaf("AmountValue")
                        Text("g Carbs")
                            .accessibilityIdentifierLeaf("AmountUnit")
                    }
                    HStack {
                        Text("In")
                        Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: userSettings.absorptionTimeCarbsDelayInMinutes + userSettings.mealDelayInMinutes))!)
                            .accessibilityIdentifierLeaf("PauseValue")
                        Text("min at")
                        Text(self.regularCarbsTimeAsString)
                            .accessibilityIdentifierLeaf("TimeValue")
                    }
                    HStack {
                        Text("For")
                        Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: UserSettings.shared.absorptionTimeCarbsDurationInHours))!)
                            .accessibilityIdentifierLeaf("DurationValue")
                        Text("h")
                            .accessibilityIdentifierLeaf("DurationUnit")
                    }
                }
            }
        }
    }
}
