//
//  Meal.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 21.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class MealViewModel {
    var name: String
    var calories: Double = 0.0
    private var carbs: Double = 0.0
    var sugars: Double = 0.0
    var amount: Int = 0
    var fpus: FPU = FPU(fpu: 0.0)
    var foodItems = [FoodItemViewModel]()
    
    static let `default` = MealViewModel(name: "Default")
    
    init(name: String) {
        self.name = name
    }
    
    func add(foodItem: FoodItemViewModel) {
        foodItems.append(foodItem)
        let tempFPUs = fpus.fpu
        calories += foodItem.getCalories()
        carbs += foodItem.getRegularCarbs()
        sugars += foodItem.getSugars()
        amount += Int(foodItem.amount)
        fpus = FPU(fpu: tempFPUs + foodItem.getFPU().fpu)
    }
    
    func getRegularCarbs() -> Double {
        carbs - sugars
    }
}
