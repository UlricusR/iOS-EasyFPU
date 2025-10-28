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
    
    static func createFetchRequest() -> NSFetchRequest<ComposedFoodItem> {
        let request: NSFetchRequest<ComposedFoodItem> = ComposedFoodItem.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ComposedFoodItem.name, ascending: true)]
        return request
    }
    
    /// Creates a new ComposedFoodItem with the given name. Other values are set to defaults. Does not save the context.
    /// - Parameter name: The name of the new ComposedFoodItem.
    /// - Returns: The new ComposedFoodItem.
    static func new(name: String, context: NSManagedObjectContext) -> ComposedFoodItem {
        let cdComposedFoodItem = ComposedFoodItem(context: context)
        cdComposedFoodItem.id = UUID()
        cdComposedFoodItem.name = name
        cdComposedFoodItem.favorite = false
        cdComposedFoodItem.amount = 0
        cdComposedFoodItem.numberOfPortions = 0
        return cdComposedFoodItem
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
    
    /// Returns all Core Data ComposedFoodItems with the given name.
    /// - Parameters:
    ///   - name: The Core Data entry name.
    /// - Returns: An array of related Core Data ComposedFoodItems, nil if not found.
    static func getComposedFoodItemsByName(name: String) -> [ComposedFoodItem]? {
        let predicate = NSPredicate(format: "name == %@", name)
        let request: NSFetchRequest<ComposedFoodItem> = ComposedFoodItem.fetchRequest()
        request.predicate = predicate
        do {
            let result = try CoreDataStack.viewContext.fetch(request)
            if !result.isEmpty {
                return result
            }
        } catch {
            debugPrint("Error fetching ComposedFoodItem: \(error)")
        }
        return nil
    }
}
