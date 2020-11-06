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
    
    static func delete(_ foodItem: FoodItem) {
        let moc = AppDelegate.viewContext
        
        // Deletion of all related typical amounts will happen automatically
        // as we have set Delete Rule to Cascade in data model
        
        // Delete the food item itself
        moc.delete(foodItem)
        
        // And save the context
        try? moc.save()
    }
}
