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
    
    @State private var showingSheet = false
    @State private var selectedTab: Int = 1
    private let minTranslationForSwipe: CGFloat = 50
    private let numberOfTabs: Int = 3
    
    var body: some View {
        Divider()
        
        HStack(alignment: .center) {
            Text("Total meal").font(.headline).multilineTextAlignment(.center)
            NavigationLink(destination: MealDetail(absorptionScheme: self.absorptionScheme, meal: self.meal)) {
                Image(systemName: "info.circle").imageScale(.large).foregroundColor(.accentColor).padding([.leading, .trailing])
            }
            Button(action: {
                self.showingSheet = true
            }) {
                Image(systemName: "square.and.arrow.up").imageScale(.large).foregroundColor(.accentColor)
            }
        }
        
        TabView(selection: $selectedTab) {
            // Sugars if available
            if meal.sugars > 0 {
                HStack {
                    VStack(alignment: .center) {
                        Image(systemName: "cube.fill")
                        Text("Sugars").font(.headline).fontWeight(.bold).lineLimit(2)
                    }
                    .multilineTextAlignment(.center)
                    .foregroundColor(.red)
                    .padding(.trailing)
                    
                    VStack(alignment: .trailing) { // Questions
                        Text("How much?")
                        Text("When?")
                        Text("How long?")
                    }.foregroundColor(.red)
                    
                    VStack(alignment: .leading) { // Answers
                        HStack { // How much?
                            Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: self.meal.sugars))!)
                            Text("g")
                        }
                        Text("Now") // When?
                        Text("All at once") // How long?
                    }
                }
                .lineLimit(1)
                .tabItem {
                    Image(systemName: "cube")
                }
                .tag(0)
                .highPriorityGesture(DragGesture().onEnded( {
                    self.handleSwipe(translation: $0.translation.width)
                }))
            }
            
            // Carbs
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
                        Text("g")
                    }
                    HStack {
                        Text("In")
                        Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: UserSettings.shared.absorptionTimeMediumDelay))!)
                        Text("min")
                        Text("-")
                        Text(self.regularCarbsTimeAsString)
                    }
                    HStack {
                        Text("For")
                        Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: UserSettings.shared.absorptionTimeMediumDuration))!)
                        Text("h")
                    }
                }
            }
            .lineLimit(1)
            .tabItem {
                Image(systemName: "hare")
            }
            .tag(1)
            .highPriorityGesture(DragGesture().onEnded( {
                self.handleSwipe(translation: $0.translation.width)
            }))
            
            // Extended Carbs
            HStack {
                VStack(alignment: .center) {
                    Image(systemName: "tortoise.fill")
                    Text("Extended Carbs").font(.headline).fontWeight(.bold).lineLimit(2)
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
                        Text("g")
                    }
                    HStack {
                        Text("In")
                        Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: UserSettings.shared.absorptionTimeLongDelay))!)
                        Text("min")
                        Text("-")
                        Text(self.extendedCarbsTimeAsString)
                    }
                    HStack {
                        Text("For")
                        Text(self.absorptionTimeAsString)
                        Text("h")
                    }
                }
            }
            .lineLimit(1)
            .tabItem {
                Image(systemName: "tortoise")
            }
            .tag(2)
            .highPriorityGesture(DragGesture().onEnded( {
                self.handleSwipe(translation: $0.translation.width)
            }))
        }
        .frame(height: 120)
        .padding([.leading, .trailing])
        .sheet(isPresented: self.$showingSheet) {
            MealExportView(isPresented: self.$showingSheet, meal: self.meal, absorptionScheme: self.absorptionScheme)
        }
    }
    
    private func handleSwipe(translation: CGFloat) {
        if translation > minTranslationForSwipe && selectedTab > 0 {
            if meal.sugars == 0 {
                selectedTab = max(selectedTab - 1, 1)
            } else {
                selectedTab -= 1
            }
        } else if translation < -minTranslationForSwipe && selectedTab < numberOfTabs - 1 {
            selectedTab += 1
        }
    }
}
