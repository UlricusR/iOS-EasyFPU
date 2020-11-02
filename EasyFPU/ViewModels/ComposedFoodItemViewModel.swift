//
//  ComposedProductViewModel.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 29.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class ComposedFoodItemViewModel: ObservableObject, VariableAmountItem {
    var name: String
    var calories: Double = 0.0
    private var carbs: Double = 0.0
    private var sugars: Double = 0.0
    @Published var amount: Int = 0
    var fpus: FPU = FPU(fpu: 0.0)
    var foodItems = [FoodItemViewModel]()
    
    @Published var amountAsString: String = "" {
        willSet {
            let result = DataHelper.checkForPositiveInt(valueAsString: newValue, allowZero: true)
            switch result {
            case .success(let amountAsInt):
                amount = amountAsInt
            case .failure(let err):
                debugPrint(err.evaluate())
                return
            }
        }
    }
    
    static let `default` = ComposedFoodItemViewModel(name: "Default")
    
    init(name: String) {
        self.name = name
    }
    
    func add(foodItem: FoodItemViewModel) {
        foodItems.append(foodItem)
        let tempFPUs = fpus.fpu
        calories += foodItem.getCalories()
        carbs += foodItem.getCarbsInclSugars()
        sugars += foodItem.getSugarsOnly()
        amountAsString = String(amount + foodItem.amount) // amount will be set implicitely
        fpus = FPU(fpu: tempFPUs + foodItem.getFPU().fpu)
    }
    
    func getCarbsInclSugars() -> Double {
        self.carbs
    }
    
    func getSugarsOnly() -> Double {
        self.sugars
    }
    
    func getRegularCarbs(when treatSugarsSeparately: Bool) -> Double {
        treatSugarsSeparately ? self.carbs - self.sugars : self.carbs
    }
    
    func getSugars(when treatSugarsSeparately: Bool) -> Double {
        treatSugarsSeparately ? self.sugars : 0
    }
    
    func remove(foodItem: FoodItemViewModel) {
        foodItem.amountAsString = "0"
        foodItem.cdFoodItem?.amount = 0
        if let index = foodItems.firstIndex(of: foodItem) {
            foodItems.remove(at: index)
        }
        try? AppDelegate.viewContext.save()
    }
    
    func clear() {
        for foodItem in foodItems {
            foodItem.amountAsString = "0"
            foodItem.cdFoodItem?.amount = 0
        }
        foodItems.removeAll()
        try? AppDelegate.viewContext.save()
    }
}
