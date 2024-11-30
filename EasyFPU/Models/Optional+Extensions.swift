//
//  Optional+Extensions.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 22/10/2024.
//  Copyright © 2024 Ulrich Rüth. All rights reserved.
//

/*
 * Returns Array from optional NSSet. Returns empty array if NSSet is nil.
 * It's useful for when you want an Array of objects from a Core Data many relationship.
 *
 * Example usage with managed object `game` with 1-to-many relationship to `Goal` entity:
 *    let goalArray = game.goals.array(of: Goal.self)
 */

import CoreData

extension Optional where Wrapped == NSSet {
    func array<T: Hashable>(of: T.Type) -> [T] {
        if let set = self as? Set<T> {
            return Array(set)
        }
        return [T]()
    }
}
