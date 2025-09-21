//
//  TempComposedFoodItem+CoreDataProperties.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 12/09/2025.
//  Copyright © 2025 Ulrich Rüth. All rights reserved.
//
//

import Foundation
import CoreData


extension TempComposedFoodItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TempComposedFoodItem> {
        return NSFetchRequest<TempComposedFoodItem>(entityName: "TempComposedFoodItem")
    }

    //
    // MARK: Custom functions
    //
    
    /// Removes all ingredients from the TempComposedFoodItem, resets its amount to 0 and sets new values, but keeps the ID. Does not save the context.
    /// - Parameter name: The new name for the ComposedFoodItem once cleared.
    func clear(name: String) {
        // Clear ingredients
        for ingredient in self.ingredients.allObjects as! [Ingredient] {
            ingredient.amount = 0
            self.removeFromIngredients(ingredient)
        }
        
        // Reset amount
        self.amount = 0
        
        // Reset values - we keep the ID
        self.name = name
        self.favorite = false
        self.numberOfPortions = 0
    }
}
