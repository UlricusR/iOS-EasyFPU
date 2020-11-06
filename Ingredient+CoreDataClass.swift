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
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
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
    
    static func create(from foodItemVM: FoodItemViewModel) -> Ingredient {
        let moc = AppDelegate.viewContext
        
        // Create Ingredient
        let cdIngredient = Ingredient(context: moc)
        
        // Fill data
        cdIngredient.amount = Int64(foodItemVM.amount)
        cdIngredient.caloriesPer100g = foodItemVM.caloriesPer100g
        cdIngredient.carbsPer100g = foodItemVM.carbsPer100g
        cdIngredient.category = foodItemVM.category.rawValue
        cdIngredient.favorite = foodItemVM.favorite
        cdIngredient.id = foodItemVM.id
        cdIngredient.name = foodItemVM.name
        cdIngredient.sugarsPer100g = foodItemVM.sugarsPer100g
        
        // Save new Ingredient
        try? moc.save()
        
        return cdIngredient
    }
}
