//
//  TypicalAmount+CoreDataProperties.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 15.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//
//

import Foundation
import CoreData


extension TypicalAmount {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TypicalAmount> {
        return NSFetchRequest<TypicalAmount>(entityName: "TypicalAmount")
    }

    @NSManaged public var amount: Int64
    @NSManaged public var comment: String?
    @NSManaged public var foodItem: FoodItem // required as of 2023-08-04
    @NSManaged public var id: UUID // required as of 2023-08-04
}

extension TypicalAmount: Identifiable {
    public static func == (lhs: TypicalAmount, rhs: TypicalAmount) -> Bool {
        lhs.id == rhs.id
    }
}
