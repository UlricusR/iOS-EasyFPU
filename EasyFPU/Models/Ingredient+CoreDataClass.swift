//
//  Ingredient+CoreDataClass.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 05.11.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//
//

import Foundation
import CoreData


public class Ingredient: NSManagedObject {
    
    //
    // MARK: - Static methods for entity creation/deletion/fetching
    //
    
    static func fetchAll(viewContext: NSManagedObjectContext = CoreDataStack.viewContext) -> [Ingredient] {
        let request: NSFetchRequest<Ingredient> = Ingredient.fetchRequest()
        
        guard let ingredients = try? CoreDataStack.viewContext.fetch(request) else {
            return []
        }
        return ingredients
    }
    
    static func deleteAll(viewContext: NSManagedObjectContext = CoreDataStack.viewContext) {
        Ingredient.fetchAll(viewContext: viewContext).forEach({
            viewContext.delete($0)
        })
        
        try? viewContext.save()
    }
    
    /**
     Creates a list of Ingredients from a ComposedFoodItemViewModel and relates it to the Core Data ComposedFoodItem
     Contains a reference to the related FoodItem and stores the ID of this FoodItem as separate value for export/import purposes.

     - Parameter composedFoodItemVM: The source view model, the FoodItemViewModels of which are used as Ingredients,
     i.e., only amount and reference to Core Data FoodItem is used
     - cdComposedFoodItem: The Core Data ComposedFoodItem to relate the Ingredients to.
     - saveContext: Whether to permanently save the changes to the core data stack.
     
     - Returns: A list of Ingredients, nil
     - if the VM has no ComposedFoodItem (should never be the case)
     - of if there are no FoodItems attached to the ComposedFoodItem (should never be the case)
     */
    static func create(
        from composedFoodItemVM: ComposedFoodItemViewModel,
        relateTo cdComposedFoodItem: ComposedFoodItem,
        saveContext: Bool
    ) -> [Ingredient]? {
        // We cannot create an Ingredient if no food item ingredients are attached
        if (composedFoodItemVM.ingredients.count == 0) {
            return nil
        }
        
        // Initialize ingredients array
        var cdIngredients = [Ingredient]()
        
        for foodItemVM in composedFoodItemVM.ingredients {
            var cdFoodItem: FoodItem? = nil
            
            // We need a related cdFoodItem - try to get an existing one first
            if let existingCDFoodItem = FoodItem.getFoodItemByID(id: foodItemVM.id) {
                // There is an existing FoodItem with identical ID, so check the nutritional values
                if FoodItemViewModel.hasSameNutritionalValues(lhs: existingCDFoodItem, rhs: foodItemVM) {
                    // The nutritional values are identical, so relate it to the foodItemVM
                    cdFoodItem = existingCDFoodItem
                } else {
                    // Although there is a FoodItem with the same ID, the nutritional values are not identical.
                    // We better create a new one (next step below), but it requires a new UUID
                    foodItemVM.id = UUID()
                }
            }
            
            // If there's still no related FoodItem, we need to create a new one
            if cdFoodItem == nil {
                cdFoodItem = FoodItem.create(from: foodItemVM, saveContext: saveContext)
            }
            
            // Create Ingredient
            let cdIngredient = Ingredient(context: CoreDataStack.viewContext)
            
            // Fill data
            cdIngredient.id = UUID()
            cdIngredient.relatedFoodItemID = cdFoodItem!.id // The id of the related FoodItem
            cdIngredient.name = foodItemVM.name
            cdIngredient.favorite = foodItemVM.favorite
            cdIngredient.amount = Int64(foodItemVM.amount)
            cdIngredient.caloriesPer100g = foodItemVM.caloriesPer100g
            cdIngredient.carbsPer100g = foodItemVM.carbsPer100g
            cdIngredient.sugarsPer100g = foodItemVM.sugarsPer100g
            
            // Create 1:1 references to ComposedFoodItem and FoodItem
            cdIngredient.composedFoodItem = cdComposedFoodItem
            cdIngredient.foodItem = cdFoodItem!
            
            cdIngredients.append(cdIngredient)
        }
        
        // Create and add ingredients
        cdComposedFoodItem.addToIngredients(NSSet(array: cdIngredients))
        
        // Save
        if saveContext {
            CoreDataStack.shared.save()
        }
        
        // Return the ingredients if any
        return cdIngredients.count > 0 ? cdIngredients : nil
    }
    
    /// Creates new Ingredient from FoodItem. Does not save the context.
    /// - Parameter foodItem: The FoodItem to create the Ingredient from.
    static func create(from foodItem: FoodItem) -> Ingredient {
        let cdIngredient = Ingredient(context: CoreDataStack.viewContext)
        
        // Fill data
        cdIngredient.id = UUID()
        cdIngredient.relatedFoodItemID = foodItem.id // The id of the related FoodItem
        cdIngredient.name = foodItem.name
        cdIngredient.favorite = foodItem.favorite
        cdIngredient.amount = 0 // Default amount
        cdIngredient.caloriesPer100g = foodItem.caloriesPer100g
        cdIngredient.carbsPer100g = foodItem.carbsPer100g
        cdIngredient.sugarsPer100g = foodItem.sugarsPer100g
        
        // Create 1:1 reference to FoodItem
        cdIngredient.foodItem = foodItem
        
        return cdIngredient
    }
    
    /**
     Returns the Core Data Ingredient with the given id.
     
     - Parameter id: The Core Data entry id.
     
     - Returns: The related Core Data Ingredient, nil if not found.
     */
    static func getIngredientByID(id: UUID) -> Ingredient? {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        let request: NSFetchRequest<Ingredient> = Ingredient.fetchRequest()
        request.predicate = predicate
        do {
            let result = try CoreDataStack.viewContext.fetch(request)
            if !result.isEmpty {
                return result[0]
            }
        } catch {
            debugPrint("Error fetching ingredient: \(error)")
        }
        return nil
    }
}
