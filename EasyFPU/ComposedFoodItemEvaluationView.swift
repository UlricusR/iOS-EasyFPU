//
//  MealDetail.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 23.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct ComposedFoodItemEvaluationView: View {
    @ObservedObject var absorptionScheme: AbsorptionScheme
    @ObservedObject var composedFoodItem: ComposedFoodItemViewModel
    @ObservedObject var userSettings = UserSettings.shared
    private let helpScreen = HelpScreen.mealDetails
    @State var activeSheet: ComposedFoodItemEvaluationViewSheets.State?
    
    var body: some View {
        NavigationStack {
            VStack {
                if composedFoodItem.foodItems.isEmpty {
                    // No products selected for the meal, so display empty state info and a call for action button
                    Image("cutlery-color").padding()
                    Text("This is where you will see the nutritial data of your meal and where you can export it to Loop.").padding()
                    Button {
                        // Add new product to composed food item
                        activeSheet = .addProduct
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle")
                                .imageScale(.large)
                                .foregroundColor(.green)
                                .bold()
                            Text("Add products to your meal")
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(.yellow)
                        )
                    }
                } else {
                    // Summarize the meal
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
            }
            .navigationBarTitle(Text("Calculate meal"))
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(action: {
                        activeSheet = .help
                    }) {
                        Image(systemName: "questionmark.circle").imageScale(.large)
                    }
                    
                    if !composedFoodItem.foodItems.isEmpty {
                        Button(action: {
                            composedFoodItem.clear()
                            UserSettings.shared.mealDelayInMinutes = 0
                        }) {
                            Text("Clear")
                        }
                    }
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        activeSheet = .exportToHealth
                    }) {
                        HealthDataHelper.healthKitIsAvailable() ? AnyView(Image(systemName: "square.and.arrow.up").imageScale(.large)) : AnyView(EmptyView())
                    }.disabled(composedFoodItem.foodItems.isEmpty)
                    
                    Button(action: {
                        // Add new product to composed food item
                        activeSheet = .addProduct
                    }) {
                        Image(systemName: "plus.circle")
                            .imageScale(.large)
                            .foregroundColor(.green)
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
        case .addProduct:
            ProductSelectionListView()
        case .details:
            ComposedFoodItemDetailsView(absorptionScheme: absorptionScheme, composedFoodItem: composedFoodItem, userSettings: userSettings)
        }
    }
}
