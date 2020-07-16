//
//  FoodItem+CoreDataProperties.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 16.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//
//

import Foundation
import CoreData


extension FoodItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FoodItem> {
        return NSFetchRequest<FoodItem>(entityName: "FoodItem")
    }

    @NSManaged public var caloriesPer100g: Double
    @NSManaged public var carbsPer100g: Double
    @NSManaged public var favorite: Bool
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var amount: Int64
    @NSManaged public var typicalAmounts: NSSet?
    
    var wrappedName: String {
        name ?? NSLocalizedString("Unnamed", comment: "")
    }

    func isValid() -> Bool {
        if name == nil {
            errorMessage = NSLocalizedString("Name must not be empty", comment: "")
            return false
        }
        
        if caloriesPer100g < 0.0 {
            errorMessage = NSLocalizedString("Calories per 100g must not be negative", comment: "")
            return false
        } else if carbsPer100g < 0.0 {
            errorMessage = NSLocalizedString("Carbs per 100g must not be negative", comment: "")
            return false
        } else if carbsPer100g * 4 > caloriesPer100g {
            errorMessage = NSLocalizedString("Calories from carbs (4 kcal per gram) exceed total calories", comment: "")
            return false
        } else {
            return true
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
