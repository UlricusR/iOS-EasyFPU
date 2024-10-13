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
    
    /**
     Creates a new Core Data FoodItem.
     
     - Parameters:
        - foodItedVM: the source FoodItemViewModel.
        - allowDuplicate: if true, duplicates are allowed, but they will get their own UUID.
     
     - Returns: the new Core Data FoodItem, or the existing one if a duplicate was found and is not allowed.
     */
    static func create(from foodItemVM: FoodItemViewModel, allowDuplicate: Bool) -> FoodItem {
        let existingFoodItem = FoodItem.getFoodItemByID(foodItemVM.id.uuidString)
        if !allowDuplicate && existingFoodItem != nil {
            return existingFoodItem!
        }
        
        // Create the FoodItem
        let moc = AppDelegate.viewContext
        let cdFoodItem = FoodItem(context: moc)
        
        // If we have a duplicate, then a new UUID is required
        cdFoodItem.id = existingFoodItem != nil ? UUID() : foodItemVM.id
        
        // Fill data
        cdFoodItem.name = foodItemVM.name
        cdFoodItem.category = foodItemVM.category.rawValue
        cdFoodItem.caloriesPer100g = foodItemVM.caloriesPer100g
        cdFoodItem.carbsPer100g = foodItemVM.carbsPer100g
        cdFoodItem.sugarsPer100g = foodItemVM.sugarsPer100g
        cdFoodItem.favorite = foodItemVM.favorite
        
        // Save
        try? moc.save()
        
        // Add typical amounts
        for typicalAmount in foodItemVM.typicalAmounts {
            let newCDTypicalAmount = TypicalAmount.create(from: typicalAmount)
            cdFoodItem.addToTypicalAmounts(newCDTypicalAmount)
        }
        
        // Save
        try? moc.save()
        return cdFoodItem
    }
    
    /**
     Creates a new Core Data FoodItem from a ComposedFoodItemViewModel.
     First checks if a Core Data FoodItem with the same ID exists, otherwise creates a new one with the ID of the ComposedFoodItemViewModel.
     It does not create a relationship to a ComposedFoodItem. This needs to be created manually.
     
     - Parameters:
        - composedFoodItem: The source ComposedFoodItemViewModel.
        - generateTypicalAmounts: If true, TypicalAmounts will be added to the FoodItem.
     
     - Returns: The existing Core Data FoodItem if found, otherwise a new one.
     */
    static func create(from composedFoodItem: ComposedFoodItemViewModel) -> FoodItem {
        // Return the existing Core Data FoodItem, if found
        if let existingFoodItem = FoodItem.getFoodItemByID(composedFoodItem.id.uuidString) {
            return existingFoodItem
        }
        
        let moc = AppDelegate.viewContext
        
        // Create new FoodItem
        let cdFoodItem = FoodItem(context: moc)
        cdFoodItem.id = composedFoodItem.id
        
        // Fill data
        cdFoodItem.name = composedFoodItem.name
        cdFoodItem.caloriesPer100g = composedFoodItem.caloriesPer100g
        cdFoodItem.carbsPer100g = composedFoodItem.carbsPer100g
        cdFoodItem.sugarsPer100g = composedFoodItem.sugarsPer100g
        cdFoodItem.favorite = composedFoodItem.favorite
        
        // Set category to product
        cdFoodItem.category = FoodItemCategory.product.rawValue
        
        // Add typical amounts
        if composedFoodItem.numberOfPortions > 0 {
            for typicalAmount in composedFoodItem.typicalAmounts {
                let newCDTypicalAmount = TypicalAmount.create(from: typicalAmount)
                cdFoodItem.addToTypicalAmounts(newCDTypicalAmount)
            }
        }
        
        // Save new food item and refresh
        try? moc.save()
        
        return cdFoodItem
    }
    
    /**
     Updates a Core Data FoodItem with the values from a FoodItemViewModel.
     If related to one or more Ingredients, their values will also be updated.
     
     - Parameters:
        - cdFoodItem: The Core Data FoodItem to be updated.
        - foodItemVM: The source FoodItemViewModel.
        - typicalAmountsToBeDeleted: The TypicalAmounts to be deleted from the FoodItem.
     */
    static func update(_ cdFoodItem: FoodItem, with foodItemVM: FoodItemViewModel, _ typicalAmountsToBeDeleted: [TypicalAmountViewModel]) {
        let moc = AppDelegate.viewContext
        cdFoodItem.name = foodItemVM.name
        cdFoodItem.category = foodItemVM.category.rawValue
        cdFoodItem.favorite = foodItemVM.favorite
        cdFoodItem.carbsPer100g = foodItemVM.carbsPer100g
        cdFoodItem.caloriesPer100g = foodItemVM.caloriesPer100g
        cdFoodItem.sugarsPer100g = foodItemVM.sugarsPer100g
        
        // Get the related ingredients and update their values
        let relatedIngredients = cdFoodItem.ingredients?.allObjects as? [Ingredient] ?? []
        for ingredient in relatedIngredients {
            _ = Ingredient.update(ingredient, with: cdFoodItem)
        }
        
        // Remove deleted typical amounts
        for typicalAmountToBeDeleted in typicalAmountsToBeDeleted {
            if typicalAmountToBeDeleted.cdTypicalAmount != nil {
                cdFoodItem.removeFromTypicalAmounts(typicalAmountToBeDeleted.cdTypicalAmount!)
                moc.delete(typicalAmountToBeDeleted.cdTypicalAmount!)
            }
        }
        
        // Update typical amounts
        for typicalAmountVM in foodItemVM.typicalAmounts {
            let cdTypicalAmount = TypicalAmount.update(with: typicalAmountVM)
            cdFoodItem.addToTypicalAmounts(cdTypicalAmount)
        }
        
        try? moc.save()
    }
    
    /**
     Duplicates the FoodItem represented by the existingFoodItemVM
     
     - Parameters:
        - existingFoodItemVM: the FoodItemViewModel to be duplicated
     
     - Returns: the new Core Data FoodItem, nil should never happen
     */
    static func duplicate(_ existingFoodItem: FoodItem) -> FoodItem? {
        let moc = AppDelegate.viewContext
        
        // Create new FoodItem with own ID
        let cdFoodItem = FoodItem(context: moc)
        cdFoodItem.id = UUID()
        
        // Fill data
        cdFoodItem.name = (existingFoodItem.name) + NSLocalizedString(" - Copy", comment: "")
        cdFoodItem.caloriesPer100g = existingFoodItem.caloriesPer100g
        cdFoodItem.carbsPer100g = existingFoodItem.carbsPer100g
        cdFoodItem.sugarsPer100g = existingFoodItem.sugarsPer100g
        cdFoodItem.favorite = existingFoodItem.favorite
        cdFoodItem.category = existingFoodItem.category
        
        // Add typical amounts
        if let typicalAmounts = existingFoodItem.typicalAmounts {
            for case let typicalAmount as TypicalAmount in typicalAmounts {
                let newCDTypicalAmount = TypicalAmount(context: moc)
                newCDTypicalAmount.id = UUID()
                newCDTypicalAmount.amount = typicalAmount.amount
                newCDTypicalAmount.comment = typicalAmount.comment
                cdFoodItem.addToTypicalAmounts(newCDTypicalAmount)
            }
        }
        
        // Save new food item and refresh
        try? moc.save()
        
        return cdFoodItem
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
    
    /**
     Adds a TypicalAmount to a FoodItem.
     
     - Parameters:
        - typicalAmount: The Core Data TypicalAmount to add.
        - foodItem: The Core Data FoodItem the TypicalAmount should be added to.
     */
    static func add(_ typicalAmount: TypicalAmount, to foodItem: FoodItem) {
        foodItem.addToTypicalAmounts(typicalAmount)
        try? AppDelegate.viewContext.save()
    }
    
    static func setCategory(_ foodItem: FoodItem?, to category: String) {
        if let foodItem = foodItem {
            let moc = AppDelegate.viewContext
            foodItem.category = category
            moc.refresh(foodItem, mergeChanges: true)
            try? moc.save()
        }
    }
    
    /**
     Returns the Core Data FoodItem with the given id.
     
     - Parameter id: The Core Data entry id.
     
     - Returns: The related Core Data FoodItem, nil if not found.
     */
    static func getFoodItemByID(_ id: String) -> FoodItem? {
        let predicate = NSPredicate(format: "id = %@", id)
        let request: NSFetchRequest<FoodItem> = FoodItem.fetchRequest()
        request.predicate = predicate
        if let result = try? AppDelegate.viewContext.fetch(request) {
            if !result.isEmpty {
                return result[0]
            }
        }
        return nil
    }
    
    /**
     Returns the Core Data FoodItem with the given name.
     
     - Parameter name: The Core Data entry name.
     
     - Returns: The related Core Data FoodItem, nil if not found.
     */
    static func getFoodItemByName(name: String) -> FoodItem? {
        let predicate = NSPredicate(format: "name = %@", name)
        let request: NSFetchRequest<FoodItem> = FoodItem.fetchRequest()
        request.predicate = predicate
        if let result = try? AppDelegate.viewContext.fetch(request) {
            if !result.isEmpty {
                return result[0]
            }
        }
        return nil
    }
}
