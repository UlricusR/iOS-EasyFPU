//
//  DataWrapper.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 17/08/2023.
//  Copyright © 2023 Ulrich Rüth. All rights reserved.
//

import Foundation

class DataWrapper: Codable {
    var dataModelVersion: DataModelVersion
    var foodItemVMs: [FoodItemViewModel]
    
    enum CodingKeys: String, CodingKey {
        case dataModelVersion
        case foodItems
    }
    
    init(dataModelVersion: DataModelVersion, foodItemVMs: [FoodItemViewModel]) {
        self.dataModelVersion = dataModelVersion
        self.foodItemVMs = foodItemVMs
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var dataModelVersionString = try container.decode(String.self, forKey: .dataModelVersion)
        guard let dataModelVersion = DataModelVersion(rawValue: dataModelVersionString) else {
            throw DataVersionFinder.DataModelError.invalidDataModelVersion("'" + dataModelVersionString + "' " + NSLocalizedString("is not a valid data model", comment: ""))
        }
        self.dataModelVersion = dataModelVersion
        self.foodItemVMs = try container.decode([FoodItemViewModel].self, forKey: .foodItems)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(dataModelVersion.rawValue, forKey: .dataModelVersion)
        try container.encode(foodItemVMs, forKey: .foodItems)
    }
}
