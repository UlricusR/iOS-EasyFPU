//
//  MealSugarsView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 22.09.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct ComposedFoodItemSugarsView: View {
    @ObservedObject var composedFoodItem: ComposedFoodItem
    @ObservedObject var userSettings = UserSettings.shared
    var sugarsTimeAsString: String {
        let time = Date().addingTimeInterval(TimeInterval((userSettings.absorptionTimeSugarsDelayInMinutes + userSettings.mealDelayInMinutes) * 60))
        return HealthExportCarbsPreviewChart.timeStyle.string(from: time)
    }
    static let color = UIColor.red
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Image(systemName: "cube.fill")
                    .accessibilityIdentifierLeaf("Symbol")
                Text("Sugars").font(.headline).fontWeight(.bold).lineLimit(2)
                    .accessibilityIdentifierLeaf("Title")
            }
            .multilineTextAlignment(.center)
            .foregroundStyle(Color(ComposedFoodItemSugarsView.color))
            
            HStack {
                VStack(alignment: .trailing) { // Questions
                    Text("How much?").accessibilityIdentifierLeaf("AmountLabel")
                    Text("When?").accessibilityIdentifierLeaf("TimeLabel")
                    Text("How long?").accessibilityIdentifierLeaf("DurationLabel")
                }.foregroundStyle(Color(ComposedFoodItemSugarsView.color))
                
                VStack(alignment: .leading) { // Answers
                    HStack { // How much?
                        Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: ComposedFoodItem.getSugars(composedFoodItem: composedFoodItem, treatSugarsSeparately: userSettings.treatSugarsSeparately)))!)
                            .accessibilityIdentifierLeaf("AmountValue")
                        Text("g Carbs").accessibilityIdentifierLeaf("AmountUnit")
                    }
                    HStack {
                        Text("In")
                        Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: userSettings.absorptionTimeSugarsDelayInMinutes + userSettings.mealDelayInMinutes))!)
                            .accessibilityIdentifierLeaf("PauseValue")
                        Text("min at")
                        Text(self.sugarsTimeAsString)
                            .accessibilityIdentifierLeaf("TimeValue")
                    }
                    HStack {
                        Text("For")
                        Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: UserSettings.shared.absorptionTimeSugarsDurationInHours))!)
                            .accessibilityIdentifierLeaf("DurationValue")
                        Text("h")
                            .accessibilityIdentifierLeaf("DurationUnit")
                    }
                }
            }
        }
    }
}
