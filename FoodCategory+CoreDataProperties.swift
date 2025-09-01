//
//  FoodCategory+CoreDataProperties.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 13/08/2025.
//  Copyright © 2025 Ulrich Rüth. All rights reserved.
//
//

import Foundation
import CoreData


extension FoodCategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FoodCategory> {
        return NSFetchRequest<FoodCategory>(entityName: "FoodCategory")
    }

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var category: String
    @NSManaged public var foodItems: NSSet?
    @NSManaged public var composedFoodItems: NSSet?

    //
    // MARK: - Computed properties
    //
    
    
    
    //
    // MARK: - Custom functions
    //
    
    /// Updates an existing Core Data FoodCategory with new values.
    /// - Parameters:
    ///   - newName: The new name for the FoodCategory.
    ///   - newCategory: The new category type for the FoodCategory, as a FoodItemCategory.
    ///   - saveContext: A Boolean indicating whether to save the Core Data context after updating.
    func update(
        newName: String,
        newCategory: FoodItemCategory,
        saveContext: Bool
    ) {
        self.name = newName
        self.category = newCategory.rawValue
        if saveContext {
            CoreDataStack.shared.save()
        }
    }
    
    /// Checks if the given FoodCategory has related items, either FoodItems or ComposedFoodItems.
    /// - Returns: True if there are related items, false otherwise.
    func hasRelatedItems() -> Bool {
        var hasRelatedItems = false
        
        // Check if there are any related FoodItems
        let request: NSFetchRequest<FoodItem> = FoodItem.fetchRequest()
        request.predicate = NSPredicate(format: "foodCategory == %@", self)
        
        do {
            let result = try CoreDataStack.viewContext.fetch(request)
            hasRelatedItems = !result.isEmpty
        } catch {
            debugPrint("Error fetching food items for category: \(error)")
        }
        
        // Check if there are any related ComposedFoodItems
        if !hasRelatedItems {
            let request: NSFetchRequest<ComposedFoodItem> = ComposedFoodItem.fetchRequest()
            request.predicate = NSPredicate(format: "foodCategory == %@", self)
            do {
                let result = try CoreDataStack.viewContext.fetch(request)
                hasRelatedItems = !result.isEmpty
            } catch {
                debugPrint("Error fetching composed food items for category: \(error)")
            }
        }
        
        return hasRelatedItems
    }
    
    
}

// MARK: Generated accessors for foodItem
extension FoodCategory {

    @objc(addFoodItemObject:)
    @NSManaged public func addToFoodItems(_ value: FoodItem)

    @objc(removeFoodItemObject:)
    @NSManaged public func removeFromFoodItems(_ value: FoodItem)

    @objc(addFoodItem:)
    @NSManaged public func addToFoodItems(_ values: NSSet)

    @objc(removeFoodItem:)
    @NSManaged public func removeFromFoodItems(_ values: NSSet)

}

// MARK: Generated accessors for composedFoodItem
extension FoodCategory {

    @objc(addComposedFoodItemObject:)
    @NSManaged public func addToComposedFoodItems(_ value: ComposedFoodItem)

    @objc(removeComposedFoodItemObject:)
    @NSManaged public func removeFromComposedFoodItems(_ value: ComposedFoodItem)

    @objc(addComposedFoodItem:)
    @NSManaged public func addToComposedFoodItems(_ values: NSSet)

    @objc(removeComposedFoodItem:)
    @NSManaged public func removeFromComposedFoodItems(_ values: NSSet)

}

extension FoodCategory : Identifiable {
    public static func == (lhs: FoodCategory, rhs: FoodCategory) -> Bool {
        lhs.id == rhs.id
    }
}
