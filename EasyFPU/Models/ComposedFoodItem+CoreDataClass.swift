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
    
    //
    // MARK: - Static methods for entity creation/deletion/fetching
    //
    
    static func fetchAll(viewContext: NSManagedObjectContext = CoreDataStack.viewContext) -> [ComposedFoodItem] {
        let request: NSFetchRequest<ComposedFoodItem> = ComposedFoodItem.fetchRequest()
        
        guard let composedFoodItems = try? CoreDataStack.viewContext.fetch(request) else {
            return []
        }
        return composedFoodItems
    }
    
    static func deleteAll(viewContext: NSManagedObjectContext = CoreDataStack.viewContext) {
        ComposedFoodItem.fetchAll(viewContext: viewContext).forEach({
            viewContext.delete($0)
        })
        
        try? viewContext.save()
    }
    
    static func fetchRequestWithoutChildren() -> NSFetchRequest<ComposedFoodItem> {
        let request: NSFetchRequest<ComposedFoodItem> = ComposedFoodItem.fetchRequest()
        request.includesSubentities = false
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ComposedFoodItem.name, ascending: true)]
        return request
    }
    
    /**
     Creates a new ComposedFoodItem from the ComposedFoodItemViewModel.
     Creates the Ingredients and relates them to the new ComposedFoodItem.
     Also creates a new FoodItem and relates it to the new ComposedFoodItem.
     Does not relate the Core Data ComposedFoodItem to the passed ComposedFoodItemViewModel.
     
     - Parameter composedFoodItemVM: The source view model.
     - Parameter saveContext: Whether to permanently save the changes to the core data stack.
     
     - Returns: A Core Data ComposedFoodItem; nil if there are no Ingredients.
     */
    static func create(from composedFoodItemVM: ComposedFoodItemPersistence, saveContext: Bool) -> ComposedFoodItem? {
        // Create new ComposedFoodItem
        let cdComposedFoodItem = ComposedFoodItem(context: CoreDataStack.viewContext)
        
        // Use the ID of the ComposedFoodItemViewModel
        cdComposedFoodItem.id = composedFoodItemVM.id
        
        // Fill data
        cdComposedFoodItem.name = composedFoodItemVM.name
        cdComposedFoodItem.foodCategory = composedFoodItemVM.foodCategory
        cdComposedFoodItem.favorite = composedFoodItemVM.favorite
        cdComposedFoodItem.amount = Int64(composedFoodItemVM.amount)
        cdComposedFoodItem.numberOfPortions = Int16(composedFoodItemVM.numberOfPortions)
        
        // Check for ingredients - there must be ingredients!
        if Ingredient.create(from: composedFoodItemVM, relateTo: cdComposedFoodItem, saveContext: saveContext) != nil {
            // Create a related FoodItem and relate it to the ComposedFoodItem
            cdComposedFoodItem.foodItem = FoodItem.create(from: composedFoodItemVM, saveContext: saveContext)
            
            // Save new composed food item
            if saveContext {
                CoreDataStack.shared.save()
            }
            
            // Return the ComposedFoodItem
            return cdComposedFoodItem
        } else {
            // There are no ingredients, therefore we delete it again and return nil
            CoreDataStack.viewContext.delete(cdComposedFoodItem)
            if saveContext {
                CoreDataStack.shared.save()
            }
            return nil
        }
    }
    
    /// Creates a new ComposedFoodItem from the given ComposedFoodItem.
    /// Typically used for creating a permanent ComposedFoodItem from a TempComposedFoodItem.
    /// - Parameters:
    ///   - composedFoodItem: The source ComposedFoodItem.
    ///   - saveContext: Whether to permanently save the changes to the core data stack.
    /// - Returns: The created ComposedFoodItem.
    static func create(from composedFoodItem: ComposedFoodItem, saveContext: Bool) -> ComposedFoodItem {
        // Create new ComposedFoodItem
        let cdComposedFoodItem = ComposedFoodItem(context: CoreDataStack.viewContext)
        
        // Use the ID of the ComposedFoodItemViewModel
        cdComposedFoodItem.id = composedFoodItem.id
        
        // Fill data
        cdComposedFoodItem.name = composedFoodItem.name
        cdComposedFoodItem.foodCategory = composedFoodItem.foodCategory
        cdComposedFoodItem.favorite = composedFoodItem.favorite
        cdComposedFoodItem.amount = composedFoodItem.amount
        cdComposedFoodItem.numberOfPortions = composedFoodItem.numberOfPortions
        
        // Link ingredients
        for ingredient in composedFoodItem.ingredients {
            if let cdIngredient = ingredient as? Ingredient {
                cdComposedFoodItem.addToIngredients(cdIngredient)
            }
        }
        
        // Save new composed food item
        if saveContext {
            CoreDataStack.shared.save()
        }
        
        return cdComposedFoodItem
    }
    
    /// Deletes the given ComposedFoodItem. Does not save the context.
    /// - Parameters:
    ///   - composedFoodItem: The ComposedFoodItem to delete.
    ///   - includeAssociatedFoodItem: If true, also deletes the associated FoodItem, if any.
    static func delete(_ composedFoodItem: ComposedFoodItem, includeAssociatedFoodItem: Bool, saveContext: Bool) {
        if includeAssociatedFoodItem {
            if let associatedFoodItem = composedFoodItem.foodItem {
                FoodItem.delete(associatedFoodItem, saveContext: false)
            }
        }
        
        // Deletion of all related ingredients will happen automatically
        // as we have set Delete Rule to Cascade in data model
        
        // Delete the food item itself
        CoreDataStack.viewContext.delete(composedFoodItem)
        
        if saveContext {
            CoreDataStack.shared.save()
        }
    }
    
    /**
     Returns the Core Data ComposedFoodItem with the given id.
     
     - Parameter id: The Core Data entry id.
     
     - Returns: The related Core Data ComposedFoodItem, nil if not found.
     */
    static func getComposedFoodItemByID(id: UUID) -> ComposedFoodItem? {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        let request: NSFetchRequest<ComposedFoodItem> = ComposedFoodItem.fetchRequest()
        request.predicate = predicate
        do {
            let result = try CoreDataStack.viewContext.fetch(request)
            if !result.isEmpty {
                return result[0]
            }
        } catch {
            debugPrint("Error fetching ComposedFoodItem: \(error)")
        }
        return nil
    }
    
    /**
     Returns the Core Data ComposedFoodItem with the given name.
     
     - Parameter name: The Core Data entry name.
     
     - Returns: The related Core Data ComposedFoodItem, nil if not found.
     */
    static func getComposedFoodItemByName(name: String, includeSubEntities: Bool = false) -> ComposedFoodItem? {
        let predicate = NSPredicate(format: "name == %@", name)
        let request: NSFetchRequest<ComposedFoodItem> = ComposedFoodItem.fetchRequest()
        request.includesSubentities = includeSubEntities
        request.predicate = predicate
        do {
            let result = try CoreDataStack.viewContext.fetch(request)
            if !result.isEmpty {
                return result[0]
            }
        } catch {
            debugPrint("Error fetching ComposedFoodItem: \(error)")
        }
        return nil
    }
}
