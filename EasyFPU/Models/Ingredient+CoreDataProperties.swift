//
//  Ingredient+CoreDataProperties.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 05.11.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//
//

import Foundation
import CoreData


extension Ingredient: VariableAmountItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Ingredient> {
        return NSFetchRequest<Ingredient>(entityName: "Ingredient")
    }

    @NSManaged public var id: UUID
    @NSManaged public var relatedFoodItemID: UUID? // The id of the related FoodItem
    @NSManaged public var name: String
    @NSManaged public var favorite: Bool
    @NSManaged public var amount: Int64
    @NSManaged public var caloriesPer100g: Double
    @NSManaged public var carbsPer100g: Double
    @NSManaged public var sugarsPer100g: Double
    @NSManaged public var composedFoodItem: ComposedFoodItem
    @NSManaged public var foodItem: FoodItem?
    
    //
    // MARK: - Computed properties
    //
    
    var calories: Double {
        Double(self.amount) / 100 * self.caloriesPer100g
    }
    
    var carbsInclSugars: Double {
        Double(self.amount) / 100 * self.carbsPer100g
    }
    
    var sugarsOnly: Double {
        Double(self.amount) / 100 * self.sugarsPer100g
    }
    
    var fpus: FPU {
        // 1g carbs has ~4 kcal, so calculate carb portion of calories
        let carbsCal = Double(self.amount) / 100 * self.carbsPer100g * 4;

        // The carbs from fat and protein is the remainder
        let calFromFP = calories - carbsCal;

        // 100kcal makes 1 FPU
        let fpus = calFromFP / 100;

        // Create and return the FPU object
        return FPU(fpu: fpus)
    }
    
    //
    // MARK: - Custom functions
    //
    
    func getRegularCarbs(treatSugarsSeparately: Bool) -> Double {
        Double(self.amount) / 100 * (treatSugarsSeparately ? (self.carbsPer100g - self.sugarsPer100g) : self.carbsPer100g)
    }
    
    func getSugars(treatSugarsSeparately: Bool) -> Double {
        Double(self.amount) / 100 * (treatSugarsSeparately ? self.sugarsPer100g : 0)
    }
    
    
}

extension Ingredient : Identifiable {
    public static func == (lhs: Ingredient, rhs: Ingredient) -> Bool {
        lhs.id == rhs.id
    }
}
