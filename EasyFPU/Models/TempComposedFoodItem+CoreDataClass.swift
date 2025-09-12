//
//  TempComposedFoodItem+CoreDataClass.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 12/09/2025.
//  Copyright © 2025 Ulrich Rüth. All rights reserved.
//
//

import Foundation
import CoreData

@objc(TempComposedFoodItem)
public class TempComposedFoodItem: ComposedFoodItem {
    
    //
    // MARK: - Static methods for entity creation/deletion/fetching
    //

    /// Creates a new TempComposedFoodItem with the given name. Other values are set to defaults. Does not save the context.
    /// - Parameter name: The name of the new TempComposedFoodItem.
    /// - Returns: The new TempComposedFoodItem.
    static func new(name: String) -> TempComposedFoodItem {
        let cdComposedFoodItem = TempComposedFoodItem(context: CoreDataStack.viewContext)
        cdComposedFoodItem.id = UUID()
        cdComposedFoodItem.name = name
        cdComposedFoodItem.favorite = false
        cdComposedFoodItem.amount = 0
        cdComposedFoodItem.numberOfPortions = 0
        return cdComposedFoodItem
    }
}
