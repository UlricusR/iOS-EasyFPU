//
//  MealECarbsView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 22.09.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct ComposedFoodItemECarbsView: View {
    @ObservedObject var composedFoodItem: ComposedFoodItemViewModel
    var absorptionScheme: AbsorptionScheme
    var absorptionTimeAsString: String {
        if composedFoodItem.fpus.getAbsorptionTime(absorptionScheme: absorptionScheme) != nil {
            return DataHelper.intFormatter.string(from: NSNumber(value: composedFoodItem.fpus.getAbsorptionTime(absorptionScheme: absorptionScheme)!))!
        } else {
            return "..."
        }
    }
    @ObservedObject var userSettings = UserSettings.shared
    var extendedCarbsTimeAsString: String {
        let time = Date().addingTimeInterval(TimeInterval((userSettings.absorptionTimeECarbsDelayInMinutes + userSettings.mealDelayInMinutes) * 60))
        return HealthExportCarbsPreviewChart.timeStyle.string(from: time)
    }
    static var color = UIColor.blue
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Image(systemName: "tortoise.fill")
                    .accessibilityIdentifierLeaf("Symbol")
                Text("e-Carbs").font(.headline).fontWeight(.bold).lineLimit(2)
                    .accessibilityIdentifierLeaf("Title")
            }
            .multilineTextAlignment(.center)
            .foregroundStyle(Color(ComposedFoodItemECarbsView.color))
            
            HStack {
                VStack(alignment: .trailing) { // Questions
                    Text("How much?").accessibilityIdentifierLeaf("AmountLabel")
                    Text("When?").accessibilityIdentifierLeaf("TimeLabel")
                    Text("How long?").accessibilityIdentifierLeaf("DurationLabel")
                }.foregroundStyle(Color(ComposedFoodItemECarbsView.color))
                
                VStack(alignment: .leading) { // Answers
                    HStack {
                        Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: self.composedFoodItem.fpus.getExtendedCarbs()))!)
                            .accessibilityIdentifierLeaf("AmountValue")
                        Text("g Carbs")
                            .accessibilityIdentifierLeaf("AmountUnit")
                    }
                    HStack {
                        Text("In")
                        Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: userSettings.absorptionTimeECarbsDelayInMinutes + userSettings.mealDelayInMinutes))!)
                            .accessibilityIdentifierLeaf("PauseValue")
                        Text("min at")
                        Text(self.extendedCarbsTimeAsString)
                            .accessibilityIdentifierLeaf("TimeValue")
                    }
                    HStack {
                        Text("For")
                        Text(self.absorptionTimeAsString)
                            .accessibilityIdentifierLeaf("DurationValue")
                        Text("h")
                            .accessibilityIdentifierLeaf("DurationUnit")
                    }
                }
            }
        }
    }
}
