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
    static func fetchAll(viewContext: NSManagedObjectContext = CoreDataStack.viewContext) -> [FoodCategory] {
        let request: NSFetchRequest<FoodCategory> = FoodCategory.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
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
    
    /**
     Creates a new Core Data FoodCategory. Does not relate it to the passed FoodItemViewModel.
     
     - Parameters:
        - foodCategoryVM: the source FoodCategoryViewModel.
        
     - Returns: the new Core Data FoodCategory.
     */
    static func create(from foodCategoryVM: FoodCategoryViewModel) -> FoodCategory {
        // Create the FoodCategory
        let cdFoodCategory = FoodCategory(context: CoreDataStack.viewContext)
        
        // Fill data
        cdFoodCategory.id = foodCategoryVM.id
        cdFoodCategory.name = foodCategoryVM.name
        cdFoodCategory.category = foodCategoryVM.category.rawValue
        
        // Save
        CoreDataStack.shared.save()
        return cdFoodCategory
    }
    
    /**
     Updates a Core Data FoodCategory with the values from a FoodCategoryViewModel.
     
     - Parameters:
        - cdFoodCategory: The Core Data FoodCategory to be updated.
        - foodCategoryVM: The source FoodCategoryViewModel.
     */
    static func update(
        _ cdFoodCategory: FoodCategory,
        with foodCategoryVM: FoodCategoryViewModel
    ) {
        cdFoodCategory.name = foodCategoryVM.name
        cdFoodCategory.category = foodCategoryVM.category.rawValue
        
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
