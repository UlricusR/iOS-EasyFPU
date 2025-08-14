//
//  FoodCategory+CoreDataProperties.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 13/08/2025.
//  Copyright © 2025 Ulrich Rüth. All rights reserved.
//
//

import Foundation
import CoreData


extension FoodCategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FoodCategory> {
        return NSFetchRequest<FoodCategory>(entityName: "FoodCategory")
    }

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var category: String
    @NSManaged public var foodItems: NSSet?
    @NSManaged public var composedFoodItems: NSSet?

}

// MARK: Generated accessors for foodItem
extension FoodCategory {

    @objc(addFoodItemObject:)
    @NSManaged public func addToFoodItems(_ value: FoodItem)

    @objc(removeFoodItemObject:)
    @NSManaged public func removeFromFoodItems(_ value: FoodItem)

    @objc(addFoodItem:)
    @NSManaged public func addToFoodItems(_ values: NSSet)

    @objc(removeFoodItem:)
    @NSManaged public func removeFromFoodItems(_ values: NSSet)

}

// MARK: Generated accessors for composedFoodItem
extension FoodCategory {

    @objc(addComposedFoodItemObject:)
    @NSManaged public func addToComposedFoodItems(_ value: ComposedFoodItem)

    @objc(removeComposedFoodItemObject:)
    @NSManaged public func removeFromComposedFoodItems(_ value: ComposedFoodItem)

    @objc(addComposedFoodItem:)
    @NSManaged public func addToComposedFoodItems(_ values: NSSet)

    @objc(removeComposedFoodItem:)
    @NSManaged public func removeFromComposedFoodItems(_ values: NSSet)

}

extension FoodCategory : Identifiable {
    public static func == (lhs: FoodCategory, rhs: FoodCategory) -> Bool {
        lhs.id == rhs.id
    }
}
