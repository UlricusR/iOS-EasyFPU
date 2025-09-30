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
    
    func localizedDescription() -> String {
        switch self {
        case .name(let errorMessage):
            errorMessage
        case .calories(let errorMessage):
            NSLocalizedString("Calories: ", comment:"") + errorMessage
        case .carbs(let errorMessage):
            NSLocalizedString("Carbs: ", comment:"") + errorMessage
        case .sugars(let errorMessage):
            NSLocalizedString("Sugars: ", comment: "") + errorMessage
        case .tooMuchCarbs(let errorMessage):
            errorMessage
        case .tooMuchSugars(let errorMessage):
            errorMessage
        case .amount(let errorMessage):
            NSLocalizedString("Amount: ", comment:"") + errorMessage
        case .none:
            ""
        }
    }
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
    static func new(category: FoodItemCategory, context: NSManagedObjectContext) -> FoodItem {
        let newFoodItem = FoodItem(context: context)
        newFoodItem.id = UUID()
        newFoodItem.name = ""
        newFoodItem.caloriesPer100g = 0
        newFoodItem.carbsPer100g = 0
        newFoodItem.sugarsPer100g = 0
        newFoodItem.favorite = false
        newFoodItem.category = category.rawValue
        return newFoodItem
    }
    
    /// Creates a new Core Data FoodItem from a FoodItemPersistence. Validates the data.
    /// - Parameters:
    ///   - foodItedPersistence: The source FoodItemPersistence.
    ///   - saveContext: If true, the context will be saved after creation.
    ///   - dataError: An inout parameter that will contain any validation error encountered during creation.
    /// - Returns: The new Core Data FoodItem, or nil if there was a validation error.
    static func create(from foodItemPersistence: FoodItemPersistence, saveContext: Bool, dataError: inout FoodItemDataError) -> FoodItem? {
        // Create the FoodItem
        let cdFoodItem = FoodItem(context: CoreDataStack.viewContext)
        
        // Fill data
        cdFoodItem.id = foodItemPersistence.id
        cdFoodItem.name = foodItemPersistence.name
        cdFoodItem.foodCategory = foodItemPersistence.foodCategory
        cdFoodItem.category = foodItemPersistence.category.rawValue
        cdFoodItem.caloriesPer100g = foodItemPersistence.caloriesPer100g
        cdFoodItem.carbsPer100g = foodItemPersistence.carbsPer100g
        cdFoodItem.sugarsPer100g = foodItemPersistence.sugarsPer100g
        cdFoodItem.favorite = foodItemPersistence.favorite
        cdFoodItem.sourceID = foodItemPersistence.sourceID
        cdFoodItem.sourceDB = foodItemPersistence.sourceDB?.rawValue
        
        // Validate the data
        dataError = cdFoodItem.validateInput()
        guard dataError == .none else {
            return nil
        }
        
        // Add typical amounts
        for typicalAmount in foodItemPersistence.typicalAmounts {
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
        let context = composedFoodItem.managedObjectContext ?? CoreDataStack.viewContext
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
                let typicalAmount = TypicalAmount.create(amount: Int64(portionAmount), comment: comment, context: context)
                cdFoodItem.addToTypicalAmounts(typicalAmount)
            }
        }
        
        return cdFoodItem
    }
    
    /// Deletes the given FoodItem from Core Data. Does not save the context.
    /// - Parameters:
    ///   - foodItem: The FoodItem to be deleted.
    ///   - deleteAssociatedRecipe: If true, the associated ComposedFoodItem (recipe) will also be deleted.
    static func delete(_ foodItem: FoodItem, deleteAssociatedRecipe: Bool = false, saveContext: Bool) {
        // Deletion of all related typical amounts will happen automatically
        // as we have set Delete Rule to Cascade in data model
        
        if deleteAssociatedRecipe {
            if let associatedRecipe = foodItem.composedFoodItem {
                ComposedFoodItem.delete(associatedRecipe, includeAssociatedFoodItem: false, saveContext: false)
            }
        }
        
        // Delete the food item itself
        CoreDataStack.viewContext.delete(foodItem)
        
        if saveContext {
            CoreDataStack.shared.save()
        }
    }
    
    /**
     Adds a TypicalAmount to a FoodItem.
     
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
    static func nameExists(name: String, isNew: Bool) -> Bool {
        let foodItems = FoodItem.getFoodItemsByName(name: name)
        let composedFoodItems = ComposedFoodItem.getComposedFoodItemsByName(name: name)
        
        // We expect the food item not to exist
        // If isNew is true, we expect 0 items, as we are creating a new one
        // If isNew is false, we expect 1 item, as we are editing an existing one
        return foodItems != nil && foodItems!.count > (isNew ? 0 : 1) || composedFoodItems != nil && composedFoodItems!.count > (isNew ? 0 : 1)
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
    
    /// Returns the Core Data FoodItems with the given name.
    /// - Parameters:
    ///   - name: The Core Data entry name.
    /// - Returns: The related Core Data FoodItems, nil if not found.
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
