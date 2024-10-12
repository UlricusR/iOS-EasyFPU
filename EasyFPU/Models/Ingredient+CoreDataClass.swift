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
    static func fetchAll(viewContext: NSManagedObjectContext = AppDelegate.viewContext) -> [Ingredient] {
        let request: NSFetchRequest<Ingredient> = Ingredient.fetchRequest()
        
        guard let ingredients = try? AppDelegate.viewContext.fetch(request) else {
            return []
        }
        return ingredients
    }
    
    static func deleteAll(viewContext: NSManagedObjectContext = AppDelegate.viewContext) {
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
        if (composedFoodItemVM.foodItems.count == 0) {
            return nil
        }
        
        // Initialize ingredients array
        var cdIngredients = [Ingredient]()
        
        let moc = AppDelegate.viewContext
        
        for ingredient in composedFoodItemVM.foodItems {
            // In case of an import, there might be no Core Data FoodItem for the ingredient yet
            if isImport {
                // Get existing or new FoodItem
                let relatedFoodItem = FoodItem.create(from: ingredient, allowDuplicate: false)
                ingredient.cdFoodItem = relatedFoodItem
            }
            
            // If no import: We cannot create an Ingredient if we have no cdFoodItem
            if let associatedCDFoodItem = ingredient.cdFoodItem {
                // Create Ingredient
                let cdIngredient = Ingredient(context: moc)
                
                // Fill data
                // We use the identical UUID as the FoodItem, so that we can identify the related FoodItem later
                cdIngredient.id = associatedCDFoodItem.id // The id of the related FoodItem
                cdIngredient.name = ingredient.name
                cdIngredient.favorite = ingredient.favorite
                cdIngredient.amount = Int64(ingredient.amount)
                cdIngredient.caloriesPer100g = ingredient.caloriesPer100g
                cdIngredient.carbsPer100g = ingredient.carbsPer100g
                cdIngredient.sugarsPer100g = ingredient.sugarsPer100g
                
                // Create 1:1 references to ComposedFoodItem and FoodItem
                cdIngredient.composedFoodItem = cdComposedFoodItem
                cdIngredient.foodItem = associatedCDFoodItem
                
                cdIngredients.append(cdIngredient)
            }
        }
        
        // Create and add ingredients
        cdComposedFoodItem.addToIngredients(NSSet(array: cdIngredients))
        
        // Save
        try? moc.save()
        
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
        let moc = AppDelegate.viewContext
        
        // Create Ingredient
        let cdIngredient = Ingredient(context: moc)
        
        // Fill data
        cdIngredient.id = existingIngredient.id // The id of the related FoodItem
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
        try? moc.save()
        
        return cdIngredient
    }
}
