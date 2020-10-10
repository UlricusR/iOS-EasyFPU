//
//  MealDetail.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 23.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct MealDetail: View {
    @Environment(\.presentationMode) var presentation
    @ObservedObject var absorptionScheme: AbsorptionScheme
    var meal: MealViewModel
    @ObservedObject var userSettings = UserSettings.shared
    private let helpScreen = HelpScreen.mealDetails
    @State var activeSheet: MealDetailSheets.State?
    @State private var showDetails = false
    var absorptionTimeAsString: String {
        if meal.fpus.getAbsorptionTime(absorptionScheme: absorptionScheme) != nil {
            return NumberFormatter().string(from: NSNumber(value: meal.fpus.getAbsorptionTime(absorptionScheme: absorptionScheme)!))!
        } else {
            return "..."
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                VStack() {
                    // The meal delay stepper
                    HStack {
                        Stepper("Delay until meal", onIncrement: {
                            userSettings.mealDelayInMinutes += 5
                            userSettings.objectWillChange.send()
                        }, onDecrement: {
                            userSettings.mealDelayInMinutes = max(userSettings.mealDelayInMinutes - 5, 0)
                            userSettings.objectWillChange.send()
                        })
                        Text(String(userSettings.mealDelayInMinutes))
                        Text("min")
                    }.padding()
                    
                    // The carbs views
                    if userSettings.treatSugarsSeparately { MealSugarsView(meal: self.meal) }
                    MealCarbsView(meal: self.meal).padding(.top)
                    MealECarbsView(meal: self.meal, absorptionScheme: self.absorptionScheme).padding(.top)
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
                }.padding([.leading, .trailing])
                
                if showDetails {
                    List {
                        // Futher details
                        VStack(alignment: .leading) {
                            // Amount and name
                            HStack {
                                Text(String(meal.amount))
                                Text("g")
                                Text(NSLocalizedString(meal.name, comment: ""))
                            }.foregroundColor(Color.accentColor)
                            // Calories
                            HStack {
                                Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: meal.calories))!)
                                Text("kcal")
                            }.font(.caption)
                            // FPU
                            HStack {
                                Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: meal.fpus.fpu))!)
                                Text("FPU")
                            }.font(.caption)
                        }
                        
                        // Food items
                        ForEach(meal.foodItems, id: \.self) { foodItem in
                            MealItemView(foodItem: foodItem, absorptionScheme: self.absorptionScheme, fontSizeDetails: .caption, foregroundColorName: Color.accentColor)
                        }
                    }
                    .animation(.easeInOut)
                }
                
                Spacer()
            }
            .navigationBarTitle(NSLocalizedString(self.meal.name, comment: ""))
            .navigationBarItems(leading: HStack {
                Button(action: {
                    activeSheet = .help
                }) {
                    Image(systemName: "questionmark.circle").imageScale(.large)
                }
                
                if HealthDataHelper.healthKitIsAvailable() {
                    Button(action: {
                        activeSheet = .exportToHealth
                    }) {
                        Image(systemName: "square.and.arrow.up").imageScale(.large)
                    }.padding(.leading)
                }
            }, trailing:
                Button(action: {
                    presentation.wrappedValue.dismiss()
                }) {
                    Text("Done")
                }
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(item: $activeSheet) {
            sheetContent($0)
        }
    }
    
    @ViewBuilder
    private func sheetContent(_ state: MealDetailSheets.State) -> some View {
        switch state {
        case .help:
            HelpView(helpScreen: self.helpScreen)
        case .exportToHealth:
            MealExportView(meal: meal, absorptionScheme: absorptionScheme)
        }
    }
}
