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
     Creates a list of Ingredients from a ComposedFoodItemViewModel.

     - Parameter composedFoodItemVM: The source view model, the FoodItemViewModels of which are used as Ingredients,
     i.e., only amount and reference to Core Data FoodItem is used
     
     - Returns: A list of Ingredients, nil
     - if the VM has no ComposedFoodItem (should never be the case)
     - of if there are no FoodItems attached to the ComposedFoodItem (should never be the case)
     */
    static func create(from composedFoodItemVM: ComposedFoodItemViewModel) -> [Ingredient]? {
        // We cannot create an Ingredient if no FoodItem is available or no food item ingredients are attached
        if (composedFoodItemVM.cdComposedFoodItem == nil || composedFoodItemVM.foodItems.count == 0) {
            return nil
        }
        
        // Initialize ingredients array
        var cdIngredients = [Ingredient]()
        
        let moc = AppDelegate.viewContext
        
        for ingredient in composedFoodItemVM.foodItems {
            // We cannot create an Ingredient if we have no cdFoodItem
            if ingredient.cdFoodItem != nil {
                // Create Ingredient
                let cdIngredient = Ingredient(context: moc)
                
                // Fill data
                cdIngredient.id = UUID()
                cdIngredient.name = ingredient.name
                cdIngredient.favorite = ingredient.favorite
                cdIngredient.amount = Int64(ingredient.amount)
                cdIngredient.caloriesPer100g = ingredient.caloriesPer100g
                cdIngredient.carbsPer100g = ingredient.carbsPer100g
                cdIngredient.sugarsPer100g = ingredient.sugarsPer100g
                
                // Create 1:1 references to ComposedFoodItem
                cdIngredient.composedFoodItem = composedFoodItemVM.cdComposedFoodItem!
                
                // Save new Ingredient
                try? moc.save()
                
                cdIngredients.append(cdIngredient)
            }
        }
        
        // Return the ingredients if any
        return cdIngredients.count > 0 ? cdIngredients : nil
    }
    
    /**
     Creates new Ingredient from existing one - used to duplicate an Ingredient.
     
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
        cdIngredient.id = UUID()
        cdIngredient.name = existingIngredient.name
        cdIngredient.favorite = existingIngredient.favorite
        cdIngredient.amount = Int64(existingIngredient.amount)
        cdIngredient.caloriesPer100g = existingIngredient.caloriesPer100g
        cdIngredient.carbsPer100g = existingIngredient.carbsPer100g
        cdIngredient.sugarsPer100g = existingIngredient.sugarsPer100g
        
        // Create 1:1 references to ComposedFoodItem
        cdIngredient.composedFoodItem = newCDComposedFoodItem
        
        // Save new Ingredient
        try? moc.save()
        
        return cdIngredient
    }
}
