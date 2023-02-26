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
    @State private var showDetails = false
    var absorptionTimeAsString: String {
        if composedFoodItem.fpus.getAbsorptionTime(absorptionScheme: absorptionScheme) != nil {
            return DataHelper.intFormatter.string(from: NSNumber(value: composedFoodItem.fpus.getAbsorptionTime(absorptionScheme: absorptionScheme)!))!
        } else {
            return "..."
        }
    }
    
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
                
                HStack() {
                    Text("Further details").font(.headline)
                    Spacer()
                    Button(action: {
                        withAnimation {
                            self.showDetails.toggle()
                        }
                    }) {
                        Image(systemName: "chevron.right.circle")
                            .imageScale(.large)
                            .rotationEffect(.degrees(showDetails ? 90 : 0))
                            .scaleEffect(showDetails ? 1.5 : 1)
                    }
                }.padding(.horizontal)
                
                if showDetails {
                    List {
                        // Futher details: Total meal
                        VStack(alignment: .leading) {
                            // Amount and name
                            HStack {
                                Text(String(composedFoodItem.amount))
                                Text("g")
                                Text(NSLocalizedString(composedFoodItem.name, comment: ""))
                            }.foregroundColor(Color.accentColor)
                            // Calories
                            HStack {
                                Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: composedFoodItem.calories))!)
                                Text("kcal")
                            }.font(.caption)
                            // FPU
                            HStack {
                                Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: composedFoodItem.fpus.fpu))!)
                                Text("FPU")
                            }.font(.caption)
                        }
                        
                        // Food items
                        ForEach(composedFoodItem.foodItems, id: \.self) { foodItem in
                            ComposedFoodItemView(foodItem: foodItem, absorptionScheme: self.absorptionScheme, fontSizeDetails: .caption, foregroundColorName: Color.accentColor)
                        }
                    }
                    .animation(.easeInOut, value: showDetails)
                }
                
                Spacer()
            }
            .navigationBarTitle(Text(self.composedFoodItem.name), displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        activeSheet = .help
                    }) {
                        Image(systemName: "questionmark.circle").imageScale(.large)
                    }
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        composedFoodItem.clear()
                        UserSettings.shared.mealDelayInMinutes = 0
                    }) {
                        Image(systemName: "xmark.circle").foregroundColor(.red).imageScale(.large)
                    }.padding(.trailing)
                    
                    Button(action: {
                        activeSheet = .exportToHealth
                    }) {
                        HealthDataHelper.healthKitIsAvailable() ? AnyView(Image(systemName: "square.and.arrow.up").imageScale(.large)) : AnyView(EmptyView())
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
        }
    }
}
