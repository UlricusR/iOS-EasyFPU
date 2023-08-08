//
//  Ingredient1ToIngredient2MigrationPolicy.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 07/08/2023.
//  Copyright © 2023 Ulrich Rüth. All rights reserved.
//

import Foundation
import CoreData

final class Ingredient1ToIngredient2MigrationPolicy: NSEntityMigrationPolicy {
    /**
     Tries to find the FoodItem for the source Ingredient.
     If a FoodItem is found, a destination Ingredient is created and related to the FoodItem.
     If no FoodItem is found, no destination Ingredient is created.
     */
    override func createDestinationInstances(forSource sourceIngredient: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        // Check if we deal with an Ingredient as source
        if sourceIngredient.entity.name == "Ingredient" {
            // Set up the request to FoodItem entity
            let foodItemRequest = NSFetchRequest<NSManagedObject>(entityName: "FoodItem")
            let context = manager.sourceContext
            let results = try context.fetch(foodItemRequest)
            
            // Search for matching FoodItem
            for foodItem in results {
                if isEqual(ingredient: sourceIngredient, foodItem: foodItem) {
                    // Related FoodItem found, so that we can create the destinationIngredient now
                    try super.createDestinationInstances(forSource: sourceIngredient, in: mapping, manager: manager)
                    
                    // Get the destinationIngredient
                    guard let destinationIngredient = manager.destinationInstances(forEntityMappingName: mapping.name, sourceInstances: [sourceIngredient]).first else {
                        fatalError("Was expecting an Ingredient")
                    }
                    
                    // Assign FoodItem to the Ingredient
                    destinationIngredient.setValue(foodItem, forKey: "foodItem")
                    
                    // Create the inverse relationship from the FoodItem to the Ingredient
                    var ingredients = Set<Ingredient>()
                    if let existingIngredients = foodItem.value(forKey: "ingredients") {
                        // Add existing ingredients
                        let existingIngredientsSet = existingIngredients as! NSSet
                        existingIngredientsSet.forEach({ ingredient in
                            ingredients.insert(ingredient as! Ingredient)
                        })
                    }
                    
                    // Add the new ingredient
                    ingredients.insert(sourceIngredient as! Ingredient)
                    
                    // Add the ingredients to the FoodItem
                    foodItem.setValue(ingredients, forKey: "ingredients")
                    
                    // Step out of the for-in loop, as we have found a FoodItem
                    break
                }
            }
        }
    }
    
    private func isEqual(ingredient: NSManagedObject, foodItem: NSManagedObject) -> Bool {
        let ingredientName = ingredient.primitiveValue(forKey: "name") as? String
        let ingredientCalories = ingredient.primitiveValue(forKey: "caloriesPer100g") as? Double
        let ingredientCarbs = ingredient.primitiveValue(forKey: "carbsPer100g") as? Double
        let ingredientSugars = ingredient.primitiveValue(forKey: "sugarsPer100g") as? Double
        let foodItemName = foodItem.primitiveValue(forKey: "name") as? String
        let foodItemCalories = foodItem.primitiveValue(forKey: "caloriesPer100g") as? Double
        let foodItemCarbs = foodItem.primitiveValue(forKey: "carbsPer100g") as? Double
        let foodItemSugars = foodItem.primitiveValue(forKey: "sugarsPer100g") as? Double
        
        return ingredientName == foodItemName && ingredientCalories == foodItemCalories && ingredientCarbs == foodItemCarbs && ingredientSugars == foodItemSugars
    }
}
