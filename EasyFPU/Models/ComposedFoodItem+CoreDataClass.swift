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
    
    /**
     Creates a new ComposedFoodItem from the ComposedFoodItemViewModel.
     Creates the Ingredients and relates them to the new ComposedFoodItem.
     Also creates a new FoodItem and relates it to the new ComposedFoodItem.
     Does not relate the Core Data ComposedFoodItem to the passed ComposedFoodItemViewModel.
     
     - Parameter composedFoodItemVM: The source view model.
     
     - Returns: A Core Data ComposedFoodItem; nil if there are no Ingredients.
     */
    static func create(from composedFoodItemVM: ComposedFoodItemViewModel) -> ComposedFoodItem? {
        // Create new ComposedFoodItem
        let cdComposedFoodItem = ComposedFoodItem(context: CoreDataStack.viewContext)
        
        // Use the ID of the ComposedFoodItemViewModel
        cdComposedFoodItem.id = composedFoodItemVM.id
        
        // Fill data
        cdComposedFoodItem.name = composedFoodItemVM.name
        cdComposedFoodItem.foodCategory = composedFoodItemVM.foodCategoryVM?.cdFoodCategory
        cdComposedFoodItem.favorite = composedFoodItemVM.favorite
        cdComposedFoodItem.amount = Int64(composedFoodItemVM.amount)
        cdComposedFoodItem.numberOfPortions = Int16(composedFoodItemVM.numberOfPortions)
        
        // Save new composed food item
        CoreDataStack.shared.save()
        
        // Check for ingredients - there must be ingredients!
        if Ingredient.create(from: composedFoodItemVM, relateTo: cdComposedFoodItem) != nil {
            // Create a related FoodItem and relate it to the ComposedFoodItem
            cdComposedFoodItem.foodItem = FoodItem.create(from: composedFoodItemVM)
            
            // Save new composed food item
            CoreDataStack.shared.save()
            
            // Return the ComposedFoodItem
            return cdComposedFoodItem
        } else {
            // There are no ingredients, therefore we delete it again and return nil
            CoreDataStack.viewContext.delete(cdComposedFoodItem)
            CoreDataStack.shared.save()
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
            // Update data in cdComposedFoodItem
            cdComposedFoodItem.name = composedFoodItemVM.name
            cdComposedFoodItem.foodCategory = composedFoodItemVM.foodCategoryVM?.cdFoodCategory
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
            cdComposedFoodItem.foodItem?.foodCategory = composedFoodItemVM.foodCategoryVM?.cdFoodCategory
            cdComposedFoodItem.foodItem?.favorite = composedFoodItemVM.favorite
            cdComposedFoodItem.foodItem?.caloriesPer100g = composedFoodItemVM.caloriesPer100g
            cdComposedFoodItem.foodItem?.carbsPer100g = composedFoodItemVM.carbsPer100g
            cdComposedFoodItem.foodItem?.sugarsPer100g = composedFoodItemVM.sugarsPer100g
            
            // Delete the existing Ingredients
            for ingredient in cdComposedFoodItem.ingredients {
                if let ingredientToBeDeleted = ingredient as? NSManagedObject {
                    CoreDataStack.viewContext.delete(ingredientToBeDeleted)
                    CoreDataStack.shared.save()
                    
                }
            }
            
            // Add new ingredients
            _ = Ingredient.create(from: composedFoodItemVM, relateTo: cdComposedFoodItem)
            
            // Delete the existing TypicalAmounts
            if let existingTypicalAmounts = cdComposedFoodItem.foodItem?.typicalAmounts {
                for typicalAmount in existingTypicalAmounts {
                    if let typicalAmountToBeDeleted = typicalAmount as? NSManagedObject {
                        CoreDataStack.viewContext.delete(typicalAmountToBeDeleted)
                        CoreDataStack.shared.save()
                    }
                }
            }
            
            // Add the new TypicalAmounts
            if let cdFoodItem = cdComposedFoodItem.foodItem {
                for typicalAmount in composedFoodItemVM.typicalAmounts {
                    cdFoodItem.addToTypicalAmounts(TypicalAmount.create(from: typicalAmount))
                }
            }
            
            // Save
            CoreDataStack.shared.save()
            
            return cdComposedFoodItem
        } else {
            // No Core Data ComposedFoodItem found - this should never happen!
            return nil
        }
    }
    
    /// Updates the nutritional value of the FoodItem related to the ComposedFoodItem.
    /// - Parameter composedFoodItem: The ComposedFoodItem, the FoodItem of which should be updated.
    /// - Returns: The updated FoodItem, nil if no related FoodItem was found (should never happen).
    static func updateRelatedFoodItem(_ composedFoodItem: ComposedFoodItem) -> FoodItem? {
        // Find the related FoodItem
        guard let relatedFoodItem = composedFoodItem.foodItem else { return nil }
        
        var calories: Double = 0.0
        var carbs: Double = 0.0
        var sugars: Double = 0.0
        
        // Iterate through ingredients and calculate the updated nutritional values
        for case let ingredient as Ingredient in composedFoodItem.ingredients {
            calories += ingredient.caloriesPer100g * Double(ingredient.amount)
            carbs += ingredient.carbsPer100g * Double(ingredient.amount)
            sugars += ingredient.sugarsPer100g * Double(ingredient.amount)
        }
        
        relatedFoodItem.caloriesPer100g = calories / Double(composedFoodItem.amount)
        relatedFoodItem.carbsPer100g = carbs / Double(composedFoodItem.amount)
        relatedFoodItem.sugarsPer100g = sugars / Double(composedFoodItem.amount)
        
        CoreDataStack.shared.save()
        
        return relatedFoodItem
    }
    
    static func duplicate(_ existingComposedFoodItem: ComposedFoodItem) -> ComposedFoodItem? {
        // Create new ComposedFoodItem with new ID
        let cdComposedFoodItem = ComposedFoodItem(context: CoreDataStack.viewContext)
        cdComposedFoodItem.id = UUID()
        
        // Fill data
        cdComposedFoodItem.name = existingComposedFoodItem.name + NSLocalizedString(" - Copy", comment: "")
        cdComposedFoodItem.foodCategory = existingComposedFoodItem.foodCategory
        cdComposedFoodItem.favorite = existingComposedFoodItem.favorite
        cdComposedFoodItem.amount = existingComposedFoodItem.amount
        cdComposedFoodItem.numberOfPortions = existingComposedFoodItem.numberOfPortions
        
        // Save
        CoreDataStack.shared.save()
        
        // Create ingredients
        for case let ingredient as Ingredient in existingComposedFoodItem.ingredients {
            _ = Ingredient.duplicate(ingredient, for: cdComposedFoodItem)
        }
        
        // Create related FoodItem
        if let existingFoodItem = existingComposedFoodItem.foodItem {
            cdComposedFoodItem.foodItem = FoodItem.duplicate(existingFoodItem)
            
            // Save
            CoreDataStack.shared.save()
            
            return cdComposedFoodItem
        } else {
            // No existing FoodItem found to duplicate - this should not happen
            // Delete composedFoodItem again
            ComposedFoodItem.delete(cdComposedFoodItem)
            
            return nil
        }
    }
    
    static func delete(_ composedFoodItem: ComposedFoodItem) {
        // Deletion of all related ingredients will happen automatically
        // as we have set Delete Rule to Cascade in data model
        
        // Delete the food item itself
        CoreDataStack.viewContext.delete(composedFoodItem)
        
        // And save the context
        CoreDataStack.shared.save()
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
    static func getComposedFoodItemByName(name: String) -> ComposedFoodItem? {
        let predicate = NSPredicate(format: "name == %@", name)
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
}
