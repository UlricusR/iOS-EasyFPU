//
//  MealDetail.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 23.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct MealDetail: View {
    @Binding var isPresented: Bool
    @ObservedObject var absorptionScheme: AbsorptionScheme
    var meal: MealViewModel
    private let helpScreen = HelpScreen.mealDetails
    @State var activeSheet = ActiveMealDetailSheet.help
    @State private var showingSheet = false
    @State private var showIncludedFoodItems = false
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
                    MealSugarsView(meal: self.meal)
                    MealCarbsView(meal: self.meal).padding(.top)
                    MealECarbsView(meal: self.meal, absorptionScheme: self.absorptionScheme).padding(.top)
                }.padding()
                
                HStack() {
                    Text("Included food items:").font(.headline)
                    Spacer()
                    Button(action: {
                        withAnimation {
                            self.showIncludedFoodItems.toggle()
                        }
                    }) {
                        Image(systemName: "chevron.right.circle")
                            .imageScale(.large)
                            .rotationEffect(.degrees(showIncludedFoodItems ? 90 : 0))
                            .scaleEffect(showIncludedFoodItems ? 1.5 : 1)
                    }
                }.padding([.leading, .trailing])
                
                if showIncludedFoodItems {
                    List {
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
                    self.activeSheet = .help
                    self.showingSheet = true
                }) {
                    Image(systemName: "questionmark.circle").imageScale(.large)
                }
                
                if HealthDataHelper.healthKitIsAvailable() {
                    Button(action: {
                        self.activeSheet = .exportToHealth
                        self.showingSheet = true
                    }) {
                        Image(systemName: "square.and.arrow.up").imageScale(.large)
                    }.padding(.leading)
                }
            }, trailing:
                Button(action: {
                    self.isPresented = false
                }) {
                    Text("Done")
                }
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: self.$showingSheet) {
            MealDetailSheet(activeSheet: self.activeSheet, isPresented: self.$showingSheet, meal: self.meal, absorptionScheme: self.absorptionScheme, helpScreen: self.helpScreen)
        }
    }
}
