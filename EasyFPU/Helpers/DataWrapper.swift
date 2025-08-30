//
//  DataWrapper.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 17/08/2023.
//  Copyright © 2023 Ulrich Rüth. All rights reserved.
//

import Foundation
import CoreTransferable

class DataWrapper: Codable {
    var dataModelVersion: DataModelVersion
    var foodItemVMs: [FoodItemViewModel]
    var composedFoodItemVMs: [ComposedFoodItemViewModel]
    
    enum CodingKeys: String, CodingKey {
        case dataModelVersion
        case foodItems
        case recipes
    }
    
    init() {
        dataModelVersion = DataModelVersion.latest
        foodItemVMs = []
        composedFoodItemVMs = []
    }
    
    init(dataModelVersion: DataModelVersion, foodItemVMs: [FoodItemViewModel], composedFoodItemVMs: [ComposedFoodItemViewModel]) {
        self.dataModelVersion = dataModelVersion
        self.foodItemVMs = foodItemVMs
        self.composedFoodItemVMs = composedFoodItemVMs
    }
    
    init(dataModelVersion: DataModelVersion, foodItems: [FoodItem], composedFoodItems: [ComposedFoodItem]) {
        self.dataModelVersion = dataModelVersion
        
        var foodItemVMs: [FoodItemViewModel] = []
        for foodItem in foodItems {
            let foodItemVM = FoodItemViewModel(from: foodItem)
            foodItemVMs.append(foodItemVM)
        }
        self.foodItemVMs = foodItemVMs
        
        var composedFoodItemVMs: [ComposedFoodItemViewModel] = []
        for composedFoodItem in composedFoodItems {
            let composedFoodItemVM = ComposedFoodItemViewModel(from: composedFoodItem)
            composedFoodItemVMs.append(composedFoodItemVM)
        }
        self.composedFoodItemVMs = composedFoodItemVMs
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dataModelVersionString = try container.decode(String.self, forKey: .dataModelVersion)
        guard let dataModelVersion = DataModelVersion(rawValue: dataModelVersionString) else {
            throw DataVersionFinder.DataModelError.invalidDataModelVersion("'" + dataModelVersionString + "' " + NSLocalizedString("is not a valid data model", comment: ""))
        }
        self.dataModelVersion = dataModelVersion
        self.foodItemVMs = try container.decode([FoodItemViewModel].self, forKey: .foodItems)
        self.composedFoodItemVMs = try container.decode([ComposedFoodItemViewModel].self, forKey: .recipes)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(dataModelVersion.rawValue, forKey: .dataModelVersion)
        try container.encode(foodItemVMs, forKey: .foodItems)
        try container.encode(composedFoodItemVMs, forKey: .recipes)
    }
}

extension DataWrapper: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .foodDataType)
        
        DataRepresentation(importedContentType: .foodDataType) { data in
            let wrappedData = try JSONDecoder().decode(DataWrapper.self, from: data)
            return wrappedData
        }
        
        DataRepresentation(exportedContentType: .foodDataType) { wrappedData in
            let data = try JSONEncoder().encode(wrappedData)
            return data
        }
        
        FileRepresentation(contentType: .foodDataType) { wrappedData in
            let docsURL = URL.temporaryDirectory.appendingPathComponent("\(UUID().uuidString)", conformingTo: .foodDataType)
            let data = try JSONEncoder().encode(wrappedData)
            try data.write(to: docsURL)
            return SentTransferredFile(docsURL)
        } importing: { received in
            let data = try Data(contentsOf: received.file)
            let wrappedData = try JSONDecoder().decode(DataWrapper.self, from: data)
            return wrappedData
        }
    }
}

