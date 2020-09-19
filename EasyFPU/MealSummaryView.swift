//
//  MealSummary.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 19.09.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct MealSummaryView: View {
    @ObservedObject var absorptionScheme: AbsorptionScheme
    var meal: MealViewModel
    var absorptionTimeAsString: String {
        if meal.fpus.getAbsorptionTime(absorptionScheme: absorptionScheme) != nil {
            return NumberFormatter().string(from: NSNumber(value: meal.fpus.getAbsorptionTime(absorptionScheme: absorptionScheme)!))!
        } else {
            return "..."
        }
    }
    var regularCarbsTimeAsString: String {
        let time = Date().addingTimeInterval(UserSettings.shared.absorptionTimeMediumDelay * 60)
        return ChartBar.timeStyle.string(from: time)
    }
    var extendedCarbsTimeAsString: String {
        let time = Date().addingTimeInterval(UserSettings.shared.absorptionTimeLongDelay * 60)
        return ChartBar.timeStyle.string(from: time)
    }
    
    var body: some View {
        TabView {
            // Sugars if available
            if meal.sugars > 0 {
                VStack(alignment: .leading) {
                    Text("Sugars").font(.subheadline).foregroundColor(.accentColor).fontWeight(.bold)
                    HStack {
                        Text("How much?").foregroundColor(.accentColor)
                        Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: self.meal.sugars))!)
                        Text("g")
                    }
                    HStack {
                        Text("When?").foregroundColor(.accentColor)
                        Text("Now")
                    }
                    HStack {
                        Text("How long?").foregroundColor(.accentColor)
                        Text("All at once")
                    }
                }
                .tabItem {
                    Image("sugar-35")
                }
                .tag("Sugars")
            }
            
            // Carbs
            
            VStack(alignment: .leading) {
                Text("Regular Carbs").font(.subheadline).foregroundColor(.accentColor).fontWeight(.bold)
                HStack {
                    Text("How much?").foregroundColor(.accentColor)
                    Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: self.meal.getRegularCarbs()))!)
                    Text("g")
                }
                HStack {
                    Text("When?").foregroundColor(.accentColor)
                    Text("In")
                    Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: UserSettings.shared.absorptionTimeMediumDelay))!)
                    Text("min")
                    Text("(")
                    Text(self.regularCarbsTimeAsString)
                    Text(")")
                }
                HStack {
                    Text("How long?").foregroundColor(.accentColor)
                    Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: UserSettings.shared.absorptionTimeMediumDuration))!)
                    Text("h")
                }
            }
            .tabItem {
                Image("carbohydrates-35")
            }
            .tag("Carbs")
            
            // Extended Carbs
            VStack(alignment: .leading) {
                Text("Extended Carbs").font(.subheadline).foregroundColor(.accentColor).fontWeight(.bold)
                HStack {
                    Text("How much?").foregroundColor(.accentColor)
                    Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: self.meal.fpus.getExtendedCarbs()))!)
                    Text("g")
                }
                HStack {
                    Text("When?").foregroundColor(.accentColor)
                    Text("In")
                    Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: UserSettings.shared.absorptionTimeLongDelay))!)
                    Text("min")
                    Text("(")
                    Text(self.extendedCarbsTimeAsString)
                    Text(")")
                }
                HStack {
                    Text("How long?").foregroundColor(.accentColor)
                    Text(self.absorptionTimeAsString)
                    Text("h")
                }
            }
            .tabItem {
                Image("protein-35")
            }
            .tag("e-Carbs")
        }
    }
}
