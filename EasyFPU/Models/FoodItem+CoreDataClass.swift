//
//  FoodItem+CoreDataClass.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 17.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//
//

import Foundation
import CoreData


public class FoodItem: NSManagedObject {
    func getCalories() -> Double {
        Double(self.amount) * self.caloriesPer100g / 100
    }
    
    func getCarbs() -> Double {
        Double(self.amount) * self.carbsPer100g / 100
    }
    
    func getFPU() -> FPU {
        // 1g carbs has ~4 kcal, so calculate carb portion of calories
        let carbsCal = Double(self.amount) / 100 * self.carbsPer100g * 4;

        // The carbs from fat and protein is the remainder
        let calFromFP = getCalories() - carbsCal;

        // 100kcal makes 1 FPU
        let fpus = calFromFP / 100;

        // Create and return the FPU object
        return FPU(fpu: fpus)
    }
}
