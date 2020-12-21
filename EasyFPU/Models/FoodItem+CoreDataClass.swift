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
    
    static func create(from foodItemVM: FoodItemViewModel) -> FoodItem {
        let moc = AppDelegate.viewContext
        
        // Create the FoodItem
        let cdFoodItem = FoodItem(context: moc)
        
        // Fill data
        cdFoodItem.name = foodItemVM.name
        cdFoodItem.category = foodItemVM.category.rawValue
        cdFoodItem.caloriesPer100g = foodItemVM.caloriesPer100g
        cdFoodItem.carbsPer100g = foodItemVM.carbsPer100g
        cdFoodItem.sugarsPer100g = foodItemVM.sugarsPer100g
        cdFoodItem.favorite = foodItemVM.favorite
        cdFoodItem.id = foodItemVM.id ?? UUID()
        
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
        
        return cdFoodItem
    }
    
    static func create(from ingredient: Ingredient) -> FoodItem {
        let moc = AppDelegate.viewContext
        
        // Create the FoodItem
        let cdFoodItem = FoodItem(context: moc)
        
        // Fill data
        cdFoodItem.name = ingredient.name
        cdFoodItem.category = ingredient.category
        cdFoodItem.caloriesPer100g = ingredient.caloriesPer100g
        cdFoodItem.carbsPer100g = ingredient.carbsPer100g
        cdFoodItem.sugarsPer100g = ingredient.sugarsPer100g
        cdFoodItem.favorite = ingredient.favorite
        cdFoodItem.id = UUID()
        cdFoodItem.composedFoodItem = ingredient.composedFoodItem
        
        // Save new food item
        try? moc.save()
        
        return cdFoodItem
    }
    
    static func create(from composedFoodItem: ComposedFoodItemViewModel, generateTypicalAmounts: Bool) -> FoodItem {
        debugPrint(AppDelegate.persistentContainer.persistentStoreDescriptions) // The location of the .sqlite file
        let moc = AppDelegate.viewContext
        
        // Create new FoodItem
        let cdFoodItem = FoodItem(context: moc)
        cdFoodItem.id = UUID()
        
        // Fill data
        cdFoodItem.name = composedFoodItem.name
        cdFoodItem.caloriesPer100g = composedFoodItem.caloriesPer100g
        cdFoodItem.carbsPer100g = composedFoodItem.carbsPer100g
        cdFoodItem.sugarsPer100g = composedFoodItem.sugarsPer100g
        cdFoodItem.favorite = composedFoodItem.favorite
        cdFoodItem.composedFoodItem = composedFoodItem.cdComposedFoodItem
        
        // Set category to product
        cdFoodItem.category = FoodItemCategory.product.rawValue
        
        // Add typical amounts
        if generateTypicalAmounts {
            // Then add the newly generated ones
            for typicalAmount in composedFoodItem.typicalAmounts {
                let newCDTypicalAmount = TypicalAmount.create(from: typicalAmount)
                cdFoodItem.addToTypicalAmounts(newCDTypicalAmount)
            }
        }
        
        // Save new food item and refresh
        try? moc.save()
        
        return cdFoodItem
    }
    
    static func update(_ cdFoodItem: FoodItem?, with foodItemVM: FoodItemViewModel) {
        let moc = AppDelegate.viewContext
        var foodItem: FoodItem
        if cdFoodItem != nil {
            foodItem = cdFoodItem!
        } else {
            foodItem = FoodItem(context: moc)
            foodItem.id = UUID()
        }
        foodItem.name = foodItemVM.name
        foodItem.category = foodItemVM.category.rawValue
        foodItem.favorite = foodItemVM.favorite
        foodItem.carbsPer100g = foodItemVM.carbsPer100g
        foodItem.caloriesPer100g = foodItemVM.caloriesPer100g
        foodItem.sugarsPer100g = foodItemVM.sugarsPer100g
        
        // Update typical amounts
        for typicalAmountVM in foodItemVM.typicalAmounts {
            let cdTypicalAmount = TypicalAmount.update(with: typicalAmountVM)
            foodItem.addToTypicalAmounts(cdTypicalAmount)
        }
        
        try? AppDelegate.viewContext.save()
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
    
    static func add(_ typicalAmount: TypicalAmount, to foodItem: FoodItem) {
        foodItem.addToTypicalAmounts(typicalAmount)
        try? AppDelegate.viewContext.save()
    }
    
    static func remove(_ typicalAmountVMs: [TypicalAmountViewModel], from foodItem: FoodItem) {
        let moc = AppDelegate.viewContext
        
        // Remove deleted typical amounts
        for typicalAmountToBeDeleted in typicalAmountVMs {
            if typicalAmountToBeDeleted.cdTypicalAmount != nil {
                typicalAmountToBeDeleted.cdTypicalAmount!.foodItem = nil
                foodItem.removeFromTypicalAmounts(typicalAmountToBeDeleted.cdTypicalAmount!)
                moc.delete(typicalAmountToBeDeleted.cdTypicalAmount!)
            }
        }
        
        try? moc.save()
    }
    
    static func setCategory(_ foodItem: FoodItem?, to category: String) {
        if let foodItem = foodItem {
            let moc = AppDelegate.viewContext
            foodItem.category = category
            moc.refresh(foodItem, mergeChanges: true)
            try? moc.save()
        }
    }
}
