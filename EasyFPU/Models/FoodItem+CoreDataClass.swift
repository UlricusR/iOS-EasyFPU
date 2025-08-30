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
    
    static func new(category: FoodItemCategory) -> FoodItem {
        let newFoodItem = FoodItem(context: CoreDataStack.viewContext)
        newFoodItem.id = UUID()
        newFoodItem.name = ""
        newFoodItem.caloriesPer100g = 0.0
        newFoodItem.carbsPer100g = 0.0
        newFoodItem.sugarsPer100g = 0.0
        newFoodItem.favorite = false
        newFoodItem.category = category.rawValue
        return newFoodItem
    }
    
    /**
     Creates a new Core Data FoodItem. Does not relate it to the passed FoodItemViewModel.
     
     - Parameters:
        - foodItedVM: the source FoodItemViewModel.
        
     - Returns: the new Core Data FoodItem.
     */
    static func create(from foodItemVM: FoodItemViewModel) -> FoodItem {
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
        
        // Save
        CoreDataStack.shared.save()
        
        // Add typical amounts
        for typicalAmount in foodItemVM.typicalAmounts {
            let newCDTypicalAmount = TypicalAmount.create(from: typicalAmount)
            cdFoodItem.addToTypicalAmounts(newCDTypicalAmount)
        }
        
        // Save
        CoreDataStack.shared.save()
        return cdFoodItem
    }
    
    /**
     Creates a new Core Data FoodItem from a ComposedFoodItemViewModel.
     First checks if a Core Data FoodItem with the same ID exists, otherwise creates a new one with the ID of the ComposedFoodItemViewModel.
     Creates TypicalAmounts for the FoodItem, if required.
     It does not create a relationship to a ComposedFoodItem. This needs to be created manually.
     
     - Parameters:
        - composedFoodItem: The source ComposedFoodItemViewModel.
        - generateTypicalAmounts: If true, TypicalAmounts will be added to the FoodItem.
     
     - Returns: The existing Core Data FoodItem if found, otherwise a new one.
     */
    static func create(from composedFoodItemVM: ComposedFoodItemViewModel) -> FoodItem {
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
                let newCDTypicalAmount = TypicalAmount.create(from: typicalAmountVM)
                cdFoodItem.addToTypicalAmounts(newCDTypicalAmount)
            }
        }
        
        // Save new food item and refresh
        CoreDataStack.shared.save()
        
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
    static func update(
        _ cdFoodItem: FoodItem,
        with foodItemVM: FoodItemViewModel,
        typicalAmountsToBeDeleted: [TypicalAmountViewModel]
    ) {
        // TODO remove after fixing tests
    }
    
    /// Updates the ComposedFoodItems (recipes) related to the FoodItem with the nutritional values of the FoodItem.
    /// - Parameter cdFoodItem: The food item used for updating the recipes.
    static func updateRelatedRecipes(of cdFoodItem: FoodItem) {
        // Get the related ingredients and update their values
        let relatedIngredients = cdFoodItem.ingredients?.allObjects as? [Ingredient] ?? []
        for ingredient in relatedIngredients {
            _ = Ingredient.update(ingredient, with: cdFoodItem)
        }
    }
    
    static func fill(foodItem: FoodItem, with foodDatabaseEntry: FoodDatabaseEntry) {
        foodItem.name = foodDatabaseEntry.name
        foodItem.category = foodDatabaseEntry.category.rawValue
        foodItem.sourceID = foodDatabaseEntry.sourceId
        foodItem.sourceDB = foodDatabaseEntry.source.rawValue
        
        // When setting string representations, number will be set implicitely
        foodItem.caloriesPer100g = foodDatabaseEntry.caloriesPer100g.getEnergyInKcal()
        foodItem.carbsPer100g = foodDatabaseEntry.carbsPer100g
        foodItem.sugarsPer100g = foodDatabaseEntry.sugarsPer100g
        
        // Add the quantity as typical amount if available
        if foodDatabaseEntry.quantity > 0 && foodDatabaseEntry.quantityUnit == FoodItemUnit.gram {
            // Create TypicalAmount
            let cdTypicalAmount = TypicalAmount.create(amount: Int64(foodDatabaseEntry.quantity), comment: NSLocalizedString("As sold", comment: ""))
            
            // Add to cdFoodItem
            foodItem.addToTypicalAmounts(cdTypicalAmount)
        }
    }
    
    /**
     Duplicates the FoodItem represented by the existingFoodItemVM
     
     - Parameters:
        - existingFoodItemVM: the FoodItemViewModel to be duplicated
     
     - Returns: the new Core Data FoodItem
     */
    static func duplicate(_ existingFoodItem: FoodItem) -> FoodItem {
        // Create new FoodItem with own ID
        let cdFoodItem = FoodItem(context: CoreDataStack.viewContext)
        cdFoodItem.id = UUID()
        
        // Fill data
        cdFoodItem.name = (existingFoodItem.name) + NSLocalizedString(" - Copy", comment: "")
        cdFoodItem.foodCategory = existingFoodItem.foodCategory
        cdFoodItem.caloriesPer100g = existingFoodItem.caloriesPer100g
        cdFoodItem.carbsPer100g = existingFoodItem.carbsPer100g
        cdFoodItem.sugarsPer100g = existingFoodItem.sugarsPer100g
        cdFoodItem.favorite = existingFoodItem.favorite
        cdFoodItem.category = existingFoodItem.category
        cdFoodItem.sourceID = existingFoodItem.sourceID
        cdFoodItem.sourceDB = existingFoodItem.sourceDB
        
        // Add typical amounts
        if let typicalAmounts = existingFoodItem.typicalAmounts {
            for case let typicalAmount as TypicalAmount in typicalAmounts {
                let newCDTypicalAmount = TypicalAmount(context: CoreDataStack.viewContext)
                newCDTypicalAmount.id = UUID()
                newCDTypicalAmount.amount = typicalAmount.amount
                newCDTypicalAmount.comment = typicalAmount.comment
                cdFoodItem.addToTypicalAmounts(newCDTypicalAmount)
            }
        }
        
        // Save new food item and refresh
        CoreDataStack.shared.save()
        
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
                ComposedFoodItem.delete(associatedRecipe)
            }
        }
        
        // Delete the food item itself
        CoreDataStack.viewContext.delete(foodItem)
    }
    
    /**
     Adds a TypicalAmount to a FoodItem.
     
     - Parameters:
        - typicalAmount: The Core Data TypicalAmount to add.
        - foodItem: The Core Data FoodItem the TypicalAmount should be added to.
     */
    static func add(_ typicalAmount: TypicalAmount, to foodItem: FoodItem) {
        foodItem.addToTypicalAmounts(typicalAmount)
        CoreDataStack.shared.save()
    }
    
    /// Checks if a Core Data FoodItem or ComposedFoodItem with the name of this FoodItem exists.
    /// - Parameter foodItem: The Core Data FoodItem to check the name for.
    /// - Returns: True if a Core Data FoodItem or ComposedFoodItem with the same name exists, false otherwise.
    static func nameExists(foodItem: FoodItem) -> Bool {
        let foodItems = FoodItem.getFoodItemsByName(name: foodItem.name)
        let composedFoodItems = ComposedFoodItem.getComposedFoodItemByName(name: foodItem.name)
        
        // We expect the food item to exist exactly once (itself), so if there is more than one, the name already exists
        return foodItems != nil && foodItems!.count > 1 || composedFoodItems != nil
    }
    
    /// Sets the category of the Core Data FoodItem to the given String. Does not check if the string is a valid FoodItemCategory.
    /// - Parameters:
    ///   - foodItem: The Core Data FoodItem.
    ///   - category: The string representation of the FoodItemCategory.
    static func setCategory(_ foodItem: FoodItem?, to category: String) {
        if let foodItem = foodItem {
            foodItem.category = category
            foodItem.foodCategory = nil // Remove the food category, as it belonged to the previous category
            CoreDataStack.viewContext.refresh(foodItem, mergeChanges: true)
            CoreDataStack.shared.save()
        }
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
    
    static func getCalories(ingredient: Ingredient) -> Double {
        Double(ingredient.amount) / 100 * ingredient.caloriesPer100g
    }
    
    static func getCarbsInclSugars(ingredient: Ingredient) -> Double {
        Double(ingredient.amount) / 100 * ingredient.carbsPer100g
    }
    
    static func getSugarsOnly(ingredient: Ingredient) -> Double {
        Double(ingredient.amount) / 100 * ingredient.sugarsPer100g
    }
    
    static func getRegularCarbs(ingredient: Ingredient, treatSugarsSeparately: Bool) -> Double {
        Double(ingredient.amount) / 100 * (treatSugarsSeparately ? (ingredient.carbsPer100g - ingredient.sugarsPer100g) : ingredient.carbsPer100g)
    }
    
    static func getSugars(ingredient: Ingredient, treatSugarsSeparately: Bool) -> Double {
        Double(ingredient.amount) / 100 * (treatSugarsSeparately ? ingredient.sugarsPer100g : 0)
    }
    
    static func getFPU(ingredient: Ingredient) -> FPU {
        // 1g carbs has ~4 kcal, so calculate carb portion of calories
        let carbsCal = Double(ingredient.amount) / 100 * ingredient.carbsPer100g * 4;

        // The carbs from fat and protein is the remainder
        let calFromFP = getCalories(ingredient: ingredient) - carbsCal;

        // 100kcal makes 1 FPU
        let fpus = calFromFP / 100;

        // Create and return the FPU object
        return FPU(fpu: fpus)
    }
}
