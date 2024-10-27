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
     - isImport: If true, a new FoodItem is created for each ingredient, otherwise an existing FoodItem is expected.
     
     - Returns: A list of Ingredients, nil
     - if the VM has no ComposedFoodItem (should never be the case)
     - of if there are no FoodItems attached to the ComposedFoodItem (should never be the case)
     */
    static func create(
        from composedFoodItemVM: ComposedFoodItemViewModel,
        relateTo cdComposedFoodItem: ComposedFoodItem,
        isImport: Bool = false
    ) -> [Ingredient]? {
        // We cannot create an Ingredient if no food item ingredients are attached
        if (composedFoodItemVM.foodItemVMs.count == 0) {
            return nil
        }
        
        // Initialize ingredients array
        var cdIngredients = [Ingredient]()
        
        for foodItemVM in composedFoodItemVM.foodItemVMs {
            // In case of an import, there might be no Core Data FoodItem for the ingredient yet
            if isImport {
                // Get existing or new FoodItem
                let relatedFoodItem = FoodItem.create(from: foodItemVM, allowDuplicate: false)
                foodItemVM.cdFoodItem = relatedFoodItem
                
                // Save
                CoreDataStack.shared.save()
            }
            
            // If no import: We cannot create an Ingredient if we have no cdFoodItem
            if let associatedCDFoodItem = foodItemVM.cdFoodItem {
                // Create Ingredient
                let cdIngredient = Ingredient(context: CoreDataStack.viewContext)
                
                // Fill data
                cdIngredient.id = UUID()
                cdIngredient.relatedFoodItemID = associatedCDFoodItem.id // The id of the related FoodItem
                cdIngredient.name = foodItemVM.name
                cdIngredient.favorite = foodItemVM.favorite
                cdIngredient.amount = Int64(foodItemVM.amount)
                cdIngredient.caloriesPer100g = foodItemVM.caloriesPer100g
                cdIngredient.carbsPer100g = foodItemVM.carbsPer100g
                cdIngredient.sugarsPer100g = foodItemVM.sugarsPer100g
                
                // Create 1:1 references to ComposedFoodItem and FoodItem
                cdIngredient.composedFoodItem = cdComposedFoodItem
                cdIngredient.foodItem = associatedCDFoodItem
                
                cdIngredients.append(cdIngredient)
                
                // Save
                CoreDataStack.shared.save()
            }
        }
        
        // Create and add ingredients
        cdComposedFoodItem.addToIngredients(NSSet(array: cdIngredients))
        
        // Save
        CoreDataStack.shared.save()
        
        // Return the ingredients if any
        return cdIngredients.count > 0 ? cdIngredients : nil
    }
    
    /**
     Creates new Ingredient from existing one - used to duplicate an Ingredient.
     Contains a reference to the related FoodItem and stores the ID of this FoodItem as separate value for export/import purposes.
     
     - Parameters:
        - existingIngredient: The Ingredient to be duplicated.
        - newCDComposedFoodItem: Used to create the relationship to the Core Data ComposedFoodItem.
     
     - Returns: The new Ingredient with with a reference to the newCDComposedFoodItem.
    */
    static func duplicate(_ existingIngredient: Ingredient, for newCDComposedFoodItem: ComposedFoodItem) -> Ingredient {
        // Create Ingredient
        let cdIngredient = Ingredient(context: CoreDataStack.viewContext)
        
        // Fill data
        cdIngredient.id = UUID()
        cdIngredient.relatedFoodItemID = existingIngredient.relatedFoodItemID // The id of the related FoodItem
        cdIngredient.name = existingIngredient.name
        cdIngredient.favorite = existingIngredient.favorite
        cdIngredient.amount = Int64(existingIngredient.amount)
        cdIngredient.caloriesPer100g = existingIngredient.caloriesPer100g
        cdIngredient.carbsPer100g = existingIngredient.carbsPer100g
        cdIngredient.sugarsPer100g = existingIngredient.sugarsPer100g
        
        // Create 1:1 references to ComposedFoodItem and FoodItem
        cdIngredient.composedFoodItem = newCDComposedFoodItem
        cdIngredient.foodItem = existingIngredient.foodItem
        
        // Add to ComposedFoodItem
        newCDComposedFoodItem.addToIngredients(cdIngredient)
        
        // Save new Ingredient
        CoreDataStack.shared.save()
        
        return cdIngredient
    }
    
    /// Updates the values of the Ingredient with those of the FoodItem (but not the ID).
    /// Also updates the FoodItem of the related ComposedFoodItem.
    /// - Parameters:
    ///   - ingredient: The Ingredient to be updated.
    ///   - foodItem: The FoodItem the values are copied of.
    /// - Returns: The updated Ingredient or nil if the related FoodItem of the related ComposedFoodItem could not be found (should not happen).
    static func update(_ ingredient: Ingredient, with foodItem: FoodItem) -> Ingredient? {
        ingredient.name = foodItem.name
        ingredient.favorite = foodItem.favorite
        ingredient.caloriesPer100g = foodItem.caloriesPer100g
        ingredient.carbsPer100g = foodItem.carbsPer100g
        ingredient.sugarsPer100g = foodItem.sugarsPer100g
        
        // Update the FoodItem of the related ComposedFoodItem
        if ComposedFoodItem.updateRelatedFoodItem(ingredient.composedFoodItem) == nil {
            return nil
        }
        
        // Save
        CoreDataStack.shared.save()
        
        return ingredient
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
