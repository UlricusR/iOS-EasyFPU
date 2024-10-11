//
//  ComposedFoodItem+CoreDataClass.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 05.11.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//
//

import Foundation
import CoreData


public class ComposedFoodItem: NSManagedObject {
    static func fetchAll(viewContext: NSManagedObjectContext = AppDelegate.viewContext) -> [ComposedFoodItem] {
        let request: NSFetchRequest<ComposedFoodItem> = ComposedFoodItem.fetchRequest()
        
        guard let composedFoodItems = try? AppDelegate.viewContext.fetch(request) else {
            return []
        }
        return composedFoodItems
    }
    
    static func deleteAll(viewContext: NSManagedObjectContext = AppDelegate.viewContext) {
        ComposedFoodItem.fetchAll(viewContext: viewContext).forEach({
            viewContext.delete($0)
        })
        
        try? viewContext.save()
    }
    
    /**
     Creates a new ComposedFoodItem from the ComposedFoodItemViewModel.
     Creates the Ingredients and relates them to the new ComposedFoodItem.
     Also creates a new FoodItem and relates it to the new ComposedFoodItem.
     Does not relate the Core Data ComposedFoodItem to the passed ComposedFoodItemViewModel.
     
     - Parameter composedFoodItemVM: The source view model.
     
     - Returns: A Core Data ComposedFoodItem; nil if there are no Ingredients.
     */
    static func create(from composedFoodItemVM: ComposedFoodItemViewModel, isImport: Bool = false) -> ComposedFoodItem? {
        let moc = AppDelegate.viewContext
        
        // Create new ComposedFoodItem
        let cdComposedFoodItem = ComposedFoodItem(context: moc)
        
        // No existing composed food item, therefore create a new UUID
        cdComposedFoodItem.id = composedFoodItemVM.id
        
        // Fill data
        cdComposedFoodItem.name = composedFoodItemVM.name
        cdComposedFoodItem.favorite = composedFoodItemVM.favorite
        cdComposedFoodItem.amount = Int64(composedFoodItemVM.amount)
        cdComposedFoodItem.numberOfPortions = Int16(composedFoodItemVM.numberOfPortions)
        
        // Save new composed food item
        try? moc.save()
        
        // Check for ingredients - there must be ingredients!
        if Ingredient.create(from: composedFoodItemVM, relateTo: cdComposedFoodItem, isImport: isImport) != nil {
            // Create a related FoodItem and relate it to the ComposedFoodItem
            cdComposedFoodItem.foodItem = FoodItem.create(from: composedFoodItemVM)
            
            // Save new composed food item
            try? moc.save()
            
            // Return the ComposedFoodItem
            return cdComposedFoodItem
        } else {
            // There are no ingredients, therefore we delete it again and return nil
            moc.delete(cdComposedFoodItem)
            try? moc.save()
            return nil
        }
    }
    
    /**
     Updates an existing Core Data ComposedFoodItem.
     
     - Parameters:
        - composedFoodItemVM: The source ComposedFoodItemViewModel.
     - Returns: The updated Core Data ComposedFoodItem, nil if no related Core Data ComposedFoodItem was found (shouldn't happen)
     */
    static func update(_ composedFoodItemVM: ComposedFoodItemViewModel) -> ComposedFoodItem? {
        if let cdComposedFoodItem = composedFoodItemVM.cdComposedFoodItem {
            let moc = AppDelegate.viewContext
            
            // Update data in cdComposedFoodItem
            cdComposedFoodItem.name = composedFoodItemVM.name
            cdComposedFoodItem.favorite = composedFoodItemVM.favorite
            cdComposedFoodItem.amount = Int64(composedFoodItemVM.amount)
            cdComposedFoodItem.numberOfPortions = Int16(composedFoodItemVM.numberOfPortions)
            
            // If the related Core Data FoodItem was deleted, we need to create a new one
            // and set its ID to the same as the composed food item
            if cdComposedFoodItem.foodItem == nil {
                let cdFoodItem = FoodItem.create(from: composedFoodItemVM)
                cdFoodItem.id = cdComposedFoodItem.id
                cdComposedFoodItem.foodItem = cdFoodItem
            }
            
            // Update related cdFoodItem
            cdComposedFoodItem.foodItem?.name = composedFoodItemVM.name
            cdComposedFoodItem.foodItem?.favorite = composedFoodItemVM.favorite
            cdComposedFoodItem.foodItem?.caloriesPer100g = composedFoodItemVM.caloriesPer100g
            cdComposedFoodItem.foodItem?.carbsPer100g = composedFoodItemVM.carbsPer100g
            cdComposedFoodItem.foodItem?.sugarsPer100g = composedFoodItemVM.sugarsPer100g
            
            // Delete the existing Ingredients
            for ingredient in cdComposedFoodItem.ingredients {
                if let ingredientToBeDeleted = ingredient as? NSManagedObject {
                    moc.delete(ingredientToBeDeleted)
                }
            }
            
            // Add new ingredients
            _ = Ingredient.create(from: composedFoodItemVM, relateTo: cdComposedFoodItem)
            
            // Delete the existing TypicalAmounts
            if let existingTypicalAmounts = cdComposedFoodItem.foodItem?.typicalAmounts {
                for typicalAmount in existingTypicalAmounts {
                    if let typicalAmountToBeDeleted = typicalAmount as? NSManagedObject {
                        moc.delete(typicalAmountToBeDeleted)
                    }
                }
            }
            
            // Add the new TypicalAmounts
            if let cdFoodItem = cdComposedFoodItem.foodItem {
                for typicalAmount in composedFoodItemVM.typicalAmounts {
                    cdFoodItem.addToTypicalAmounts(TypicalAmount.create(from: typicalAmount))
                }
            }
            
            // Save updated composed food item
            try? AppDelegate.viewContext.save()
            
            return cdComposedFoodItem
        } else {
            // No Core Data ComposedFoodItem found - this should never happen!
            return nil
        }
    }
    
    static func duplicate(_ existingComposedFoodItem: ComposedFoodItem) -> ComposedFoodItem? {
        let moc = AppDelegate.viewContext
        
        // Create new ComposedFoodItem with new ID
        let cdComposedFoodItem = ComposedFoodItem(context: moc)
        cdComposedFoodItem.id = UUID()
        
        // Fill data
        cdComposedFoodItem.name = existingComposedFoodItem.name + NSLocalizedString(" - Copy", comment: "")
        cdComposedFoodItem.favorite = existingComposedFoodItem.favorite
        cdComposedFoodItem.amount = existingComposedFoodItem.amount
        cdComposedFoodItem.numberOfPortions = existingComposedFoodItem.numberOfPortions
        
        // Save
        try? moc.save()
        
        // Create ingredients
        for case let ingredient as Ingredient in existingComposedFoodItem.ingredients {
            _ = Ingredient.duplicate(ingredient, for: cdComposedFoodItem)
        }
        
        // Create related FoodItem
        if let existingFoodItem = existingComposedFoodItem.foodItem {
            cdComposedFoodItem.foodItem = FoodItem.duplicate(existingFoodItem)
            
            // Save
            try? moc.save()
            
            return cdComposedFoodItem
        } else {
            // No existing FoodItem found to duplicate - this should not happen
            // Delete composedFoodItem again
            ComposedFoodItem.delete(cdComposedFoodItem)
            
            return nil
        }
    }
    
    static func delete(_ composedFoodItem: ComposedFoodItem) {
        let moc = AppDelegate.viewContext
        
        // Deletion of all related ingredients will happen automatically
        // as we have set Delete Rule to Cascade in data model
        
        // Delete the food item itself
        moc.delete(composedFoodItem)
        
        // And save the context
        try? moc.save()
    }
    
    /**
     Returns the Core Data ComposedFoodItem with the given name.
     
     - Parameter name: The Core Data entry name.
     
     - Returns: The related Core Data ComposedFoodItem, nil if not found.
     */
    static func getComposedFoodItemByName(name: String) -> ComposedFoodItem? {
        let predicate = NSPredicate(format: "name = %@", name)
        let request: NSFetchRequest<ComposedFoodItem> = ComposedFoodItem.fetchRequest()
        request.predicate = predicate
        if let result = try? AppDelegate.viewContext.fetch(request) {
            if !result.isEmpty {
                return result[0]
            }
        }
        return nil
    }
}
