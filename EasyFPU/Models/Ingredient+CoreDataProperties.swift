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


extension Ingredient {

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
}

extension Ingredient : Identifiable {
    public static func == (lhs: Ingredient, rhs: Ingredient) -> Bool {
        lhs.id == rhs.id
    }
}
