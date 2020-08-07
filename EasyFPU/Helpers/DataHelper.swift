//
//  DataHelper.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 04.08.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices

class DataHelper {
    static func loadDefaultAbsorptionBlocks() -> [AbsorptionBlockFromJson] {
        // Load default absorption scheme
        let absorptionSchemeDefaultFile = "absorptionscheme_default.json"
        guard let file = Bundle.main.url(forResource: absorptionSchemeDefaultFile, withExtension: nil) else {
            fatalError("Unable to load \(absorptionSchemeDefaultFile)")
        }
        do {
            let data = try Data(contentsOf: file)
            return DataHelper.decode(json: data, strategy: .convertFromSnakeCase) as [AbsorptionBlockFromJson]
        } catch {
            fatalError("Could not decode data of \(absorptionSchemeDefaultFile):\n\(error.localizedDescription)")
        }
    }
    
    static private func decode<T: Decodable>(json data: Data, strategy: JSONDecoder.KeyDecodingStrategy) -> T {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = strategy
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Couldn't parse data as \(T.self):\n\(error.localizedDescription)")
        }
    }
    
    static func exportFoodItems() -> Bool {
        let cdFoodItems = FoodItem.fetchAll()
        var foodItems = [FoodItemViewModel]()
        for cdFoodItem in cdFoodItems {
            foodItems.append(FoodItemViewModel(from: cdFoodItem))
        }
        let file = "\(UUID().uuidString).json"
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let contents = try encoder.encode(foodItems)
            guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                debugPrint("Could not open user directory")
                return false
            }
            let fileURL = dir.appendingPathComponent(file)
            try contents.write(to: fileURL)
            return true
        } catch {
            debugPrint(error)
            return false
        }
    }
}
