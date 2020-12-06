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
    static func fetchAll(viewContext: NSManagedObjectContext = AppDelegate.viewContext) -> [ComposedFoodItem] {
        let request: NSFetchRequest<ComposedFoodItem> = ComposedFoodItem.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        guard let composedFoodItems = try? AppDelegate.viewContext.fetch(request) else {
            return []
        }
        return composedFoodItems
    }
    
    static func deleteAll(viewContext: NSManagedObjectContext = AppDelegate.viewContext) {
        ComposedFoodItem.fetchAll(viewContext: viewContext).forEach({
            viewContext.delete($0)
        })
        
        try? viewContext.save()
    }
    
    static func create(from composedFoodItemVM: ComposedFoodItemViewModel) -> ComposedFoodItem {
        debugPrint(AppDelegate.persistentContainer.persistentStoreDescriptions) // The location of the .sqlite file
        let moc = AppDelegate.viewContext
        var existingCDComposedFoodItem: ComposedFoodItem? = nil
        
        // Check for existing ComposedFoodItem to be replaced
        if let idToBeReplaced = composedFoodItemVM.cdComposedFoodItem?.id?.uuidString {
            let predicate = NSPredicate(format: "id = %@", idToBeReplaced)
            let request: NSFetchRequest<ComposedFoodItem> = ComposedFoodItem.fetchRequest()
            request.predicate = predicate
            if let result = try? moc.fetch(request) {
                if !result.isEmpty {
                    existingCDComposedFoodItem = result[0]
                }
            }
        }
        
        // Remove ComposedFoodItem from CoreData if existing
        if existingCDComposedFoodItem != nil {
            moc.delete(existingCDComposedFoodItem!)
        }
            
        // Create new FoodItem
        let cdComposedFoodItem = ComposedFoodItem(context: moc)
        cdComposedFoodItem.id = UUID()
        
        // Fill data
        cdComposedFoodItem.name = composedFoodItemVM.name
        cdComposedFoodItem.category = composedFoodItemVM.category.rawValue
        cdComposedFoodItem.amount = Int64(composedFoodItemVM.amount)
        cdComposedFoodItem.favorite = composedFoodItemVM.favorite
        cdComposedFoodItem.numberOfPortions = Int16(composedFoodItemVM.numberOfPortions)
        
        // Add new ingredients
        for ingredient in composedFoodItemVM.foodItems {
            let cdIngredient = Ingredient.create(from: ingredient)
            cdComposedFoodItem.addToIngredients(cdIngredient)
        }
        
        // Save new composed food item
        try? moc.save()
        
        return cdComposedFoodItem
    }
    
    static func create(from existingComposedFoodItem: ComposedFoodItem) -> ComposedFoodItem {
        let moc = AppDelegate.viewContext
        let cdComposedFoodItem = ComposedFoodItem(context: moc)
        cdComposedFoodItem.id = UUID()
        
        // Fill data
        cdComposedFoodItem.name = existingComposedFoodItem.name
        cdComposedFoodItem.category = existingComposedFoodItem.category
        cdComposedFoodItem.amount = existingComposedFoodItem.amount
        cdComposedFoodItem.favorite = existingComposedFoodItem.favorite
        cdComposedFoodItem.numberOfPortions = existingComposedFoodItem.numberOfPortions
        
        // Add ingredients
        if let existingIngredients = existingComposedFoodItem.ingredients?.allObjects as? [Ingredient] {
            for ingredient in existingIngredients {
                let cdIngredient = Ingredient.create(from: ingredient)
                cdComposedFoodItem.addToIngredients(cdIngredient)
            }
        }
        
        // Save new composed food item
        try? moc.save()
        
        return cdComposedFoodItem
    }
    
    static func delete(_ composedFoodItem: ComposedFoodItem) {
        let moc = AppDelegate.viewContext
        
        // Deletion of all related ingredients will happen automatically
        // as we have set Delete Rule to Cascade in data model
        
        // Delete the food item itself
        moc.delete(composedFoodItem)
        
        // And save the context
        try? moc.save()
    }
}
