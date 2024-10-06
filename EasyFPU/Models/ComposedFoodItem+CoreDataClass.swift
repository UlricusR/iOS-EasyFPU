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
        
        // Add cdComposedFoodItem to composedFoodItemVM
        composedFoodItemVM.cdComposedFoodItem = cdComposedFoodItem
        
        // Create a related FoodItem and relate it to the ComposedFoodItem
        cdComposedFoodItem.foodItem = FoodItem.create(from: composedFoodItemVM)
        
        // Add new ingredients
        if let cdIngredients = Ingredient.create(from: composedFoodItemVM, isImport: isImport) {
            cdComposedFoodItem.addToIngredients(NSSet(array: cdIngredients))
            
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
     Creates a ComposedFoodItem from an existing one - used for duplicating.
     
     - Parameters:
        - existingComposedFoodItem: The Core Data ComposedFoodItem to be duplicated.
        - newCDFoodItem: The Core Data FoodItem to be linked to this new ComposedFoodItem.
     
     - Returns: A new Core Data ComposedFoodItem linked to the passed FoodItem.
     */
    static func duplicate(_ existingComposedFoodItemVM: ComposedFoodItemViewModel) -> ComposedFoodItem? {
        // Create a new ComposedFoodItem from the existing view model
        let cdComposedFoodItem = ComposedFoodItem.create(from: existingComposedFoodItemVM)
        
        // Rename
        cdComposedFoodItem?.name += NSLocalizedString(" - Copy", comment: "")
        
        return cdComposedFoodItem
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
            if let ingredients = Ingredient.create(from: composedFoodItemVM) {
                cdComposedFoodItem.addToIngredients(NSSet(array: ingredients))
            }
            
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
