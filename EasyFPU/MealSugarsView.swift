//
//  MealSugarsView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 22.09.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct MealSugarsView: View {
    var meal: MealViewModel
    var sugarsTimeAsString: String {
        let time = Date().addingTimeInterval(TimeInterval(UserSettings.shared.absorptionTimeSugarsDelayInMinutes * 60))
        return ChartBar.timeStyle.string(from: time)
    }
    static let color = Color.red
    
    var body: some View {
        HStack {
            VStack(alignment: .center) {
                Image(systemName: "cube.fill")
                Text("Sugars").font(.headline).fontWeight(.bold).lineLimit(2)
            }
            .multilineTextAlignment(.center)
            .foregroundColor(MealSugarsView.color)
            .padding(.trailing)
            
            VStack(alignment: .trailing) { // Questions
                Text("How much?")
                Text("When?")
                Text("How long?")
            }.foregroundColor(MealSugarsView.color)
            
            VStack(alignment: .leading) { // Answers
                HStack { // How much?
                    Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: self.meal.sugars))!)
                    Text("g Carbs")
                }
                HStack {
                    Text("In")
                    Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: UserSettings.shared.absorptionTimeSugarsDelayInMinutes))!)
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
