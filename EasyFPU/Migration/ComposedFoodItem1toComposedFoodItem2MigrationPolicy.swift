//
//  ComposedFoodItem1toComposedFoodItem2MigrationPolicy.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 17/08/2023.
//  Copyright © 2023 Ulrich Rüth. All rights reserved.
//

import Foundation
import CoreData

final class ComposedFoodItem1ToComposedFoodItem2MigrationPolicy: NSEntityMigrationPolicy {
    /**
     No ComposedFoodItem is created in the destination model, i.e., there will be no ComposedFoodItems
     */
    override func createDestinationInstances(forSource sourceComposedFoodItem: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        // Do nothing on purpose
        debugPrint("Not migrating ComposedFoodItem with ID: \((sourceComposedFoodItem as? ComposedFoodItem)?.id.uuidString ?? "unknown")")
    }
}
