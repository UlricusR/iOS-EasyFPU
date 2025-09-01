//
//  Ingredient+CoreDataProperties.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 05.11.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//
//

import Foundation
import CoreData


extension Ingredient: VariableAmountItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Ingredient> {
        return NSFetchRequest<Ingredient>(entityName: "Ingredient")
    }

    @NSManaged public var id: UUID
    @NSManaged public var relatedFoodItemID: UUID? // The id of the related FoodItem
    @NSManaged public var name: String
    @NSManaged public var favorite: Bool
    @NSManaged public var amount: Int64
    @NSManaged public var caloriesPer100g: Double
    @NSManaged public var carbsPer100g: Double
    @NSManaged public var sugarsPer100g: Double
    @NSManaged public var composedFoodItem: ComposedFoodItem
    @NSManaged public var foodItem: FoodItem?
    
    //
    // MARK: - Computed properties
    //
    
    var calories: Double {
        Double(self.amount) / 100 * self.caloriesPer100g
    }
    
    var carbsInclSugars: Double {
        Double(self.amount) / 100 * self.carbsPer100g
    }
    
    var sugarsOnly: Double {
        Double(self.amount) / 100 * self.sugarsPer100g
    }
    
    var fpus: FPU {
        // 1g carbs has ~4 kcal, so calculate carb portion of calories
        let carbsCal = Double(self.amount) / 100 * self.carbsPer100g * 4;

        // The carbs from fat and protein is the remainder
        let calFromFP = calories - carbsCal;

        // 100kcal makes 1 FPU
        let fpus = calFromFP / 100;

        // Create and return the FPU object
        return FPU(fpu: fpus)
    }
    
    //
    // MARK: - Custom functions
    //
    
    func getRegularCarbs(treatSugarsSeparately: Bool) -> Double {
        Double(self.amount) / 100 * (treatSugarsSeparately ? (self.carbsPer100g - self.sugarsPer100g) : self.carbsPer100g)
    }
    
    func getSugars(treatSugarsSeparately: Bool) -> Double {
        Double(self.amount) / 100 * (treatSugarsSeparately ? self.sugarsPer100g : 0)
    }
    
    /**
     Creates new Ingredient from existing one - used to duplicate an Ingredient.
     Contains a reference to the related FoodItem and stores the ID of this FoodItem as separate value for export/import purposes.
     Does not save the context.
     
     - Parameters:
        - newCDComposedFoodItem: Used to create the relationship to the Core Data ComposedFoodItem.
     
     - Returns: The new Ingredient with with a reference to the newCDComposedFoodItem.
    */
    func duplicate(for newCDComposedFoodItem: ComposedFoodItem) -> Ingredient {
        // Create Ingredient
        let cdIngredient = Ingredient(context: CoreDataStack.viewContext)
        
        // Fill data
        cdIngredient.id = UUID()
        cdIngredient.relatedFoodItemID = self.relatedFoodItemID // The id of the related FoodItem
        cdIngredient.name = self.name
        cdIngredient.favorite = self.favorite
        cdIngredient.amount = self.amount
        cdIngredient.caloriesPer100g = self.caloriesPer100g
        cdIngredient.carbsPer100g = self.carbsPer100g
        cdIngredient.sugarsPer100g = self.sugarsPer100g
        
        // Create 1:1 references to ComposedFoodItem and FoodItem
        cdIngredient.composedFoodItem = newCDComposedFoodItem
        cdIngredient.foodItem = self.foodItem
        
        // Add to ComposedFoodItem
        newCDComposedFoodItem.addToIngredients(cdIngredient)
        
        return cdIngredient
    }
    
    /// Updates the values of the Ingredient with those of the FoodItem (but not the ID).
    /// Also updates the FoodItem of the related ComposedFoodItem.
    /// - Parameters:
    ///   - foodItem: The FoodItem the values are copied of.
    func update(with foodItem: FoodItem) {
        self.name = foodItem.name
        self.favorite = foodItem.favorite
        self.caloriesPer100g = foodItem.caloriesPer100g
        self.carbsPer100g = foodItem.carbsPer100g
        self.sugarsPer100g = foodItem.sugarsPer100g
        
        // Update the FoodItem of the related ComposedFoodItem
        composedFoodItem.updateRelatedFoodItem()
    }
    
    
}

extension Ingredient : Identifiable {
    public static func == (lhs: Ingredient, rhs: Ingredient) -> Bool {
        lhs.id == rhs.id
    }
}
