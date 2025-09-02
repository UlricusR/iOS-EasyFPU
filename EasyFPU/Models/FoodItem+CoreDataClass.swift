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


enum FoodItemDataError: Equatable {
    case name(String), calories(String), carbs(String), sugars(String), amount(String), tooMuchCarbs(String), tooMuchSugars(String)
    case none
}

enum FoodItemCategory: String, CaseIterable, Identifiable {
    case product = "Product"
    case ingredient = "Ingredient"
    
    var id: String {
        self.rawValue
    }
}

enum FoodItemUnit: String {
    case gram = "g"
    case milliliter = "ml"
    
    init?(rawValue: String) {
        switch rawValue {
        case FoodItemUnit.gram.rawValue:
            self = .gram
        case FoodItemUnit.milliliter.rawValue:
            self = .milliliter
        default:
            return nil
        }
    }
}

public class FoodItem: NSManagedObject {
    
    //
    // MARK: - Static methods for entity creation/deletion/fetching
    //
    
    static func fetchAll(viewContext: NSManagedObjectContext = CoreDataStack.viewContext) -> [FoodItem] {
        let request: NSFetchRequest<FoodItem> = FoodItem.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        guard let foodItems = try? CoreDataStack.viewContext.fetch(request) else {
            return []
        }
        return foodItems
    }
    
    static func deleteAll(viewContext: NSManagedObjectContext = CoreDataStack.viewContext) {
        FoodItem.fetchAll(viewContext: viewContext).forEach({
            viewContext.delete($0)
        })
        
        try? viewContext.save()
    }
    
    /// Creates a new Core Data FoodItem with default values. Does not save the context.
    /// - Parameter category: The category of the new FoodItem.
    /// - Returns: The new Core Data FoodItem.
    static func new(category: FoodItemCategory) -> FoodItem {
        let newFoodItem = FoodItem(context: CoreDataStack.viewContext)
        newFoodItem.id = UUID()
        newFoodItem.name = ""
        newFoodItem.caloriesPer100g = 0
        newFoodItem.carbsPer100g = 0
        newFoodItem.sugarsPer100g = 0
        newFoodItem.favorite = false
        newFoodItem.category = category.rawValue
        return newFoodItem
    }
    
    /**
     Creates a new Core Data FoodItem. Does not relate it to the passed FoodItemViewModel. Saves the context.
     
     - Parameters:
        - foodItedVM: the source FoodItemViewModel.
        - saveContext: If true, the context will be saved after creation.
        
     - Returns: the new Core Data FoodItem.
     */
    static func create(from foodItemVM: FoodItemPersistence, saveContext: Bool) -> FoodItem {
        // Create the FoodItem
        let cdFoodItem = FoodItem(context: CoreDataStack.viewContext)
        
        // Fill data
        cdFoodItem.id = foodItemVM.id
        cdFoodItem.name = foodItemVM.name
        cdFoodItem.foodCategory = foodItemVM.foodCategory
        cdFoodItem.category = foodItemVM.category.rawValue
        cdFoodItem.caloriesPer100g = foodItemVM.caloriesPer100g
        cdFoodItem.carbsPer100g = foodItemVM.carbsPer100g
        cdFoodItem.sugarsPer100g = foodItemVM.sugarsPer100g
        cdFoodItem.favorite = foodItemVM.favorite
        cdFoodItem.sourceID = foodItemVM.sourceID
        cdFoodItem.sourceDB = foodItemVM.sourceDB?.rawValue
        
        // Add typical amounts
        for typicalAmount in foodItemVM.typicalAmounts {
            let newCDTypicalAmount = TypicalAmount.create(from: typicalAmount, saveContext: saveContext)
            cdFoodItem.addToTypicalAmounts(newCDTypicalAmount)
        }
        
        // Save
        if saveContext {
            CoreDataStack.shared.save()
        }
        return cdFoodItem
    }
    
    /**
     Creates a new Core Data FoodItem from a ComposedFoodItemViewModel.
     First checks if a Core Data FoodItem with the same ID exists, otherwise creates a new one with the ID of the ComposedFoodItemViewModel.
     Creates TypicalAmounts for the FoodItem, if required.
     It does not create a relationship to a ComposedFoodItem. This needs to be created manually.
     Saves the context.
     
     - Parameters:
        - composedFoodItem: The source ComposedFoodItemViewModel.
        - generateTypicalAmounts: If true, TypicalAmounts will be added to the FoodItem.
        - saveContext: If true, the context will be saved after creation.
     
     - Returns: The existing Core Data FoodItem if found, otherwise a new one.
     */
    static func create(from composedFoodItemVM: ComposedFoodItemPersistence, saveContext: Bool) -> FoodItem {
        var cdFoodItem: FoodItem
        
        // Return the existing Core Data FoodItem, if found
        if let existingFoodItem = FoodItem.getFoodItemByID(id: composedFoodItemVM.id) {
            cdFoodItem = existingFoodItem
            
            // Remove existing TypicalAmounts
            if let existingTypicalAmounts = cdFoodItem.typicalAmounts {
                cdFoodItem.removeFromTypicalAmounts(existingTypicalAmounts)
            }
        } else {
            // Create new FoodItem
            cdFoodItem = FoodItem(context: CoreDataStack.viewContext)
            cdFoodItem.id = composedFoodItemVM.id
            
            // Fill data
            cdFoodItem.name = composedFoodItemVM.name
            cdFoodItem.foodCategory = composedFoodItemVM.foodCategory
            cdFoodItem.caloriesPer100g = composedFoodItemVM.caloriesPer100g
            cdFoodItem.carbsPer100g = composedFoodItemVM.carbsPer100g
            cdFoodItem.sugarsPer100g = composedFoodItemVM.sugarsPer100g
            cdFoodItem.favorite = composedFoodItemVM.favorite
            
            // Set category to product
            cdFoodItem.category = FoodItemCategory.product.rawValue
        }
        
        // Add typical amounts
        if composedFoodItemVM.numberOfPortions > 0 {
            for typicalAmountVM in composedFoodItemVM.typicalAmounts {
                let newCDTypicalAmount = TypicalAmount.create(from: typicalAmountVM, saveContext: saveContext)
                cdFoodItem.addToTypicalAmounts(newCDTypicalAmount)
            }
        }
        
        // Save new food item and refresh
        if saveContext {
            CoreDataStack.shared.save()
        }
        
        return cdFoodItem
    }
    
    /// Either creates a new Core Data FoodItem from a ComposedFoodItem or updates an existing one.
    /// Does not save the context.
    /// - Parameter composedFoodItem: The source ComposedFoodItem.
    /// - Returns: The existing Core Data FoodItem if found, otherwise a new one.
    static func createOrUpdate(from composedFoodItem: ComposedFoodItem) -> FoodItem {
        var cdFoodItem: FoodItem
        
        // Check for related FoodItem
        if let relatedFoodItem = composedFoodItem.foodItem {
            cdFoodItem = relatedFoodItem
            
            // Remove existing TypicalAmounts
            if let existingTypicalAmounts = cdFoodItem.typicalAmounts {
                cdFoodItem.removeFromTypicalAmounts(existingTypicalAmounts)
            }
        } else if let existingFoodItem = FoodItem.getFoodItemByID(id: composedFoodItem.id) {
            // There is an existing FoodItem with the same ID, use it
            cdFoodItem = existingFoodItem
            
            // Remove existing TypicalAmounts
            if let existingTypicalAmounts = cdFoodItem.typicalAmounts {
                cdFoodItem.removeFromTypicalAmounts(existingTypicalAmounts)
            }
        } else {
            // Create new FoodItem
            cdFoodItem = FoodItem(context: CoreDataStack.viewContext)
            cdFoodItem.id = composedFoodItem.id
        }
        
        // Update data
        cdFoodItem.name = composedFoodItem.name
        cdFoodItem.foodCategory = composedFoodItem.foodCategory
        cdFoodItem.caloriesPer100g = composedFoodItem.caloriesPer100g
        cdFoodItem.carbsPer100g = composedFoodItem.carbsPer100g
        cdFoodItem.sugarsPer100g = composedFoodItem.sugarsPer100g
        cdFoodItem.favorite = composedFoodItem.favorite
        
        // Set category to product
        cdFoodItem.category = FoodItemCategory.product.rawValue
        
        // Add typical amounts
        if composedFoodItem.numberOfPortions > 0 {
            let portionWeight = Int(composedFoodItem.amount) / Int(composedFoodItem.numberOfPortions)
            for multiplier in 1...Int(composedFoodItem.numberOfPortions) {
                let portionAmount = portionWeight * multiplier
                let comment = "\(multiplier) \(NSLocalizedString("portion(s)", comment: "")) (\(multiplier)/\(composedFoodItem.numberOfPortions))"
                let typicalAmount = TypicalAmount.create(amount: Int64(portionAmount), comment: comment)
                cdFoodItem.addToTypicalAmounts(typicalAmount)
            }
        }
        
        return cdFoodItem
    }
    
    /// Deletes the given FoodItem from Core Data. Does not save the context.
    /// - Parameters:
    ///   - foodItem: The FoodItem to be deleted.
    ///   - deleteAssociatedRecipe: If true, the associated ComposedFoodItem (recipe) will also be deleted.
    static func delete(_ foodItem: FoodItem, deleteAssociatedRecipe: Bool = false) {
        // Deletion of all related typical amounts will happen automatically
        // as we have set Delete Rule to Cascade in data model
        
        if deleteAssociatedRecipe {
            if let associatedRecipe = foodItem.composedFoodItem {
                ComposedFoodItem.delete(associatedRecipe, includeAssociatedFoodItem: false)
            }
        }
        
        // Delete the food item itself
        CoreDataStack.viewContext.delete(foodItem)
    }
    
    /**
     Adds a TypicalAmount to a FoodItem.
     TODO check if still needed after refacturing.
     
     - Parameters:
        - typicalAmount: The Core Data TypicalAmount to add.
        - foodItem: The Core Data FoodItem the TypicalAmount should be added to.
        - saveContext: If true, the context will be saved after adding the TypicalAmount.
     */
    static func add(_ typicalAmount: TypicalAmount, to foodItem: FoodItem, saveContext: Bool) {
        foodItem.addToTypicalAmounts(typicalAmount)
        if saveContext {
            CoreDataStack.shared.save()
        }
    }
    
    /// Checks if a Core Data FoodItem or ComposedFoodItem with the name of this FoodItem exists.
    /// - Parameter foodItem: The Core Data FoodItem to check the name for.
    /// - Returns: True if a Core Data FoodItem or ComposedFoodItem with the same name exists, false otherwise.
    static func nameExists(name: String) -> Bool {
        let foodItems = FoodItem.getFoodItemsByName(name: name)
        let composedFoodItems = ComposedFoodItem.getComposedFoodItemByName(name: name)
        
        // We expect the food item to exist exactly once (itself), so if there is more than one, the name already exists
        return foodItems != nil && foodItems!.count > 1 || composedFoodItems != nil
    }
    
    /**
     Returns the Core Data FoodItem with the given id.
     
     - Parameter id: The Core Data entry id.
     
     - Returns: The related Core Data FoodItem, nil if not found.
     */
    static func getFoodItemByID(id: UUID) -> FoodItem? {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        let request: NSFetchRequest<FoodItem> = FoodItem.fetchRequest()
        request.predicate = predicate
        do {
            let result = try CoreDataStack.viewContext.fetch(request)
            if !result.isEmpty {
                return result[0]
            }
        } catch {
            debugPrint("Error fetching food item: \(error)")
        }
        return nil
    }
    
    /**
     Returns the Core Data FoodItem with the given name.
     
     - Parameter name: The Core Data entry name.
     
     - Returns: The related Core Data FoodItem, nil if not found.
     */
    static func getFoodItemsByName(name: String) -> [FoodItem]? {
        let predicate = NSPredicate(format: "name == %@", name)
        let request: NSFetchRequest<FoodItem> = FoodItem.fetchRequest()
        request.predicate = predicate
        do {
            let result = try CoreDataStack.viewContext.fetch(request)
            if !result.isEmpty {
                return result
            }
        } catch {
            debugPrint("Error fetching food item: \(error)")
        }
        return nil
    }
}
