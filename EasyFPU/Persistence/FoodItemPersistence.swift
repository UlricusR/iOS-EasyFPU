//
//  FoodItemViewModel.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 24.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class FoodItemPersistence: Codable, Hashable, Identifiable {
    var id: UUID
    var name: String
    var favorite: Bool
    var category: FoodItemCategory
    var foodCategory: FoodCategory? = nil
    var caloriesPer100g: Double = 0.0
    var carbsPer100g: Double = 0.0
    var sugarsPer100g: Double = 0.0
    var sourceID: String?
    var sourceDB: FoodDatabaseType?
    var amount: Int = 0
    var typicalAmounts = [TypicalAmountPersistence]()
    private(set) var isClone: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case foodItem
        case id, name, foodCategory, category, favorite, amount, caloriesPer100g, carbsPer100g, sugarsPer100g, sourceID, sourceDB
        case typicalAmounts
    }
    
    /// Initializes the FoodItemViewModel from numeric values for the nutritional values and the amount.
    /// Their string representations will be generated, using the decimal separator of the current locale.
    /// - Parameters:
    ///   - id: The ID of the food item.
    ///   - name: The name of the food item.
    ///   - foodCategory: The food category of the food item, can be nil.
    ///   - category: The category of the food item.
    ///   - favorite: Whether the food item is a favorite.
    ///   - caloriesPer100g: The calories per 100g of the food item.
    ///   - carbsPer100g: The carbs per 100g of the food item.
    ///   - sugarsPer100g: The sugars per 100g of the food item.
    ///   - amount: The amount of the food item.
    ///   - sourceID: The ID of the food item in a source food database (normally the barcode ID)
    ///   - sourceDB: The food database the sourceID relates to
    init(id: UUID, name: String, foodCategory: FoodCategory?, category: FoodItemCategory, favorite: Bool, caloriesPer100g: Double, carbsPer100g: Double, sugarsPer100g: Double, amount: Int, sourceID: String?, sourceDB: FoodDatabaseType?) {
        self.id = id
        self.name = name
        self.foodCategory = foodCategory
        self.category = category
        self.favorite = favorite
        self.caloriesPer100g = caloriesPer100g
        self.carbsPer100g = carbsPer100g
        self.sugarsPer100g = sugarsPer100g
        self.amount = amount
        self.sourceID = sourceID
        self.sourceDB = sourceDB
    }
    
    convenience init?(from cdIngredient: Ingredient) {
        guard cdIngredient.foodItem != nil else { return nil }
        self.init(from: cdIngredient.foodItem!)
        self.amount = Int(cdIngredient.amount)
    }
    
    /// Initializes the FoodItemViewModel from a Core Data FoodItem. If the Core Data FoodItem is related to TypicalAmounts, TypicalAmountViewModels will be added.
    /// - Parameter cdFoodItem: The source Core Data FoodItem.
    init(from cdFoodItem: FoodItem) {
        // Use ID from Core Date FoodItem
        self.id = cdFoodItem.id
        self.name = cdFoodItem.name
        self.foodCategory = cdFoodItem.foodCategory
        self.category = FoodItemCategory.init(rawValue: cdFoodItem.category) ?? FoodItemCategory.product // Default is product
        self.favorite = cdFoodItem.favorite
        self.caloriesPer100g = cdFoodItem.caloriesPer100g
        self.carbsPer100g = cdFoodItem.carbsPer100g
        self.sugarsPer100g = cdFoodItem.sugarsPer100g
        self.sourceID = cdFoodItem.sourceID
        self.sourceDB = (cdFoodItem.sourceDB != nil) ? FoodDatabaseType(rawValue: cdFoodItem.sourceDB!) : nil
        
        if cdFoodItem.typicalAmounts != nil {
            for typicalAmount in cdFoodItem.typicalAmounts!.allObjects as! [TypicalAmount] {
                typicalAmounts.append(TypicalAmountPersistence(from: typicalAmount))
            }
        }
    }
    
    /// Decodes the FoodItemViewModel from a decoder. This is used for import from JSON files.
    /// - Parameter decoder: The decoder to decode from.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let foodItem = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .foodItem)
        
        // Data model version 1 had no ID, therefore we need to catch this separately
        do {
            let uuidString = try foodItem.decode(String.self, forKey: .id)
            
            // Success --> we overwrite the id (and generate a new one if this goes wrong)
            self.id = UUID(uuidString: uuidString) ?? UUID()
        } catch {
            // We generate a new UUID
            self.id = UUID()
        }
        self.name = try foodItem.decode(String.self, forKey: .name)
        let category = try FoodItemCategory.init(rawValue: foodItem.decode(String.self, forKey: .category)) ?? .product
        self.category = category
        if let foodCategoryString = try? foodItem.decode(String.self, forKey: .foodCategory) {
            self.foodCategory = FoodCategory.getFoodCategoriesByName(name: foodCategoryString, category: category)?.first
        }
        self.favorite = try foodItem.decode(Bool.self, forKey: .favorite)
        self.amount = try foodItem.decode(Int.self, forKey: .amount)
        self.caloriesPer100g = try foodItem.decode(Double.self, forKey: .caloriesPer100g)
        self.carbsPer100g = try foodItem.decode(Double.self, forKey: .carbsPer100g)
        self.sugarsPer100g = try foodItem.decode(Double.self, forKey: .sugarsPer100g)
        self.sourceID = try? foodItem.decode(String.self, forKey: .sourceID)
        if let sourceDBString = try? foodItem.decode(String.self, forKey: .sourceDB) {
            self.sourceDB = FoodDatabaseType(rawValue: sourceDBString)
        }
        self.typicalAmounts = try foodItem.decode([TypicalAmountPersistence].self, forKey: .typicalAmounts)
    }
    
    func getCalories() -> Double {
        Double(self.amount) / 100 * self.caloriesPer100g
    }
    
    func getCarbsInclSugars() -> Double {
        Double(self.amount) / 100 * self.carbsPer100g
    }
    
    func getSugarsOnly() -> Double {
        Double(self.amount) / 100 * self.sugarsPer100g
    }
    
    func getRegularCarbs(treatSugarsSeparately: Bool) -> Double {
        Double(self.amount) / 100 * (treatSugarsSeparately ? (self.carbsPer100g - self.sugarsPer100g) : self.carbsPer100g)
    }
    
    func getSugars(treatSugarsSeparately: Bool) -> Double {
        Double(self.amount) / 100 * (treatSugarsSeparately ? self.sugarsPer100g : 0)
    }
    
    func getFPU() -> FPU {
        // 1g carbs has ~4 kcal, so calculate carb portion of calories
        let carbsCal = Double(self.amount) / 100 * self.carbsPer100g * 4;

        // The carbs from fat and protein is the remainder
        let calFromFP = getCalories() - carbsCal;

        // 100kcal makes 1 FPU
        let fpus = calFromFP / 100;

        // Create and return the FPU object
        return FPU(fpu: fpus)
    }
    
    /// Saves the FoodItemViewModel to a Core Data FoodItem
    func save() {
        // Never save a clone to Core Data!
        guard isClone == false else {
            debugPrint("Fatal error: Cannot save a clone to Core Data!")
            return
        }
        
        // Check for an existing FoodItem with same ID
        if let existingFoodItem = FoodItem.getFoodItemByID(id: self.id) {
            if FoodItemPersistence.hasSameNutritionalValues(lhs: existingFoodItem, rhs: self) {
                // In case of an existing FoodItem with identical nutritional values, no new FoodItem needs to be created
                return
            } else {
                // Otherwise we need to create a new UUID before saving the VM to Core Data
                self.id = UUID()
            }
        }
        
        // Create the new FoodItem
        var dataError: FoodItemDataError = .none
        guard FoodItem.create(from: self, saveContext: true, dataError: &dataError) != nil else {
            debugPrint("Error saving FoodItem: \(dataError)")
            return
        }
    }
    
    /// Checks if two FoodItemViewModels have the same nutritional values.
    /// - Parameters: otherFoodItemVM: The other FoodItemViewModel to compare with.
    /// - Returns: True if the nutritional values are the same, false otherwise.
    func hasDifferentNutritionalValues(comparedTo otherFoodItemVM: FoodItemPersistence) -> Bool {
        return self.caloriesPer100g != otherFoodItemVM.caloriesPer100g || self.carbsPer100g != otherFoodItemVM.carbsPer100g || self.sugarsPer100g != otherFoodItemVM.sugarsPer100g
    }
    
    /// Exports the FoodItemViewModel to a JSON file in the app's document directory.
    /// The file is named <name>.fooditem, where <name> is the name
    /// - Returns: The URL of the exported file, or nil if the export failed.
    func exportToURL() -> URL? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let encoded = try? encoder.encode(self) else { return nil }
        
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        guard let path = documents?.appendingPathComponent("/\(name).fooditem") else {
            return nil
        }
        
        do {
            try encoded.write(to: path, options: .atomicWrite)
            return path
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    /// Encodes the FoodItemViewModel to an encoder. This is used for export to JSON files.
    /// - Parameter encoder: The encoder to encode to.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var foodItem = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .foodItem)
        try foodItem.encode(id.uuidString, forKey: .id)
        try foodItem.encode(name, forKey: .name)
        try foodItem.encode(category.rawValue, forKey: .category)
        try foodItem.encode(favorite, forKey: .favorite)
        try foodItem.encode(amount, forKey: .amount)
        try foodItem.encode(caloriesPer100g, forKey: .caloriesPer100g)
        try foodItem.encode(carbsPer100g, forKey: .carbsPer100g)
        try foodItem.encode(sugarsPer100g, forKey: .sugarsPer100g)
        if sourceID != nil { try foodItem.encode(sourceID, forKey: .sourceID) }
        if sourceDB != nil { try foodItem.encode(sourceDB?.rawValue, forKey: .sourceDB) }
        try foodItem.encode(typicalAmounts, forKey: .typicalAmounts)
    }
    
    static func == (lhs: FoodItemPersistence, rhs: FoodItemPersistence) -> Bool {
        lhs.id == rhs.id
    }

    /// Compares the nutritional values (calories per 100g, carbs per 100g, sugars per 100g) of a FoodItem and a FoodItemViewModel.
    /// - Parameters:
    ///   - lhs: The FoodItem to be compared.
    ///   - rhs: The FoodItemViewModel to be compared.
    /// - Returns: True if all nutritional values are identical.
    static func hasSameNutritionalValues(lhs: FoodItem, rhs: FoodItemPersistence) -> Bool {
        lhs.caloriesPer100g == rhs.caloriesPer100g &&
        lhs.carbsPer100g == rhs.carbsPer100g &&
        lhs.sugarsPer100g == rhs.sugarsPer100g
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func sampleData() -> FoodItemPersistence {
        let foodItemVM = FoodItemPersistence(
            id: UUID(),
            name: "Sample Food Item",
            foodCategory: nil,
            category: .product,
            favorite: false,
            caloriesPer100g: 100.0,
            carbsPer100g: 10.0,
            sugarsPer100g: 5.0,
            amount: 100,
            sourceID: nil,
            sourceDB: nil
        )
        
        foodItemVM.typicalAmounts.append(TypicalAmountPersistence(amount: 100, comment: "As sold"))
        foodItemVM.typicalAmounts.append(TypicalAmountPersistence(amount: 25, comment: "As served"))
        
        return foodItemVM
    }
}
