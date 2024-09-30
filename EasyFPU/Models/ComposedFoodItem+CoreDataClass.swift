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
     
     - Parameter composedFoodItemVM: The source view model.
     
     - Returns: A Core Data ComposedFoodItem; nil if there are no Ingredients.
     */
    static func create(from composedFoodItemVM: ComposedFoodItemViewModel, generateTypicalAmounts: Bool) -> ComposedFoodItem? {
        debugPrint(AppDelegate.persistentContainer.persistentStoreDescriptions) // The location of the .sqlite file
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
    static func duplicate(_ existingComposedFoodItemVM: ComposedFoodItemViewModel) -> ComposedFoodItem {
        let moc = AppDelegate.viewContext
        let cdComposedFoodItem = ComposedFoodItem(context: moc)
        cdComposedFoodItem.id = UUID()
        
        // Fill data
        cdComposedFoodItem.name = existingComposedFoodItemVM.name
        cdComposedFoodItem.favorite = existingComposedFoodItemVM.favorite
        cdComposedFoodItem.amount = Int64(existingComposedFoodItemVM.amount)
        cdComposedFoodItem.numberOfPortions = Int16(existingComposedFoodItemVM.numberOfPortions)
        
        // Add ingredients
        if let existingIngredients = existingComposedFoodItemVM.cdComposedFoodItem?.ingredients.allObjects as? [Ingredient] {
            for ingredient in existingIngredients {
                let cdIngredient = Ingredient.duplicate(ingredient, for: cdComposedFoodItem)
                cdComposedFoodItem.addToIngredients(cdIngredient)
            }
        }
        
        // Save new composed food item
        try? moc.save()
        
        return cdComposedFoodItem
    }
    
    /**
     Updates an existing Core Data ComposedFoodItem.
     
     - Parameters:
        - cdComposedFoodItem: The Core Data ComposedFoodItem to be updated.
        - composedFoodItemVM: The source ComposedFoodItemViewModel.
        - cdFoodItem: The Core Data FoodItem related to the Core Data ComposedFoodItem.
     - Returns: The updated Core Data ComposedFoodItem, nil if it couldn't be updated
     */
    static func update(_ composedFoodItemVM: ComposedFoodItemViewModel) -> ComposedFoodItem? {
        if let cdComposedFoodItem = composedFoodItemVM.cdComposedFoodItem {
            let moc = AppDelegate.viewContext
            
            // Update data
            cdComposedFoodItem.name = composedFoodItemVM.name
            cdComposedFoodItem.favorite = composedFoodItemVM.favorite
            cdComposedFoodItem.amount = Int64(composedFoodItemVM.amount)
            cdComposedFoodItem.numberOfPortions = Int16(composedFoodItemVM.numberOfPortions)
            
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
