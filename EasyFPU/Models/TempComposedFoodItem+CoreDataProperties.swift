//
//  TempComposedFoodItem+CoreDataProperties.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 12/09/2025.
//  Copyright © 2025 Ulrich Rüth. All rights reserved.
//
//

import Foundation
import CoreData


extension TempComposedFoodItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TempComposedFoodItem> {
        return NSFetchRequest<TempComposedFoodItem>(entityName: "TempComposedFoodItem")
    }


}
