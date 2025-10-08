//
//  FoodDatabaseEntry.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 17.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

@Observable class FoodDatabaseEntry: Identifiable, Equatable, Hashable {
    var id = UUID()
    var productName: String
    var brandName: String?
    var category: FoodItemCategory
    var quantity: Double
    var quantityUnit: FoodItemUnit
    var caloriesPer100g: EnergyType
    var carbsPer100g: Double
    var sugarsPer100g: Double
    var source: FoodDatabaseType
    var sourceId: String
    
    var imageFront: FoodDatabaseImage?
    var imageNutriments: FoodDatabaseImage?
    var imageIngredients: FoodDatabaseImage?
    
    var name: String {
        if brandName != nil {
            return "\(productName) (\(brandName!))"
        } else {
            return productName
        }
    }
    
    init?(from openFoodFactsProduct: OpenFoodFactsProduct, category: FoodItemCategory) {
        self.category = category
        
        source = UserSettings.shared.foodDatabase.databaseType
        
        guard let code = openFoodFactsProduct.code else {
            debugPrint(NSLocalizedString("Entry has no code", comment: ""))
            return nil
        }
        sourceId = code
        
        productName = openFoodFactsProduct.productName
        brandName = openFoodFactsProduct.brands
        quantity = (try? openFoodFactsProduct.getQuantity()) ?? 0.0
        
        quantityUnit = openFoodFactsProduct.quantityUnit
        
        if let caloriesPer100gInKcal = try? openFoodFactsProduct.getNutrimentsDoubleValue(key: OpenFoodFactsProduct.NutrimentsKey.caloriesPer100gInKcal) {
            caloriesPer100g = .kcal(caloriesPer100gInKcal)
        } else if let caloriesPer100gInKJ = try? openFoodFactsProduct.getNutrimentsDoubleValue(key: OpenFoodFactsProduct.NutrimentsKey.caloriesPer100gInKJ) {
            caloriesPer100g = .kJ(caloriesPer100gInKJ)
        } else {
            return nil
        }
        
        sugarsPer100g = (try? openFoodFactsProduct.getNutrimentsDoubleValue(key: OpenFoodFactsProduct.NutrimentsKey.sugarsPer100g)) ?? 0.0
        
        do {
            carbsPer100g = try openFoodFactsProduct.getNutrimentsDoubleValue(key: OpenFoodFactsProduct.NutrimentsKey.carbsPer100g)
        } catch {
            debugPrint(error.localizedDescription)
            return nil
        }
        
        // Identify the right images
        if let frontImages = openFoodFactsProduct.selectedImages?.front {
            imageFront = try? fillImageProperties(frontImages)
        }
        
        if let nutritionImages = openFoodFactsProduct.selectedImages?.nutrition {
            imageNutriments = try? fillImageProperties(nutritionImages)
        }
        
        if let ingredientsImages = openFoodFactsProduct.selectedImages?.ingredients {
            imageIngredients = try? fillImageProperties(ingredientsImages)
        }
    }
    
    private func fillImageProperties(_ productImages: OpenFoodFactsProductImages) throws -> FoodDatabaseImage {
        var display: URL? = nil // Usually 400 px
        var small: URL? = nil // Usually 200 px
        var thumb: URL? = nil // Usually 100 px
        
        let countryCode: String? = UserSettings.getCountryCode()?.lowercased()
        var randomCountryCode: String? = nil
        
        // First try to get the large display image
        if let images = productImages.display { // We have display images
            try setImageUrl(for: &display, using: images, countryCode: countryCode, randomCountryCode: &randomCountryCode)
        }
        
        // Then address the mid-size small image
        if let images = productImages.small { // We have small images
            try setImageUrl(for: &small, using: images, countryCode: countryCode, randomCountryCode: &randomCountryCode)
        }
        
        // Finally try the small thumbs
        if let images = productImages.thumb { // We have thumbs
            try setImageUrl(for: &thumb, using: images, countryCode: countryCode, randomCountryCode: &randomCountryCode)
        }
        
        // Assign to image
        if display != nil { // We have a large display image
            if small != nil { // We have a small image
                return FoodDatabaseImage(thumb: small!, image: display!)
            } else if thumb != nil {
                return FoodDatabaseImage(thumb: thumb!, image: display!)
            } else {
                return FoodDatabaseImage(thumb: display!, image: display!)
            }
        } else if small != nil {
            return FoodDatabaseImage(thumb: small!, image: small!)
        } else if thumb != nil {
            return FoodDatabaseImage(thumb: thumb!, image: thumb!)
        } else {
            throw FoodDatabaseError.inputError(NSLocalizedString("No image data found", comment: ""))
        }
    }
    
    private func setImageUrl(for image: inout URL?, using urls: [String: String], countryCode: String?, randomCountryCode: inout String?) throws {
        if countryCode != nil { // We have a country code
            if let urlString = urls[countryCode!] { // We have the right image for the country code
                if let url = URL(string: urlString) {
                    image = url
                } else { // Unable to create URL
                    throw FoodDatabaseError.networkError(NSLocalizedString("Unable to create image url from " + urlString, comment: ""))
                }
            }
        } else if randomCountryCode != nil { // We have no country code, so try to re-use the one set during searching display image
            if let urlString = urls[randomCountryCode!] { // We have the right image for the random country code
                if let url = URL(string: urlString) {
                    image = url
                } else { // Unable to create URL
                    throw FoodDatabaseError.networkError(NSLocalizedString("Unable to create image url from " + urlString, comment: ""))
                }
            }
        } else { // We have no country code at all, so use another random image
            if let imageObject = urls.randomElement() {
                // Set the countryCode
                randomCountryCode = imageObject.key
                if let imageUrl = URL(string: imageObject.value) {
                    image = imageUrl
                } else { // Unable to create URL
                    throw FoodDatabaseError.networkError(NSLocalizedString("Unable to create image url from " + imageObject.value, comment: ""))
                }
            }
        }
    }
    
    static func == (lhs: FoodDatabaseEntry, rhs: FoodDatabaseEntry) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct FoodDatabaseImage: Identifiable, Equatable {
    var id = UUID()
    var thumb: URL
    var image: URL
}
