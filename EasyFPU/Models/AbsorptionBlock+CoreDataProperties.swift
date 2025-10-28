//
//  AbsorptionBlock+CoreDataProperties.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 02.08.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//
//

import Foundation
import CoreData


extension AbsorptionBlock: Comparable {
    public static func < (lhs: AbsorptionBlock, rhs: AbsorptionBlock) -> Bool {
        lhs.maxFpu < rhs.maxFpu
    }
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AbsorptionBlock> {
        return NSFetchRequest<AbsorptionBlock>(entityName: "AbsorptionBlock")
    }

    @NSManaged public var maxFpu: Int64
    @NSManaged public var absorptionTime: Int64
    @NSManaged public var id: UUID?
    
    //
    // MARK: - Computed properties
    //
    
    
    
    //
    // MARK: - Custom functions
    //
    
    /// Updates the absorption time of the AbsorptionBlock and saves the context.
    /// - Parameter absorptionTime: The new absorption time in minutes.
    /// - Parameter saveContext: A Boolean indicating whether to save the Core Data context after updating.
    func updateAbsorptionTime(with absorptionTime: Int, saveContext: Bool) {
        self.absorptionTime = Int64(absorptionTime)
        if saveContext {
            CoreDataStack.shared.save()
        }
    }
    
    /// Updates the maximum FPU of the AbsorptionBlock and saves the context.
    /// - Parameter maxFpu: The new maximum FPU.
    /// - Parameter saveContext: A Boolean indicating whether to save the Core Data context after updating.
    func updateMaxFpu(with maxFpu: Int, saveContext: Bool) {
        self.maxFpu = Int64(maxFpu)
        if saveContext {
            CoreDataStack.shared.save()
        }
    }
    
    
}

extension AbsorptionBlock: Identifiable {
    public static func == (lhs: AbsorptionBlock, rhs: AbsorptionBlock) -> Bool {
        lhs.absorptionTime == rhs.absorptionTime && lhs.maxFpu == rhs.maxFpu
    }
}
