//
//  FoodItem+CoreDataClass.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 17.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//
//

import Foundation
import CoreData


public class FoodItem: NSManagedObject {
    enum IngredientsSyncStrategy {
        case createMissingFoodItems, removeNonExistingIngredients
    }
    
    static func fetchAll(viewContext: NSManagedObjectContext = AppDelegate.viewContext) -> [FoodItem] {
        let request: NSFetchRequest<FoodItem> = FoodItem.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        guard let foodItems = try? AppDelegate.viewContext.fetch(request) else {
            return []
        }
        return foodItems
    }
    
    static func deleteAll(viewContext: NSManagedObjectContext = AppDelegate.viewContext) {
        FoodItem.fetchAll(viewContext: viewContext).forEach({
            viewContext.delete($0)
        })
        
        try? viewContext.save()
    }
    
    static func create(from foodItemVM: FoodItemViewModel) {
        let moc = AppDelegate.viewContext
        
        // Create the FoodItem
        let cdFoodItem = FoodItem(context: moc)
        
        // Fill data
        cdFoodItem.name = foodItemVM.name
        cdFoodItem.category = foodItemVM.category.rawValue
        cdFoodItem.amount = Int64(foodItemVM.amount)
        cdFoodItem.caloriesPer100g = foodItemVM.caloriesPer100g
        cdFoodItem.carbsPer100g = foodItemVM.carbsPer100g
        cdFoodItem.sugarsPer100g = foodItemVM.sugarsPer100g
        cdFoodItem.favorite = foodItemVM.favorite
        cdFoodItem.id = UUID()
        
        // Add typical amounts
        for typicalAmount in foodItemVM.typicalAmounts {
            let newCDTypicalAmount = TypicalAmount.create(from: typicalAmount)
            cdFoodItem.addToTypicalAmounts(newCDTypicalAmount)
        }
        
        // Add ComposedFoodItem if available
        if let cdComposedFoodItem = foodItemVM.cdComposedFoodItem {
            cdFoodItem.composedFoodItem = cdComposedFoodItem
        }
        
        // Save new food item
        try? moc.save()
    }
    
    static func create(from ingredient: Ingredient) {
        let moc = AppDelegate.viewContext
        
        // Create the FoodItem
        let cdFoodItem = FoodItem(context: moc)
        
        // Fill data
        cdFoodItem.name = ingredient.name
        cdFoodItem.category = ingredient.category
        cdFoodItem.amount = ingredient.amount
        cdFoodItem.caloriesPer100g = ingredient.caloriesPer100g
        cdFoodItem.carbsPer100g = ingredient.carbsPer100g
        cdFoodItem.sugarsPer100g = ingredient.sugarsPer100g
        cdFoodItem.favorite = ingredient.favorite
        cdFoodItem.id = UUID()
        cdFoodItem.composedFoodItem = ingredient.composedFoodItem
        
        // Save new food item
        try? moc.save()
    }
    
    static func delete(_ foodItem: FoodItem) {
        let moc = AppDelegate.viewContext
        
        // Deletion of all related typical amounts will happen automatically
        // as we have set Delete Rule to Cascade in data model
        
        // Delete the food item itself
        moc.delete(foodItem)
        
        // And save the context
        try? moc.save()
    }
    
    static func checkForMissingFoodItems(of ingredients: [Ingredient]) -> [Ingredient] {
        var ingredientsWithoutFoodItems = [Ingredient]()
        for ingredient in ingredients {
            if ingredient.foodItem == nil {
                ingredientsWithoutFoodItems.append(ingredient)
            }
        }
        return ingredientsWithoutFoodItems
    }
    
    static func setFoodItems(from ingredients: [Ingredient], syncStrategy: IngredientsSyncStrategy) {
        // First set all amounts to zero
        let predicate = NSPredicate(format: "category = %@ AND amount > 0", FoodItemCategory.ingredient.rawValue)
        let request: NSFetchRequest<FoodItem> = FoodItem.fetchRequest()
        request.predicate = predicate
        if let foodItemsToBeSetToZero = try? AppDelegate.viewContext.fetch(request) {
            for foodItemToBeSetToZero in foodItemsToBeSetToZero {
                foodItemToBeSetToZero.amount = 0
            }
        }
        
        // Then load ingredients and set food items
        for ingredient in ingredients {
            if let foodItem = ingredient.foodItem {
                foodItem.category = FoodItemCategory.ingredient.rawValue
                foodItem.amount = ingredient.amount
            } else if syncStrategy == .createMissingFoodItems {
                FoodItem.create(from: ingredient)
            }
        }
    }
}
