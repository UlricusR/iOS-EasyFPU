//
//  FoodCategory+CoreDataClass.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 13/08/2025.
//  Copyright © 2025 Ulrich Rüth. All rights reserved.
//
//

import Foundation
import CoreData


public class FoodCategory: NSManagedObject {
    
    //
    // MARK: - Static methods for entity creation/deletion/fetching
    //
    
    static func fetchAll(
        category: FoodItemCategory? = nil,
        viewContext: NSManagedObjectContext = CoreDataStack.viewContext
    ) -> [FoodCategory] {
        let request: NSFetchRequest<FoodCategory> = FoodCategory.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        if let category = category {
            request.predicate = NSPredicate(format: "category == %@", category.rawValue)
        }
        
        guard let foodCategories = try? CoreDataStack.viewContext.fetch(request) else {
            return []
        }
        return foodCategories
    }
    
    static func deleteAll(viewContext: NSManagedObjectContext = CoreDataStack.viewContext) {
        FoodCategory.fetchAll(viewContext: viewContext).forEach({
            viewContext.delete($0)
        })
        
        try? viewContext.save()
    }
    
    /// Creates a new Core Data FoodCategory with the given values. Does not check for duplicates.
    /// - Parameters:
    ///   - id: The unique identifier for the FoodCategory.
    ///   - name: The name of the FoodCategory.
    ///   - category: The category type of the FoodCategory, as a FoodItemCategory..
    ///   - saveContext: Whether to save the Core Data context after creation.
    /// - Returns: The created FoodCategory object.
    static func create(id: UUID, name: String, category: FoodItemCategory, saveContext: Bool) -> FoodCategory {
        // Create the FoodCategory
        let cdFoodCategory = FoodCategory(context: CoreDataStack.viewContext)
        
        // Fill data
        cdFoodCategory.id = id
        cdFoodCategory.name = name
        cdFoodCategory.category = category.rawValue
        
        // Save
        if saveContext {
            CoreDataStack.shared.save()
        }
        return cdFoodCategory
    }
    
    /// Deletes the given FoodCategory from Core Data.
    /// - Parameter foodCategory: The FoodCategory to delete.
    /// - Parameter saveContext: Whether to save the Core Data context after deletion.
    static func delete(_ foodCategory: FoodCategory, saveContext: Bool) {
        // Delete the food category
        CoreDataStack.viewContext.delete(foodCategory)
        
        // And save the context
        if saveContext {
            CoreDataStack.shared.save()
        }
    }
    
    /// Checks if a FoodCategory with the given id exists.
    /// - Parameter name: The name of the FoodCategory to check for.
    /// - Returns: True if a FoodCategory with the given name exists, false otherwise.
    static func exists(name: String, category: FoodItemCategory) -> Bool {
        return getFoodCategoriesByName(name: name, category: category)?.count ?? 0 > 0
    }
    
    /**
     Returns the Core Data FoodCategory with the given id.
     
     - Parameter id: The Core Data entry id.
     
     - Returns: The related Core Data FoodCategory, nil if not found.
     */
    static func getFoodCategoryByID(id: UUID) -> FoodCategory? {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        let request: NSFetchRequest<FoodCategory> = FoodCategory.fetchRequest()
        request.predicate = predicate
        do {
            let result = try CoreDataStack.viewContext.fetch(request)
            if !result.isEmpty {
                return result[0]
            }
        } catch {
            debugPrint("Error fetching food category: \(error)")
        }
        return nil
    }
    
    /**
     Returns the Core Data FoodCategory with the given name.
     
     - Parameter name: The Core Data entry name.
     
     - Returns: The related Core Data FoodCategory, nil if not found.
     */
    static func getFoodCategoriesByName(name: String, category: FoodItemCategory) -> [FoodCategory]? {
        let predicate = NSPredicate(format: "name == %@ AND category == %@", name, category.rawValue)
        let request: NSFetchRequest<FoodCategory> = FoodCategory.fetchRequest()
        request.predicate = predicate
        do {
            let result = try CoreDataStack.viewContext.fetch(request)
            if !result.isEmpty {
                return result
            }
        } catch {
            debugPrint("Error fetching food category: \(error)")
        }
        return nil
    }
}
