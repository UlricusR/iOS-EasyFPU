//
//  MealFoodItemView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 27.08.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct MealItemView: View {
    var foodItem: FoodItemViewModel
    @ObservedObject var absorptionScheme: AbsorptionScheme
    var fontSizeName: Font?
    var fontSizeDetails: Font?
    var foregroundColorName: Color?
    var absorptionTimeAsString: String {
        if foodItem.getFPU().getAbsorptionTime(absorptionScheme: absorptionScheme) != nil {
            return NumberFormatter().string(from: NSNumber(value: foodItem.getFPU().getAbsorptionTime(absorptionScheme: absorptionScheme)!))!
        } else {
            return "..."
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            // Amount and name
            HStack {
                Text(String(foodItem.amount)).font(fontSizeName)
                Text("g").font(fontSizeName)
                Text(foodItem.name).font(fontSizeName)
            }.foregroundColor(foregroundColorName)
            // Calories
            HStack {
                Text(foodItem.caloriesAsString).font(fontSizeDetails)
                Text("kcal").font(fontSizeDetails)
            }
            // Carbs
            HStack {
                Text(foodItem.carbsAsString).font(fontSizeDetails)
                Text("g Carbs").font(fontSizeDetails)
            }
            // FPU
            HStack {
                Text(FoodItemViewModel.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: foodItem.getFPU().fpu))!).font(fontSizeDetails)
                Text("FPU").font(fontSizeDetails)
            }
            // Extended carbs
            HStack {
                Text(FoodItemViewModel.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: foodItem.getFPU().getExtendedCarbs()))!).font(fontSizeDetails)
                Text("g Extended Carbs").font(fontSizeDetails)
            }
            // Absorption time
            HStack {
                Text(self.absorptionTimeAsString).font(fontSizeDetails)
                Text("h Absorption Time").font(fontSizeDetails)
            }
        }
    }
}
