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
