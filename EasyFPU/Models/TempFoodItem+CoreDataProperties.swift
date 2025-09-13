//
//  TempFoodItem+CoreDataProperties.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 13/09/2025.
//  Copyright © 2025 Ulrich Rüth. All rights reserved.
//
//

import Foundation
import CoreData


extension TempFoodItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TempFoodItem> {
        return NSFetchRequest<TempFoodItem>(entityName: "TempFoodItem")
    }


}
