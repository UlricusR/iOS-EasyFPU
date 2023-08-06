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


extension ComposedFoodItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ComposedFoodItem> {
        return NSFetchRequest<ComposedFoodItem>(entityName: "ComposedFoodItem")
    }

    @NSManaged public var name: String? // unused as of 2023-08-04
    @NSManaged public var amount: Int64
    @NSManaged public var numberOfPortions: Int16
    @NSManaged public var favorite: Bool // unused as of 2023-08-04
    @NSManaged public var category: String? // unused as of 2023-08-04
    @NSManaged public var id: UUID // required as of 2023-08-04
    @NSManaged public var ingredients: NSSet // required as of 2023-08-04
    @NSManaged public var foodItem: FoodItem // required as of 2023-08-04

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
