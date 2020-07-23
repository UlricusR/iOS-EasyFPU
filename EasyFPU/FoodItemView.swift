//
//  FoodItemView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 13.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct FoodItemView: View {
    @EnvironmentObject var userData: UserData
    @ObservedObject var foodItem: FoodItem
    @State private var showingSheet = false
    @State var draftFoodItem = FoodItemViewModel(
        name: "",
        favorite: false,
        caloriesPer100g: 0.0,
        carbsPer100g: 0.0,
        amount: 0
    )
    @State var activeSheet = ActiveFoodItemViewSheet.selectFoodItem
    
    var body: some View {
        VStack {
            HStack {
                if foodItem.amount > 0 {
                    Image(systemName: "xmark.circle").foregroundColor(.red)
                    Text(String(foodItem.amount)).font(.headline).foregroundColor(.accentColor)
                    Text("g").font(.headline).foregroundColor(.accentColor)
                } else {
                    Image(systemName: "plus.circle").foregroundColor(.green)
                }
                Text(foodItem.name ?? "- Unnamed -").font(.headline).foregroundColor(foodItem.amount > 0 ? .accentColor : .none)
                if foodItem.favorite { Image(systemName: "star.fill").foregroundColor(.yellow).imageScale(.small) }
                Spacer()
            }
            
            HStack {
                Text("Nutritional values per 100g:").font(.caption).foregroundColor(.gray)
                
                Spacer()
                
                Text(FoodItemViewModel.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: foodItem.caloriesPer100g))!).font(.caption).foregroundColor(.gray)
                Text("kcal").font(.caption).foregroundColor(.gray)
                
                Text("|").foregroundColor(.gray)
                
                Text(FoodItemViewModel.doubleFormatter(numberOfDigits: 2).string(from: NSNumber(value: foodItem.carbsPer100g))!).font(.caption).foregroundColor(.gray)
                Text("g Carbs").font(.caption).foregroundColor(.gray)
            }
            
            if foodItem.amount > 0 {
                HStack(alignment: .top) {
                    HStack {
                        Text("Nutritional values for").font(.caption)
                        Text(String(foodItem.amount)).font(.caption)
                        Text("g").font(.caption)
                        Text(":").font(.caption)
                    }
                    
                    Spacer()
                        
                    VStack(alignment: .leading) {
                        HStack {
                            Text(FoodItemViewModel.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: foodItem.getCalories()))!).font(.caption)
                            Text("kcal").font(.caption)
                        }
                        
                        HStack {
                            Text(FoodItemViewModel.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: foodItem.getCarbs()))!).font(.caption)
                            Text("g Carbs").font(.caption)
                        }
                
                        HStack {
                            Text(FoodItemViewModel.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: foodItem.getFPU().fpu))!).font(.caption)
                            Text("FPU").font(.caption)
                        }
                        
                        HStack {
                            Text(FoodItemViewModel.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: foodItem.getFPU().getExtendedCarbs()))!).font(.caption)
                            Text("g Extended Carbs").font(.caption)
                        }
                        
                        HStack {
                            Text(NumberFormatter().string(from: NSNumber(value: foodItem.getFPU().getAbsorptionTime(absorptionScheme: userData.absorptionScheme)))!).font(.caption)
                            Text("h Absorption Time").font(.caption)
                        }
                    }
                }
            }
        }
        .onTapGesture {
            if self.foodItem.amount > 0 {
                self.foodItem.amount = 0
            } else {
                self.activeSheet = .selectFoodItem
                self.showingSheet = true
            }
        }
        .onLongPressGesture {
            // Edit food item
            self.draftFoodItem = FoodItemViewModel(
                name: self.foodItem.name ?? "",
                favorite: self.foodItem.favorite,
                caloriesPer100g: self.foodItem.caloriesPer100g,
                carbsPer100g: self.foodItem.carbsPer100g,
                amount: Int(self.foodItem.amount)
            )
            self.activeSheet = .editFoodItem
            self.showingSheet = true
        }
        .sheet(isPresented: $showingSheet) {
            FoodItemViewSheets(activeSheet: self.activeSheet, isPresented: self.$showingSheet, draftFoodItem: self.$draftFoodItem, editedFoodItem: self.foodItem)
        }
    }
}
