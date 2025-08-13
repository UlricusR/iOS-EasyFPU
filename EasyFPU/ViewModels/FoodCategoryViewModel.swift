//
//  FoodCategoryViewModel.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 13/08/2025.
//  Copyright © 2025 Ulrich Rüth. All rights reserved.
//

import Foundation

class FoodCategoryViewModel: ObservableObject, Codable, Hashable, Identifiable {
    var id: UUID
    @Published var name: String
    @Published var category: FoodItemCategory
    var cdFoodCategory: FoodCategory?
    
    enum CodingKeys: String, CodingKey {
        case foodCategory
        case id, name, category
    }
    
    /// Initializes the FoodCategoryViewModel.
    /// - Parameters:
    ///   - id: The ID of the food item.
    ///   - name: The name of the food item.
    ///   - category: The category of the food item.
    init(id: UUID, name: String, category: FoodItemCategory) {
        self.id = id
        self.name = name
        self.category = category
    }
    
    /// Initializes the FoodCategoryViewModel from a Core Data FoodCategory.
    /// - Parameter cdFoodCategory: The source Core Data FoodCategory.
    init(from cdFoodCategory: FoodCategory) {
        // Use ID from Core Date FoodItem
        self.id = cdFoodCategory.id
        self.name = cdFoodCategory.name
        self.category = FoodItemCategory.init(rawValue: cdFoodCategory.category) ?? FoodItemCategory.product // Default is product
        self.cdFoodCategory = cdFoodCategory
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let foodCategory = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .foodCategory)
        let uuidString = try foodCategory.decode(String.self, forKey: .id)
        id = UUID(uuidString: uuidString) ?? UUID()
        name = try foodCategory.decode(String.self, forKey: .name)
        category = try FoodItemCategory.init(rawValue: foodCategory.decode(String.self, forKey: .category)) ?? .product
    }
    
    /// Checks if an associated FoodCategory exists.
    /// - Returns: True if an associated FoodCategory exists.
    func hasAssociatedFoodCategory() -> Bool {
        return cdFoodCategory != nil
    }
    
    /// Checks if a Core Data FoodCategory with the name of this FoodCategoryViewModel exists.
    /// - Returns: True if a Core Data FoodCategory with the same name exists, false otherwise.
    func nameExists() -> Bool {
        FoodCategory.getFoodCategoriesByName(name: self.name) != nil
    }
    
    /// Saves the FoodCategoryViewModel to a Core Data FoodCategory.
    func save() {
        // Create the new FoodCategory
        _ = FoodCategory.create(from: self)
    }
    
    /// Updates this FoodCategoryViewModel and the related Core Data FoodCategory with the values of the passed FoodCategoryViewModel.
    /// - Parameter foodCategoryVM: The source FoodCategoryViewModel.
    /// - Parameter errorMessage: The error message in case of a fatal error.
    /// - Returns: False in case of a fatal error, true otherwise.
    func update(from clone: FoodItemViewModel, errorMessage: inout String) -> Bool {
        guard let cdFoodCategory else {
            errorMessage = "Fatal error: No Core Data FoodCategory found!"
            return false
        }
        
        // Update values
        self.name = clone.name
        self.category = clone.category
        
        // Update Core Data FoodCategory
        FoodCategory.update(
            cdFoodCategory,
            with: self
        )
        
        return true
    }
    
    /// Deletes the Core Data FoodCategory if available.
    func delete() {
        guard let cdFoodCategory else { return }
        
        FoodCategory.delete(cdFoodCategory)
        CoreDataStack.shared.save()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var foodCategory = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .foodCategory)
        try foodCategory.encode(id.uuidString, forKey: .id)
        try foodCategory.encode(name, forKey: .name)
        try foodCategory.encode(category.rawValue, forKey: .category)
    }
    
    static func == (lhs: FoodCategoryViewModel, rhs: FoodCategoryViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
