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
     Also creates a new FoodItem and relates it to the new ComposedFoodItem and vice versa.
     
     - Parameter composedFoodItemVM: The source view model.
     
     - Returns: A Core Data ComposedFoodItem; nil if there are no Ingredients.
     */
    static func create(from composedFoodItemVM: ComposedFoodItemViewModel, generateTypicalAmounts: Bool) -> ComposedFoodItem? {
        let moc = AppDelegate.viewContext
        
        // Create new ComposedFoodItem
        let cdComposedFoodItem = ComposedFoodItem(context: moc)
        
        // No existing composed food item, therefore create a new UUID
        cdComposedFoodItem.id = UUID()
        
        // Fill data
        cdComposedFoodItem.name = composedFoodItemVM.name
        cdComposedFoodItem.favorite = composedFoodItemVM.favorite
        cdComposedFoodItem.amount = Int64(composedFoodItemVM.amount)
        cdComposedFoodItem.numberOfPortions = Int16(composedFoodItemVM.numberOfPortions)
        
        // Add cdComposedFoodItem to composedFoodItemVM
        composedFoodItemVM.cdComposedFoodItem = cdComposedFoodItem
        
        // Create a related FoodItem and relate it to the ComposedFoodItem and vice versa
        cdComposedFoodItem.foodItem = FoodItem.create(from: composedFoodItemVM, generateTypicalAmounts: generateTypicalAmounts)
        cdComposedFoodItem.foodItem!.composedFoodItem = cdComposedFoodItem
        
        // Add new ingredients
        if let cdIngredients = Ingredient.create(from: composedFoodItemVM) {
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
        let cdComposedFoodItem = ComposedFoodItem.create(from: existingComposedFoodItemVM, generateTypicalAmounts: !existingComposedFoodItemVM.typicalAmounts.isEmpty)
        
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
}
