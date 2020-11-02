//
//  MealECarbsView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 22.09.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct ComposedFoodItemECarbsView: View {
    var composedFoodItem: ComposedFoodItemViewModel
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
        HStack {
            VStack(alignment: .center) {
                Image(systemName: "tortoise.fill")
                Text("e-Carbs").font(.headline).fontWeight(.bold).lineLimit(2)
            }
            .multilineTextAlignment(.center)
            .foregroundColor(Color(ComposedFoodItemECarbsView.color))
            .padding(.trailing)
            
            VStack(alignment: .trailing) { // Questions
                Text("How much?")
                Text("When?")
                Text("How long?")
            }.foregroundColor(Color(ComposedFoodItemECarbsView.color))
            
            VStack(alignment: .leading) { // Answers
                HStack {
                    Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: self.composedFoodItem.fpus.getExtendedCarbs()))!)
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
