//
//  MealSugarsView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 22.09.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct ComposedFoodItemSugarsView: View {
    @ObservedObject var composedFoodItem: ComposedFoodItemViewModel
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
                Text("Sugars").font(.headline).fontWeight(.bold).lineLimit(2)
            }
            .multilineTextAlignment(.center)
            .foregroundColor(Color(ComposedFoodItemSugarsView.color))
            
            HStack {
                VStack(alignment: .trailing) { // Questions
                    Text("How much?")
                    Text("When?")
                    Text("How long?")
                }.foregroundColor(Color(ComposedFoodItemSugarsView.color))
                
                VStack(alignment: .leading) { // Answers
                    HStack { // How much?
                        Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: self.composedFoodItem.getSugars(when: userSettings.treatSugarsSeparately)))!)
                        Text("g Carbs")
                    }
                    HStack {
                        Text("In")
                        Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: userSettings.absorptionTimeSugarsDelayInMinutes + userSettings.mealDelayInMinutes))!)
                        Text("min at")
                        Text(self.sugarsTimeAsString)
                    }
                    HStack {
                        Text("For")
                        Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: UserSettings.shared.absorptionTimeSugarsDurationInHours))!)
                        Text("h")
                    }
                }
            }
        }
    }
}
