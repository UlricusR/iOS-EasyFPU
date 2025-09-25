//
//  ComposedFoodItem+CoreDataProperties.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 05.11.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//
//

import Foundation
import CoreData


extension ComposedFoodItem: VariableAmountItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ComposedFoodItem> {
        return NSFetchRequest<ComposedFoodItem>(entityName: "ComposedFoodItem")
    }

    @NSManaged public var name: String
    @NSManaged public var favorite: Bool
    @NSManaged public var amount: Int64
    @NSManaged public var numberOfPortions: Int16
    @NSManaged public var id: UUID
    @NSManaged public var foodCategory: FoodCategory?
    @NSManaged public var foodItem: FoodItem?
    @NSManaged public var ingredients: NSSet
    
    //
    // MARK: Computed properties
    //
    
    var calories: Double {
        var newValue = 0.0
        for ingredient in ingredients.allObjects as! [Ingredient] {
            newValue += ingredient.calories
        }
        return newValue
    }
    
    private var carbs: Double {
        var newValue = 0.0
        for ingredient in ingredients.allObjects as! [Ingredient] {
            newValue += ingredient.carbsInclSugars
        }
        return newValue
    }
    
    private var sugars: Double {
        var newValue = 0.0
        for ingredient in ingredients.allObjects as! [Ingredient] {
            newValue += ingredient.sugarsOnly
        }
        return newValue
    }
    
    var fpus: FPU {
        var fpu = FPU(fpu: 0.0)
        for ingredient in ingredients.allObjects as! [Ingredient] {
            let tempFPU = fpu.fpu
            fpu = FPU(fpu: tempFPU + ingredient.fpus.fpu)
        }
        return fpu
    }
    
    var caloriesPer100g: Double {
        calories / Double(amount) * 100
    }
    
    var carbsPer100g: Double {
        carbs / Double(amount) * 100
    }
    
    var sugarsPer100g: Double {
        sugars / Double(amount) * 100
    }
    
    var carbsInclSugars: Double {
        self.carbs
    }
    
    var carbsWithoutSugars: Double {
        self.carbs - self.sugars
    }
    
    var sugarsOnly: Double {
        self.sugars
    }
    
    //
    // MARK: Custom functions
    //
    
    /// Duplicates the given ComposedFoodItem, including its Ingredients and related FoodItem.
    /// - Parameter saveContext: If true, the Core Data context is saved after duplication.
    /// - Returns: The duplicated ComposedFoodItem, nil if duplication failed.
    func duplicate(saveContext: Bool) -> ComposedFoodItem? {
        // Create new ComposedFoodItem with new ID
        let cdComposedFoodItem = ComposedFoodItem(context: CoreDataStack.viewContext)
        cdComposedFoodItem.id = UUID()
        
        // Fill data
        cdComposedFoodItem.name = self.name + NSLocalizedString(" - Copy", comment: "")
        cdComposedFoodItem.foodCategory = self.foodCategory
        cdComposedFoodItem.favorite = self.favorite
        cdComposedFoodItem.amount = self.amount
        cdComposedFoodItem.numberOfPortions = self.numberOfPortions
        
        // Create ingredients
        for case let ingredient as Ingredient in self.ingredients {
            _ = ingredient.duplicate(for: cdComposedFoodItem)
        }
        
        // Create related FoodItem
        if let existingFoodItem = self.foodItem {
            cdComposedFoodItem.foodItem = existingFoodItem.duplicate(saveContext: saveContext)
            
            // Save
            if saveContext {
                CoreDataStack.shared.save()
            }
            
            return cdComposedFoodItem
        } else {
            // No existing FoodItem found to duplicate - this should not happen
            // Delete composedFoodItem again
            ComposedFoodItem.delete(cdComposedFoodItem, includeAssociatedFoodItem: false, saveContext: saveContext)
            
            // Save
            if saveContext {
                CoreDataStack.shared.save()
            }
            
            return nil
        }
    }
    
    /// Removes all ingredients from the ComposedFoodItem, resets its amount to 0 and sets new values, but keeps the ID. Does not save the context.
    /// - Parameter name: The new name for the ComposedFoodItem once cleared.
    func clear(name: String) {
        // Clear ingredients
        for ingredient in self.ingredients.allObjects as! [Ingredient] {
            ingredient.amount = 0
            self.removeFromIngredients(ingredient)
        }
        
        // Reset amount
        self.amount = 0
        
        // Reset values - we keep the ID
        self.name = name
        self.favorite = false
        self.numberOfPortions = 0
    }
    
    /// Checks if a Core Data FoodItem or ComposedFoodItem with the name of this ComposedFoodItemViewModel exists.
    /// - Returns: True if a Core Data FoodItem or ComposedFoodItem with the same name exists, false otherwise.
    func nameExists(isNew: Bool) -> Bool {
        FoodItem.nameExists(name: self.name, isNew: isNew)
    }
    
    func regularCarbs(treatSugarsSeparately: Bool) -> Double {
        treatSugarsSeparately ? self.carbsWithoutSugars : self.carbsInclSugars
    }
    
    func sugars(treatSugarsSeparately: Bool) -> Double {
        treatSugarsSeparately ? self.sugarsOnly : 0
    }
    
    /// Updates the related FoodItem of this ComposedFoodItem. Does not save the context.
    func updateRelatedFoodItem() {
        // Update the related FoodItem or create a new one if it does not exist yet
        let foodItem = FoodItem.createOrUpdate(from: self)
        
        // Relate it to this ComposedFoodItem
        self.foodItem = foodItem
    }
    
    /// Adds an Ingredient  to the ComposedFoodItem, if it doesn't exist yet.
    /// - Parameter ingredient: The ingredient to be added.
    func add(ingredient: Ingredient) {
        if !ingredients.contains(ingredient) {
            self.addToIngredients(ingredient)
            let newAmount = self.amount + ingredient.amount
            self.amount = newAmount
        }
    }
    
    /// Checks whether the ComposedFoodItem contains the given FoodItem as one of its ingredients.
    /// - Parameters:
    ///   - foodItem: The FoodItem to be checked for.
    /// - Returns: True if the ComposedFoodItem contains the FoodItem, otherwise false.
    func contains(foodItem: FoodItem) -> Bool {
        let foodItems = self.ingredients.compactMap { ($0 as? Ingredient)?.foodItem }
        return foodItems.contains(foodItem)
    }
    
    /// Returns the Ingredient of the given ComposedFoodItem which relates to the given FoodItem.
    /// - Parameters:
    ///   - foodItem: The FoodItem to be checked for.
    /// - Returns: The Ingredient if found, otherwise nil.
    func getIngredient(foodItem: FoodItem) -> Ingredient? {
        for case let ingredient as Ingredient in self.ingredients {
            if ingredient.foodItem == foodItem {
                return ingredient
            }
        }
        return nil
    }
    
    /// Removes the Ingredient of the ComposedFoodItem which relates to the given FoodItem. Does not save the context.
    /// - Parameters:
    ///   - foodItem: The FoodItem to be removed.
    func remove(foodItem: FoodItem) {
        if let ingredientToBeRemoved = getIngredient(foodItem: foodItem) {
            remove(ingredient: ingredientToBeRemoved)
        }
    }
    
    /// Removes the Ingredient of the given ComposedFoodItem which relates to the given FoodItem. Does not save the context.
    /// - Parameters:
    ///   - foodItem: The FoodItem to be removed.
    func remove(ingredient: Ingredient) {
        // Substract the amount of the ingredient from the total amount
        let newAmount = self.amount - ingredient.amount
        self.amount = newAmount
        
        // Remove the ingredient from the composed food item and delete it
        self.removeFromIngredients(ingredient)
    }
    
    
}

// MARK: Generated accessors for ingredients
extension ComposedFoodItem {

    @objc(addIngredientsObject:)
    @NSManaged public func addToIngredients(_ value: Ingredient)

    @objc(removeIngredientsObject:)
    @NSManaged public func removeFromIngredients(_ value: Ingredient)

    @objc(addIngredients:)
    @NSManaged public func addToIngredients(_ values: NSSet)

    @objc(removeIngredients:)
    @NSManaged public func removeFromIngredients(_ values: NSSet)

}

extension ComposedFoodItem : Identifiable {
    public static func == (lhs: ComposedFoodItem, rhs: ComposedFoodItem) -> Bool {
        lhs.id == rhs.id
    }
}
