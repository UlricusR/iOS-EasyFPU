//
//  Food.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 11.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation
import CoreData

class FoodItem: NSManagedObject, Identifiable {
    @NSManaged var name: String
    @NSManaged var favorite: Bool
    @NSManaged var caloriesPer100g: Double
    @NSManaged var carbsPer100g: Double
    //@NSManaged var typicalAmounts: [TypicalAmount]?
}

extension FoodItem {
    static func getAllFoodItems() -> NSFetchRequest<FoodItem> {
        let request: NSFetchRequest<FoodItem> = FoodItem.fetchRequest() as! NSFetchRequest<FoodItem>
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        return request
    }
}
