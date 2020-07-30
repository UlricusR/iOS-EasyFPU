//
//  AbsorptionBlock+CoreDataProperties.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 30.07.20.
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

}
