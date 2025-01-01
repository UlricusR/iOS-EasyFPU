//
//  FoodItemViewModel.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 24.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

enum FoodItemViewModelError: Equatable {
    case name(String), calories(String), carbs(String), sugars(String), amount(String), tooMuchCarbs(String), tooMuchSugars(String)
    case none
}

enum FoodItemCategory: String {
    case product = "Product"
    case ingredient = "Ingredient"
}

enum FoodItemUnit: String {
    case gram = "g"
    case milliliter = "ml"
    
    init?(rawValue: String) {
        switch rawValue {
        case FoodItemUnit.gram.rawValue:
            self = .gram
        case FoodItemUnit.milliliter.rawValue:
            self = .milliliter
        default:
            return nil
        }
    }
}

class FoodItemViewModel: ObservableObject, Codable, Hashable, Identifiable, VariableAmountItem {
    var id: UUID
    @Published var name: String
    @Published var favorite: Bool
    @Published var caloriesPer100gAsString: String = "" {
        willSet {
            let result = DataHelper.checkForPositiveDouble(valueAsString: newValue, allowZero: true)
            switch result {
            case .success(let caloriesAsDouble):
                caloriesPer100g = caloriesAsDouble
            case .failure(let err):
                debugPrint(err.evaluate())
                return
            }
        }
    }
    @Published var carbsPer100gAsString: String = "" {
        willSet {
            let result = DataHelper.checkForPositiveDouble(valueAsString: newValue, allowZero: true)
            switch result {
            case .success(let carbsAsDouble):
                carbsPer100g = carbsAsDouble
            case .failure(let err):
                debugPrint(err.evaluate())
                return
            }
        }
    }
    @Published var sugarsPer100gAsString: String = "" {
        willSet {
            let result = DataHelper.checkForPositiveDouble(valueAsString: newValue, allowZero: true)
            switch result {
            case .success(let sugarsAsDouble):
                sugarsPer100g = sugarsAsDouble
            case .failure(let err):
                debugPrint(err.evaluate())
                return
            }
        }
    }
    @Published var amountAsString: String = "" {
        willSet {
            let result = DataHelper.checkForPositiveInt(valueAsString: newValue, allowZero: true)
            switch result {
            case .success(let amountAsInt):
                amount = amountAsInt
            case .failure(let err):
                debugPrint(err.evaluate())
                return
            }
        }
    }
    @Published var category: FoodItemCategory
    private(set) var caloriesPer100g: Double = 0.0
    private(set) var carbsPer100g: Double = 0.0
    private(set) var sugarsPer100g: Double = 0.0
    var sourceID: String?
    var sourceDB: FoodDatabaseType?
    @Published var amount: Int = 0
    @Published var typicalAmounts = [TypicalAmountViewModel]()
    var cdFoodItem: FoodItem?
    
    enum CodingKeys: String, CodingKey {
        case foodItem
        case id, name, category, favorite, amount, caloriesPer100g, carbsPer100g, sugarsPer100g, sourceID, sourceDB
        case typicalAmounts
    }
    
    /// Initializes the FoodItemViewModel from numeric values for the nutritional values and the amount.
    /// Their string representations will be generated, using the decimal separator of the current locale.
    /// - Parameters:
    ///   - id: The ID of the food item.
    ///   - name: The name of the food item.
    ///   - category: The category of the food item.
    ///   - favorite: Whether the food item is a favorite.
    ///   - caloriesPer100g: The calories per 100g of the food item.
    ///   - carbsPer100g: The carbs per 100g of the food item.
    ///   - sugarsPer100g: The sugars per 100g of the food item.
    ///   - amount: The amount of the food item.
    ///   - sourceID: The ID of the food item in a source food database (normally the barcode ID)
    ///   - sourceDB: The food database the sourceID relates to
    init(id: UUID, name: String, category: FoodItemCategory, favorite: Bool, caloriesPer100g: Double, carbsPer100g: Double, sugarsPer100g: Double, amount: Int, sourceID: String?, sourceDB: FoodDatabaseType?) {
        self.id = id
        self.name = name
        self.category = category
        self.favorite = favorite
        self.caloriesPer100g = caloriesPer100g
        self.carbsPer100g = carbsPer100g
        self.sugarsPer100g = sugarsPer100g
        self.amount = amount
        self.sourceID = sourceID
        self.sourceDB = sourceDB
        
        initStringRepresentations(amount: amount, carbsPer100g: carbsPer100g, caloriesPer100g: caloriesPer100g, sugarsPer100g: sugarsPer100g)
    }
    
    /// Initializes the FoodItemViewModel from a Core Data FoodItem. If the Core Data FoodItem is related to TypicalAmounts, TypicalAmountViewModels will be added.
    /// - Parameter cdFoodItem: The source Core Data FoodItem.
    init(from cdFoodItem: FoodItem) {
        // Use ID from Core Date FoodItem
        self.id = cdFoodItem.id
        self.name = cdFoodItem.name
        self.category = FoodItemCategory.init(rawValue: cdFoodItem.category) ?? FoodItemCategory.product // Default is product
        self.favorite = cdFoodItem.favorite
        self.caloriesPer100g = cdFoodItem.caloriesPer100g
        self.carbsPer100g = cdFoodItem.carbsPer100g
        self.sugarsPer100g = cdFoodItem.sugarsPer100g
        self.sourceID = cdFoodItem.sourceID
        self.sourceDB = (cdFoodItem.sourceDB != nil) ? FoodDatabaseType(rawValue: cdFoodItem.sourceDB!) : nil
        self.cdFoodItem = cdFoodItem
        
        initStringRepresentations(amount: amount, carbsPer100g: carbsPer100g, caloriesPer100g: caloriesPer100g, sugarsPer100g: sugarsPer100g)
        
        if cdFoodItem.typicalAmounts != nil {
            for typicalAmount in cdFoodItem.typicalAmounts!.allObjects {
                let castedTypicalAmount = typicalAmount as! TypicalAmount
                typicalAmounts.append(TypicalAmountViewModel(from: castedTypicalAmount))
            }
        }
    }
    
    /// Initializes the FoodItemViewModel from string representations of the nutritional values and the amount.
    /// In case of decimal numbers, the decimal separator needs to match the current locale.
    /// - Parameters:
    ///   - id: The ID of the food item.
    ///   - name: The name of the food item.
    ///   - category: The category of the food item.
    ///   - favorite: Whether the food item is a favorite.
    ///   - caloriesAsString: The string representation of a decimal number of the calories per 100g of the food item.
    ///   - carbsAsString: The string representation of a decimal number of the carbs per 100g of the food item.
    ///   - sugarsAsString: The string representation of a decimal number of the sugars per 100g of the food item.
    ///   - amountAsString: The string representation of a integer number of the amount of the food item.
    ///   - error: Stores potential errors when creating the food item, e.g., unsuccessful conversion of the string representations into numbers.
    init?(id: UUID, name: String, category: FoodItemCategory, favorite: Bool, caloriesAsString: String, carbsAsString: String, sugarsAsString: String, amountAsString: String, error: inout FoodItemViewModelError, sourceID: String?, sourceDB: FoodDatabaseType?) {
        // Check for a correct name
        let foodName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if foodName == "" {
            error = .name(NSLocalizedString("Name must not be empty", comment: ""))
            return nil
        } else {
            self.name = foodName
        }
        
        // Generate ID
        self.id = id
        
        // Set category
        self.category = category
        
        // Set favorite
        self.favorite = favorite
        
        // Check for valid calories
        let caloriesResult = DataHelper.checkForPositiveDouble(valueAsString: caloriesAsString == "" ? "0" : caloriesAsString, allowZero: true)
        switch caloriesResult {
        case .success(let caloriesAsDouble):
            caloriesPer100g = caloriesAsDouble
        case .failure(let err):
            let errorMessage = err.evaluate()
            error = .calories(errorMessage)
            return nil
        }
        self.caloriesPer100gAsString = caloriesAsString
        
        // Check for valid carbs
        let carbsResult = DataHelper.checkForPositiveDouble(valueAsString: carbsAsString == "" ? "0" : carbsAsString, allowZero: true)
        switch carbsResult {
        case .success(let carbsAsDouble):
            carbsPer100g = carbsAsDouble
        case .failure(let err):
            let errorMessage = err.evaluate()
            error = .carbs(errorMessage)
            return nil
        }
        self.carbsPer100gAsString = carbsAsString
        
        // Check for valid sugars
        let sugarsResult = DataHelper.checkForPositiveDouble(valueAsString: sugarsAsString == "" ? "0" : sugarsAsString, allowZero: true)
        switch sugarsResult {
        case .success(let sugarsAsDouble):
            sugarsPer100g = sugarsAsDouble
        case .failure(let err):
            let errorMessage = err.evaluate()
            error = .sugars(errorMessage)
            return nil
        }
        self.sugarsPer100gAsString = sugarsAsString
        
        // Check if sugars exceed carbs
        if sugarsPer100g > carbsPer100g {
            error = .tooMuchSugars(NSLocalizedString("Sugars exceed carbs", comment: ""))
            return nil
        }
        
        // Check if calories from carbs exceed total calories
        if carbsPer100g * 4 > caloriesPer100g {
            error = .tooMuchCarbs(NSLocalizedString("Calories from carbs (4 kcal per gram) exceed total calories", comment: ""))
            return nil
        }
        
        // Check for valid amount
        let amountResult = DataHelper.checkForPositiveInt(valueAsString: amountAsString == "" ? "0" : amountAsString, allowZero: true)
        switch amountResult {
        case .success(let amountAsInt):
            amount = amountAsInt
        case .failure(let err):
            let errorMessage = err.evaluate()
            error = .amount(errorMessage)
            return nil
        }
        self.amountAsString = amountAsString
        
        // Food database entry
        self.sourceID = sourceID
        self.sourceDB = sourceDB
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let foodItem = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .foodItem)
        
        // Data model version 1 had no ID, therefore we need to catch this separately
        do {
            let uuidString = try foodItem.decode(String.self, forKey: .id)
            
            // Success --> we overwrite the id (and generate a new one if this goes wrong)
            id = UUID(uuidString: uuidString) ?? UUID()
        } catch {
            // We generate a new UUID
            id = UUID()
        }
        name = try foodItem.decode(String.self, forKey: .name)
        category = try FoodItemCategory.init(rawValue: foodItem.decode(String.self, forKey: .category)) ?? .product
        favorite = try foodItem.decode(Bool.self, forKey: .favorite)
        amount = try foodItem.decode(Int.self, forKey: .amount)
        caloriesPer100g = try foodItem.decode(Double.self, forKey: .caloriesPer100g)
        carbsPer100g = try foodItem.decode(Double.self, forKey: .carbsPer100g)
        sugarsPer100g = try foodItem.decode(Double.self, forKey: .sugarsPer100g)
        sourceID = try? foodItem.decode(String.self, forKey: .sourceID)
        if let sourceDBString = try? foodItem.decode(String.self, forKey: .sourceDB) {
            sourceDB = FoodDatabaseType(rawValue: sourceDBString)
        }
        typicalAmounts = try foodItem.decode([TypicalAmountViewModel].self, forKey: .typicalAmounts)
        
        guard
            let caloriesAsString = DataHelper.doubleFormatter(numberOfDigits: 5).string(from: NSNumber(value: caloriesPer100g)),
            let carbsAsString = DataHelper.doubleFormatter(numberOfDigits: 5).string(from: NSNumber(value: carbsPer100g)),
            let sugarsAsString = DataHelper.doubleFormatter(numberOfDigits: 5).string(from: NSNumber(value: sugarsPer100g)),
            let amountAsString = DataHelper.intFormatter.string(from: NSNumber(value: amount))
        else {
            throw InvalidNumberError.inputError(NSLocalizedString("Fatal error: Cannot convert numbers into string, please contact app developer", comment: ""))
        }
        self.caloriesPer100gAsString = caloriesAsString
        self.carbsPer100gAsString = carbsAsString
        self.sugarsPer100gAsString = sugarsAsString
        self.amountAsString = amountAsString
    }
    
    private func initStringRepresentations(amount: Int, carbsPer100g: Double, caloriesPer100g: Double, sugarsPer100g: Double) {
        self.caloriesPer100gAsString = caloriesPer100g == 0 ? "" : DataHelper.doubleFormatter(numberOfDigits: 5).string(from: NSNumber(value: caloriesPer100g))!
        self.carbsPer100gAsString = carbsPer100g == 0 ? "" : DataHelper.doubleFormatter(numberOfDigits: 5).string(from: NSNumber(value: carbsPer100g))!
        self.sugarsPer100gAsString = sugarsPer100g == 0 ? "" : DataHelper.doubleFormatter(numberOfDigits: 5).string(from: NSNumber(value: sugarsPer100g))!
        self.amountAsString = amount == 0 ? "" : DataHelper.intFormatter.string(from: NSNumber(value: amount))!
    }
    
    func fill(with foodDatabaseEntry: FoodDatabaseEntry) {
        name = foodDatabaseEntry.name
        category = foodDatabaseEntry.category
        sourceID = foodDatabaseEntry.sourceId
        sourceDB = foodDatabaseEntry.source
        
        // When setting string representations, number will be set implicitely
        caloriesPer100gAsString = DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: foodDatabaseEntry.caloriesPer100g.getEnergyInKcal()))!
        carbsPer100gAsString = DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: foodDatabaseEntry.carbsPer100g))!
        sugarsPer100gAsString = DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: foodDatabaseEntry.sugarsPer100g))!
        
        // Add the quantity as typical amount if available
        if foodDatabaseEntry.quantity > 0 && foodDatabaseEntry.quantityUnit == FoodItemUnit.gram {
            typicalAmounts.append(TypicalAmountViewModel(amount: Int(foodDatabaseEntry.quantity), comment: NSLocalizedString("As sold", comment: "")))
        }
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
    
    /**
     Returns the names of the recipes associated with this food item.
     
     - Returns: The names of the associated recipes, nil if none found.
     */
    func getAssociatedRecipeNames() -> [String]? {
        if (cdFoodItem?.ingredients == nil) || (cdFoodItem!.ingredients!.count == 0) {
            return nil
        } else {
            var associatedRecipeNames = [String]()
            for case let ingredient as Ingredient in cdFoodItem!.ingredients! {
                associatedRecipeNames.append(ingredient.composedFoodItem.name)
            }
            return associatedRecipeNames
        }
    }
    
    /// Checks if an associated FoodItem exists.
    /// - Returns: True if an associated FoodItem exists.
    func hasAssociatedFoodItem() -> Bool {
        return cdFoodItem != nil
    }
    
    /// Checks if an associated recipe exists.
    /// - Returns: True if an associated recipe exists.
    func hasAssociatedRecipe() -> Bool {
        return cdFoodItem?.composedFoodItem != nil
    }
    
    /// Checks if a Core Data FoodItem or ComposedFoodItem with the name of this FoodItemViewModel exists.
    /// - Returns: True if a Core Data FoodItem or ComposedFoodItem with the same name exists, false otherwise.
    func nameExists() -> Bool {
        ComposedFoodItem.getComposedFoodItemByName(name: self.name) != nil || FoodItem.getFoodItemsByName(name: self.name) != nil
    }
    
    /**
     Changes the category.
     
     - Parameters:
        - newCategory: the category to be set
     */
    func changeCategory(to newCategory: FoodItemCategory) {
        if category != newCategory {
            category = newCategory
            FoodItem.setCategory(cdFoodItem, to: newCategory.rawValue)
        }
    }
    
    /// Saves the FoodItemViewModel to a Core Data FoodItem
    func save() {
        // Check for an existing FoodItem with same ID
        if let existingFoodItem = FoodItem.getFoodItemByID(id: self.id) {
            if FoodItemViewModel.hasSameNutritionalValues(lhs: existingFoodItem, rhs: self) {
                // In case of an existing FoodItem with identical nutritional values, no new FoodItem needs to be created
                return
            } else {
                // Otherwise we need to create a new UUID before saving the VM to Core Data
                self.id = UUID()
            }
        }
        
        // Create the new FoodItem
        _ = FoodItem.create(from: self)
    }
    
    /// Updates the related Core Data FoodItem with the values of this FoodItemViewModel.
    /// - Parameter typicalAmountsToBeDeleted: The typical amounts which need to be deleted during update.
    func update(_ typicalAmountsToBeDeleted: [TypicalAmountViewModel]) {
        guard let cdFoodItem else { return }
        FoodItem.update(cdFoodItem, with: self, typicalAmountsToBeDeleted)
    }
    
    /**
     Duplicates a FoodItem.
     */
    func duplicate() {
        guard let cdFoodItem else { return }
        
        // Check if a recipe is associated, if yes duplicate recipe
        if cdFoodItem.composedFoodItem != nil {
            _ = ComposedFoodItem.duplicate(cdFoodItem.composedFoodItem!)
        } else {
            // Create the duplicate in Core Data
            _ = FoodItem.duplicate(cdFoodItem)}
    }
    
    /// Deletes the Core Data FoodItem if available.
    /// - Parameter includeAssociatedRecipe: If true, the Core Data ComposedFoodItem associated to the FoodItem is also deleted, if available.
    func delete(includeAssociatedRecipe: Bool) {
        guard let cdFoodItem else { return }
        
        if includeAssociatedRecipe {
            if let associatedRecipe = cdFoodItem.composedFoodItem {
                ComposedFoodItem.delete(associatedRecipe)
                CoreDataStack.shared.save()
            }
        }
        
        FoodItem.delete(cdFoodItem)
        CoreDataStack.shared.save()
    }
    
    /// Resets the values of the FoodItemVM to those of the related Core Data FoodItem (if available).
    func reset() {
        if let cdFoodItem {
            self.name = cdFoodItem.name
            self.favorite = cdFoodItem.favorite
            self.category = FoodItemCategory(rawValue: cdFoodItem.category) ?? .product
            self.caloriesPer100gAsString = String(cdFoodItem.caloriesPer100g)
            self.carbsPer100gAsString = String(cdFoodItem.carbsPer100g)
            self.sugarsPer100gAsString = String(cdFoodItem.sugarsPer100g)
            self.sourceID = cdFoodItem.sourceID
            self.sourceDB = (cdFoodItem.sourceDB != nil) ? FoodDatabaseType(rawValue: cdFoodItem.sourceDB!) : nil
            
            self.typicalAmounts.removeAll()
            if let cdTypicalAmounts = cdFoodItem.typicalAmounts {
                for case let cdTypicalAmount as TypicalAmount in cdTypicalAmounts {
                    self.typicalAmounts.append(TypicalAmountViewModel(from: cdTypicalAmount))
                }
            }
        }
    }
    
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
    
    static func == (lhs: FoodItemViewModel, rhs: FoodItemViewModel) -> Bool {
        lhs.id == rhs.id
    }

    /// Compares the nutritional values (calories per 100g, carbs per 100g, sugars per 100g) of a FoodItem and a FoodItemViewModel.
    /// - Parameters:
    ///   - lhs: The FoodItem to be compared.
    ///   - rhs: The FoodItemViewModel to be compared.
    /// - Returns: True if all nutritional values are identical.
    static func hasSameNutritionalValues(lhs: FoodItem, rhs: FoodItemViewModel) -> Bool {
        lhs.caloriesPer100g == rhs.caloriesPer100g &&
        lhs.carbsPer100g == rhs.carbsPer100g &&
        lhs.sugarsPer100g == rhs.sugarsPer100g
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func sampleData() -> FoodItemViewModel {
        FoodItemViewModel(
            id: UUID(),
            name: "Sample Food Item",
            category: .product,
            favorite: false,
            caloriesPer100g: 100.0,
            carbsPer100g: 10.0,
            sugarsPer100g: 5.0,
            amount: 100,
            sourceID: nil,
            sourceDB: nil
        )
    }
}
