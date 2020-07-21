//
//  FoodItemView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 13.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct FoodItemView: View {
    @ObservedObject var foodItem: FoodItem
    
    var body: some View {
        VStack {
            HStack {
                Text(foodItem.name ?? "Shit").font(.headline)
                if foodItem.favorite { Image(systemName: "star.fill").foregroundColor(.yellow).imageScale(.small) }
                Spacer()
            }
            
            HStack {
                Text("Nutritional values per 100g: ").font(.caption)
                
                Spacer()
                
                Text(FoodItemViewModel.doubleNumberFormatter.string(from: NSNumber(value: foodItem.caloriesPer100g))!).font(.caption)
                Text("kcal").font(.caption)
                
                Text("|")
                
                Text(FoodItemViewModel.doubleNumberFormatter.string(from: NSNumber(value: foodItem.carbsPer100g))!).font(.caption)
                Text("g Carbs").font(.caption)
            }
        }
    }
}
