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
    // MARK: - Static methods for data access and manipulation
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
    
    static func new(name: String) -> ComposedFoodItem {
        let cdComposedFoodItem = ComposedFoodItem(context: CoreDataStack.viewContext)
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
     
     - Returns: A Core Data ComposedFoodItem; nil if there are no Ingredients.
     */
    static func create(from composedFoodItemVM: ComposedFoodItemViewModel) -> ComposedFoodItem? {
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
     Updates an existing Core Data ComposedFoodItem. Saves the context.
     
     - Parameters:
        - composedFoodItemVM: The source ComposedFoodItemViewModel.
     - Returns: The updated Core Data ComposedFoodItem, nil if no related Core Data ComposedFoodItem was found (shouldn't happen)
     */
    static func update(_ composedFoodItemVM: ComposedFoodItemViewModel) -> ComposedFoodItem? {
        if let cdComposedFoodItem = composedFoodItemVM.cdComposedFoodItem {
            // Update data in cdComposedFoodItem
            cdComposedFoodItem.name = composedFoodItemVM.name
            cdComposedFoodItem.foodCategory = composedFoodItemVM.foodCategory
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
            cdComposedFoodItem.foodItem?.foodCategory = composedFoodItemVM.foodCategory
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
        
        return relatedFoodItem
    }
    
    /// Duplicates the given ComposedFoodItem, including its Ingredients and related FoodItem. Saves the context.
    /// - Parameter existingComposedFoodItem: The ComposedFoodItem to be duplicated.
    /// - Returns: The duplicated ComposedFoodItem, nil if duplication failed.
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
            ComposedFoodItem.delete(cdComposedFoodItem, includeAssociatedFoodItem: false)
            
            // Save
            CoreDataStack.shared.save()
            
            return nil
        }
    }
    
    /// Deletes the given ComposedFoodItem from Core Data. Does not save the context.
    /// - Parameter composedFoodItem: The ComposedFoodItem to be deleted.
    static func delete(_ composedFoodItem: ComposedFoodItem, includeAssociatedFoodItem: Bool) {
        if includeAssociatedFoodItem {
            if let associatedFoodItem = composedFoodItem.foodItem {
                FoodItem.delete(associatedFoodItem)
            }
        }
        
        // Deletion of all related ingredients will happen automatically
        // as we have set Delete Rule to Cascade in data model
        
        // Delete the food item itself
        CoreDataStack.viewContext.delete(composedFoodItem)
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
    
    static func clear(composedFoodItem: ComposedFoodItem) {
        // Clear ingredients
        clearIngredients(composedFoodItem: composedFoodItem)
        
        // Reset values and create new UUID
        composedFoodItem.id = UUID()
        composedFoodItem.name = NSLocalizedString("Composed product", comment: "")
        composedFoodItem.favorite = false
        composedFoodItem.numberOfPortions = 0
    }
    
    /**
     Clears all ingredients and sets the amount to 0.
     */
    static func clearIngredients(composedFoodItem: ComposedFoodItem) {
        for ingredient in composedFoodItem.ingredients.allObjects as! [Ingredient] {
            ingredient.amount = 0
            composedFoodItem.removeFromIngredients(ingredient)
        }
        composedFoodItem.amount = 0
    }
    
    static func getCarbsInclSugars(composedFoodItem: ComposedFoodItem) -> Double {
        var newValue = 0.0
        for ingredient in composedFoodItem.ingredients.allObjects as! [Ingredient] {
            newValue += FoodItem.getCarbsInclSugars(ingredient: ingredient)
        }
        return newValue
    }
    
    static func getSugarsOnly(composedFoodItem: ComposedFoodItem) -> Double {
        var newValue = 0.0
        for ingredient in composedFoodItem.ingredients.allObjects as! [Ingredient] {
            newValue += FoodItem.getSugarsOnly(ingredient: ingredient)
        }
        return newValue
    }
    
    static func getRegularCarbs(composedFoodItem: ComposedFoodItem, treatSugarsSeparately: Bool) -> Double {
        treatSugarsSeparately ? getCarbsInclSugars(composedFoodItem: composedFoodItem) - getSugarsOnly(composedFoodItem: composedFoodItem) : getCarbsInclSugars(composedFoodItem: composedFoodItem)
    }
    
    static func getSugars(composedFoodItem: ComposedFoodItem, treatSugarsSeparately: Bool) -> Double {
        treatSugarsSeparately ? getSugarsOnly(composedFoodItem: composedFoodItem) : 0
    }
    
    static func fpus(composedFoodItem: ComposedFoodItem) -> FPU {
        var fpu = FPU(fpu: 0.0)
        for ingredient in composedFoodItem.ingredients.allObjects as! [Ingredient] {
            let tempFPU = fpu.fpu
            fpu = FPU(fpu: tempFPU + FoodItem.getFPU(ingredient: ingredient).fpu)
        }
        return fpu
    }
}
