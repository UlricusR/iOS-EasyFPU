//
//  MealSummary.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 19.09.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct MealSummaryView: View {
    @Binding var activeFoodListSheet: FoodListSheets.State?
    @ObservedObject var absorptionScheme: AbsorptionScheme
    var meal: MealViewModel
    @State private var showingSheet = false
    @State private var selectedTab: Int = 1
    private let minTranslationForSwipe: CGFloat = 50
    private let numberOfTabs: Int = 3
    
    var body: some View {
        Divider()
        
        HStack(alignment: .center) {
            Button(action: {
                meal.clear()
                UserSettings.shared.mealDelayInMinutes = 0
            }) {
                Image(systemName: "xmark.circle").foregroundColor(.red).imageScale(.large).padding([.leading, .trailing])
            }
            
            Text("Total meal").font(.headline).multilineTextAlignment(.center)
            
            Button(action: {
                activeFoodListSheet = .mealDetails
            }) {
                Image(systemName: "info.circle").imageScale(.large).foregroundColor(.accentColor).padding([.leading, .trailing])
            }
            
            if HealthDataHelper.healthKitIsAvailable() {
                Button(action: {
                    self.showingSheet = true
                }) {
                    Image(systemName: "square.and.arrow.up").imageScale(.large).foregroundColor(.accentColor)
                }
            }
        }
        
        TabView(selection: $selectedTab) {
            // Sugars if available
            if meal.getSugars(when: UserSettings.shared.treatSugarsSeparately) > 0 {
                MealSugarsView(meal: self.meal)
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
            MealCarbsView(meal: self.meal)
            .lineLimit(1)
            .tabItem {
                Image(systemName: "hare")
            }
            .tag(1)
            .highPriorityGesture(DragGesture().onEnded( {
                self.handleSwipe(translation: $0.translation.width)
            }))
            
            // Extended Carbs
            MealECarbsView(meal: self.meal, absorptionScheme: self.absorptionScheme)
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
            MealExportView(meal: self.meal, absorptionScheme: self.absorptionScheme)
        }
    }
    
    private func handleSwipe(translation: CGFloat) {
        if translation > minTranslationForSwipe && selectedTab > 0 {
            if meal.getSugars(when: UserSettings.shared.treatSugarsSeparately) == 0 {
                selectedTab = max(selectedTab - 1, 1)
            } else {
                selectedTab -= 1
            }
        } else if translation < -minTranslationForSwipe && selectedTab < numberOfTabs - 1 {
            selectedTab += 1
        }
    }
}
