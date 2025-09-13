//
//  TempFoodItem+CoreDataClass.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 13/09/2025.
//  Copyright © 2025 Ulrich Rüth. All rights reserved.
//
//

import Foundation
import CoreData

@objc(TempFoodItem)
public class TempFoodItem: FoodItem {
    
    //
    // MARK: - Static methods for entity creation/deletion/fetching
    //

    /// Creates a new Core Data FoodItem with default values. Does not save the context.
    /// - Parameter category: The category of the new FoodItem.
    /// - Returns: The new Core Data FoodItem.
    static func new(category: FoodItemCategory) -> TempFoodItem {
        let newFoodItem = TempFoodItem(context: CoreDataStack.viewContext)
        newFoodItem.id = UUID()
        newFoodItem.name = ""
        newFoodItem.caloriesPer100g = 0
        newFoodItem.carbsPer100g = 0
        newFoodItem.sugarsPer100g = 0
        newFoodItem.favorite = false
        newFoodItem.category = category.rawValue
        return newFoodItem
    }
}
