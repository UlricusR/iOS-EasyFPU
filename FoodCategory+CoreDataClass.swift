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
    /// - Returns: The created FoodCategory object.
    static func create(id: UUID, name: String, category: FoodItemCategory) -> FoodCategory {
        // Create the FoodCategory
        let cdFoodCategory = FoodCategory(context: CoreDataStack.viewContext)
        
        // Fill data
        cdFoodCategory.id = id
        cdFoodCategory.name = name
        cdFoodCategory.category = category.rawValue
        
        // Save
        CoreDataStack.shared.save()
        return cdFoodCategory
    }
    
    /// Updates an existing Core Data FoodCategory with new values.
    /// - Parameters:
    ///   - cdFoodCategory: The existing FoodCategory object to update.
    ///   - newName: The new name for the FoodCategory.
    ///   - newCategory: The new category type for the FoodCategory, as a FoodItemCategory.
    static func update(
        _ cdFoodCategory: FoodCategory,
        newName: String,
        newCategory: FoodItemCategory
    ) {
        cdFoodCategory.name = newName
        cdFoodCategory.category = newCategory.rawValue
        
        CoreDataStack.shared.save()
    }
    
    static func delete(_ foodCategory: FoodCategory) {
        // Delete the food category
        CoreDataStack.viewContext.delete(foodCategory)
        
        // And save the context
        CoreDataStack.shared.save()
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
    static func getFoodCategoriesByName(name: String) -> [FoodCategory]? {
        let predicate = NSPredicate(format: "name == %@", name)
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
