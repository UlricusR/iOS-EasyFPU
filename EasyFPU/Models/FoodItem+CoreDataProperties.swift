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

    @NSManaged public var amount: Int64
    @NSManaged public var caloriesPer100g: Double
    @NSManaged public var carbsPer100g: Double
    @NSManaged public var sugarsPer100g: Double
    @NSManaged public var favorite: Bool
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var typicalAmounts: NSSet?
    @NSManaged public var category: String?
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
