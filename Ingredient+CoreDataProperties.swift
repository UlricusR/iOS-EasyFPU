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

    @NSManaged public var id: UUID // required as of 2023-08-04
    @NSManaged public var name: String? // unused as of 2023-08-04
    @NSManaged public var category: String? // unused as of 2023-08-04
    @NSManaged public var favorite: Bool // unused as of 2023-08-04
    @NSManaged public var caloriesPer100g: Double // unused as of 2023-08-04
    @NSManaged public var carbsPer100g: Double // unused as of 2023-08-04
    @NSManaged public var sugarsPer100g: Double // unused as of 2023-08-04
    @NSManaged public var amount: Int64
    @NSManaged public var composedFoodItem: ComposedFoodItem // required as of 2023-08-04
    @NSManaged public var foodItem: FoodItem // required as of 2023-08-04

}

extension Ingredient : Identifiable {
    public static func == (lhs: Ingredient, rhs: Ingredient) -> Bool {
        lhs.id == rhs.id
    }
}
