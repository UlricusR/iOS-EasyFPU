//
//  MealDetail.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 23.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct ComposedFoodItemEvaluationView: View {
    @Environment(\.presentationMode) var presentation
    @ObservedObject var absorptionScheme: AbsorptionScheme
    @ObservedObject var composedFoodItem: ComposedFoodItemViewModel
    @ObservedObject var userSettings = UserSettings.shared
    private let helpScreen = HelpScreen.mealDetails
    @State var activeSheet: ComposedFoodItemEvaluationViewSheets.State?
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    // The meal delay stepper
                    HStack {
                        Stepper("Delay until meal", value: $userSettings.mealDelayInMinutes, in: 0...60, step: 5)
                        Text("\(userSettings.mealDelayInMinutes)")
                        Text("min")
                    }.padding()
                    
                    // The carbs views
                    if userSettings.treatSugarsSeparately { ComposedFoodItemSugarsView(composedFoodItem: self.composedFoodItem) }
                    ComposedFoodItemCarbsView(composedFoodItem: self.composedFoodItem).padding(.top)
                    ComposedFoodItemECarbsView(composedFoodItem: self.composedFoodItem, absorptionScheme: self.absorptionScheme).padding(.top)
                }.padding()
                
                Button(action: {
                    activeSheet = .details
                }) {
                    Text("Further details")
                }.padding()
                
                Spacer()
            }
            .navigationBarTitle(Text(self.composedFoodItem.name))
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(action: {
                        activeSheet = .help
                    }) {
                        Image(systemName: "questionmark.circle").imageScale(.large)
                    }
                    
                    Button(action: {
                        composedFoodItem.clear()
                        UserSettings.shared.mealDelayInMinutes = 0
                        presentation.wrappedValue.dismiss()
                    }) {
                        Text("Clear")
                    }
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        activeSheet = .exportToHealth
                    }) {
                        HealthDataHelper.healthKitIsAvailable() ? AnyView(Image(systemName: "square.and.arrow.up").imageScale(.large)) : AnyView(EmptyView())
                    }
                    
                    Button(action: {
                        presentation.wrappedValue.dismiss()
                    }) {
                        Text("Close")
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(item: $activeSheet) {
            sheetContent($0)
        }
    }
    
    @ViewBuilder
    private func sheetContent(_ state: ComposedFoodItemEvaluationViewSheets.State) -> some View {
        switch state {
        case .help:
            HelpView(helpScreen: self.helpScreen)
        case .exportToHealth:
            ComposedFoodItemExportView(composedFoodItem: composedFoodItem, absorptionScheme: absorptionScheme)
        case .details:
            ComposedFoodItemDetailsView(absorptionScheme: absorptionScheme, composedFoodItem: composedFoodItem, userSettings: userSettings)
        }
    }
}
