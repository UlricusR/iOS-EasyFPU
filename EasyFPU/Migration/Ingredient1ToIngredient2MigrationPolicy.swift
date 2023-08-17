//
//  Ingredient1ToIngredient2MigrationPolicy.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 07/08/2023.
//  Copyright © 2023 Ulrich Rüth. All rights reserved.
//

import Foundation
import CoreData

final class Ingredient1ToIngredient2MigrationPolicy: NSEntityMigrationPolicy {
    /**
     No Ingredient is created in the destination model, i.e., there will be no Ingredients
     */
    override func createDestinationInstances(forSource sourceIngredient: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        // Do nothing on purpose
    }
}
