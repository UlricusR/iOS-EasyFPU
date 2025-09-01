//
//  FoodItem+CoreDataProperties.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 17.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//
//

import Foundation
import CoreData


extension FoodItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FoodItem> {
        return NSFetchRequest<FoodItem>(entityName: "FoodItem")
    }

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var favorite: Bool
    @NSManaged public var category: String
    @NSManaged public var caloriesPer100g: Double
    @NSManaged public var carbsPer100g: Double
    @NSManaged public var sugarsPer100g: Double
    @NSManaged public var sourceID: String?
    @NSManaged public var sourceDB: String?
    @NSManaged public var foodCategory: FoodCategory?
    @NSManaged public var composedFoodItem: ComposedFoodItem?
    @NSManaged public var typicalAmounts: NSSet?
    @NSManaged public var ingredients: NSSet?
    
    //
    // MARK: - Computed properties
    //
    
    
    
    //
    // MARK: - Custom functions
    //
    
    /// Checks if a Core Data FoodItem or ComposedFoodItem with the name of this FoodItem exists.
    /// - Parameter foodItem: The Core Data FoodItem to check the name for.
    /// - Returns: True if a Core Data FoodItem or ComposedFoodItem with the same name exists, false otherwise.
    func nameExists() -> Bool {
        FoodItem.nameExists(name: self.name)
    }
    
    /// Checks if an associated recipe exists.
    /// - Returns: True if an associated recipe exists.
    func hasAssociatedRecipe() -> Bool {
        return self.composedFoodItem != nil
    }
    
    /// Updates the ComposedFoodItems (recipes) related to the FoodItem with the nutritional values of the FoodItem.
    func updateRelatedRecipes() {
        // Get the related ingredients and update their values
        let relatedIngredients = self.ingredients?.allObjects as? [Ingredient] ?? []
        for ingredient in relatedIngredients {
            ingredient.update(with: self)
        }
    }
    
    /// Fills the FoodItem with the values from the given FoodDatabaseEntry. Does not save the context.
    /// - Parameter foodDatabaseEntry: The FoodDatabaseEntry to fill the FoodItem with.
    func fill(with foodDatabaseEntry: FoodDatabaseEntry) {
        self.name = foodDatabaseEntry.name
        self.category = foodDatabaseEntry.category.rawValue
        self.sourceID = foodDatabaseEntry.sourceId
        self.sourceDB = foodDatabaseEntry.source.rawValue
        
        // When setting string representations, number will be set implicitely
        self.caloriesPer100g = foodDatabaseEntry.caloriesPer100g.getEnergyInKcal()
        self.carbsPer100g = foodDatabaseEntry.carbsPer100g
        self.sugarsPer100g = foodDatabaseEntry.sugarsPer100g
        
        // Add the quantity as typical amount if available
        if foodDatabaseEntry.quantity > 0 && foodDatabaseEntry.quantityUnit == FoodItemUnit.gram {
            // Create TypicalAmount
            let cdTypicalAmount = TypicalAmount.create(amount: Int64(foodDatabaseEntry.quantity), comment: NSLocalizedString("As sold", comment: ""))
            
            // Add to cdFoodItem
            self.addToTypicalAmounts(cdTypicalAmount)
        }
    }
    
    /// Duplicates the FoodItem. If the FoodItem is associated to a ComposedFoodItem (recipe), the recipe will be duplicated instead.
    /// - Parameter saveContext: If true, the Core Data context will be saved after duplication.
    /// - Returns: The duplicated FoodItem, nil if something went wrong.
    func duplicate(saveContext: Bool) -> FoodItem? {
        if self.composedFoodItem != nil {
            // This food item is associated to a recipe, so rather duplicate the recipe
            let newComposedFoodItem = self.composedFoodItem!.duplicate(saveContext: saveContext)
            return newComposedFoodItem!.foodItem // The duplicated recipe should always have a food item, otherwise something is seriously wrong
        }
        
        // Create new FoodItem with own ID
        let cdFoodItem = FoodItem(context: CoreDataStack.viewContext)
        cdFoodItem.id = UUID()
        
        // Fill data
        cdFoodItem.name = (self.name) + NSLocalizedString(" - Copy", comment: "")
        cdFoodItem.foodCategory = self.foodCategory
        cdFoodItem.caloriesPer100g = self.caloriesPer100g
        cdFoodItem.carbsPer100g = self.carbsPer100g
        cdFoodItem.sugarsPer100g = self.sugarsPer100g
        cdFoodItem.favorite = self.favorite
        cdFoodItem.category = self.category
        cdFoodItem.sourceID = self.sourceID
        cdFoodItem.sourceDB = self.sourceDB
        
        // Add typical amounts
        if let typicalAmounts = self.typicalAmounts {
            for case let typicalAmount as TypicalAmount in typicalAmounts {
                let newCDTypicalAmount = TypicalAmount(context: CoreDataStack.viewContext)
                newCDTypicalAmount.id = UUID()
                newCDTypicalAmount.amount = typicalAmount.amount
                newCDTypicalAmount.comment = typicalAmount.comment
                cdFoodItem.addToTypicalAmounts(newCDTypicalAmount)
            }
        }
        
        // Save new food item and refresh
        if saveContext {
            CoreDataStack.shared.save()
        }
        
        return cdFoodItem
    }
    
    /// Returns the names of all associated recipes (ComposedFoodItems) of the FoodItem.
    /// - Returns: An array of names of associated recipes, nil if there are no associated recipes.
    func getAssociatedRecipeNames() -> [String]? {
        if (self.ingredients == nil) || (self.ingredients!.count == 0) {
            return nil
        } else {
            var associatedRecipeNames = [String]()
            for case let ingredient as Ingredient in self.ingredients! {
                associatedRecipeNames.append(ingredient.composedFoodItem.name)
            }
            return associatedRecipeNames
        }
    }
    
    /// Changes the category of the Core Data FoodItem from ingredient to product or vice versa.
    func changeCategory(saveContext: Bool) {
        if let currentCategory = FoodItemCategory(rawValue: self.category) {
            let newCategory: FoodItemCategory = currentCategory == .ingredient ? .product : .ingredient
            setCategory(to: newCategory.rawValue, saveContext: saveContext)
        }
    }

    /// Sets the category of the Core Data FoodItem to the given String. Does not check if the string is a valid FoodItemCategory.
    /// - Parameters:
    ///   - category: The string representation of the FoodItemCategory.
    ///   - saveContext: If true, the Core Data context will be saved after setting the category.
    func setCategory(to category: String, saveContext: Bool) {
        self.category = category
        self.foodCategory = nil // Remove the food category, as it belonged to the previous category
        CoreDataStack.viewContext.refresh(self, mergeChanges: true)
        if saveContext {
            CoreDataStack.shared.save()
        }
    }
    
    
}

// MARK: Generated accessors for typicalAmounts
extension FoodItem {

    @objc(addTypicalAmountsObject:)
    @NSManaged public func addToTypicalAmounts(_ value: TypicalAmount)

    @objc(removeTypicalAmountsObject:)
    @NSManaged public func removeFromTypicalAmounts(_ value: TypicalAmount)

    @objc(addTypicalAmounts:)
    @NSManaged public func addToTypicalAmounts(_ values: NSSet)

    @objc(removeTypicalAmounts:)
    @NSManaged public func removeFromTypicalAmounts(_ values: NSSet)

}

// MARK: Generated accessors for ingredients
extension FoodItem {

    @objc(addIngredientsObject:)
    @NSManaged public func addToIngredients(_ value: Ingredient)

    @objc(removeIngredientsObject:)
    @NSManaged public func removeFromIngredients(_ value: Ingredient)

    @objc(addIngredients:)
    @NSManaged public func addToIngredients(_ values: NSSet)

    @objc(removeIngredients:)
    @NSManaged public func removeFromIngredients(_ values: NSSet)

}

extension FoodItem: Identifiable {
    public static func == (lhs: FoodItem, rhs: FoodItem) -> Bool {
        lhs.id == rhs.id
    }
}
