//
//  MealDetail.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 23.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct MealDetail: View {
    @EnvironmentObject var userData: UserData
    @Binding var isPresented: Bool
    var meal: Meal
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Total nutritional values").font(.headline)
            
                HStack {
                    Text(NumberFormatter().string(from: NSNumber(value: self.meal.amount))!)
                    Text("g")
                    Text("Amount consumed")
                }
                
                HStack {
                    Text(FoodItemViewModel.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: self.meal.calories))!)
                    Text("kcal")
                }
                
                HStack {
                    Text(FoodItemViewModel.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: self.meal.carbs))!)
                    Text("g Carbs")
                }
                
                HStack {
                    Text(FoodItemViewModel.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: self.meal.fpus.fpu))!)
                    Text("FPU")
                }
                
                HStack {
                    Text(FoodItemViewModel.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: self.meal.fpus.getExtendedCarbs()))!)
                    Text("g Extended Carbs")
                }
                
                HStack {
                    Text(NumberFormatter().string(from: NSNumber(value: self.meal.fpus.getAbsorptionTime(absorptionScheme: self.userData.absorptionScheme)))!)
                    Text("h Absorption Time")
                }
                
                Spacer()
            }
            .navigationBarTitle(NSLocalizedString(self.meal.name, comment: ""))
            .navigationBarItems(trailing: Button(action: {
                    self.isPresented = false
                }) {
                    Text("Done")
                }
            )
        }
    }
}
