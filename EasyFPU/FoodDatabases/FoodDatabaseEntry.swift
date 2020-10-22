//
//  FoodDatabaseEntry.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 17.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

struct FoodDatabaseEntry: Identifiable, Equatable {
    var id = UUID()
    var name: String
    var caloriesPer100g: Double
    var carbsPer100g: Double
    var sugarsPer100g: Double
    var source: FoodDatabaseType
    var sourceId: String
    
    var thumbFrontUrl: URL?
    var imageFrontUrl: URL?
    var thumbNutrimentsUrl: URL?
    var imageNutrimentsUrl: URL?
    
    init?(from openFoodFactsProduct: OpenFoodFactsProduct) {
        source = UserSettings.shared.foodDatabase.databaseType
        
        guard let code = openFoodFactsProduct.code else {
            debugPrint(NSLocalizedString("Entry has no code", comment: ""))
            return nil
        }
        sourceId = code
        
        guard var productName = openFoodFactsProduct.productName else {
            debugPrint(NSLocalizedString("Entry has no name", comment: ""))
            return nil
        }
        if openFoodFactsProduct.brands != nil {
            productName += " (\(openFoodFactsProduct.brands!))"
        }
        name = productName
        
        do {
            caloriesPer100g = try openFoodFactsProduct.getNutrimentsDoubleValue(key: OpenFoodFactsProduct.NutrimentsKey.caloriesPer100g)
            carbsPer100g = try openFoodFactsProduct.getNutrimentsDoubleValue(key: OpenFoodFactsProduct.NutrimentsKey.carbsPer100g)
            sugarsPer100g = (try? openFoodFactsProduct.getNutrimentsDoubleValue(key: OpenFoodFactsProduct.NutrimentsKey.sugarsPer100g)) ?? 0.0
        } catch {
            debugPrint(error.localizedDescription)
            return nil
        }
    }
}
