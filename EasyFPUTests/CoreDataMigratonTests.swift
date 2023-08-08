//
//  CoreDataMigratonTests.swift
//  EasyFPUTests
//
//  Created by Ulrich Rüth on 07/08/2023.
//  Copyright © 2023 Ulrich Rüth. All rights reserved.
//

import XCTest
import CoreData
@testable import EasyFPU

final class CoreDataMigratonTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testMigrationModel1To2() throws {
        // Define data
        let foodItem1 = [
            "name": "Alpenzwerg",
            "caloriesPer100g": "72",
            "carbsPer100g": "10.4",
            "sugarsPer100g": "9.4",
            "category": "Product",
            "favorite": "0",
            "id": "220458AD-3216-45A2-9FC3-32285A2A36D0"
        ]
        
        let foodItem2 = [
            "name": "Backpulver",
            "caloriesPer100g": "90",
            "carbsPer100g": "22",
            "sugarsPer100g": "0",
            "category": "Ingredient",
            "favorite": "1",
            "id": "E446505E-7556-49A9-9397-91C422B9D5E2"
        ]
        
        let foodItem3 = [
            "name": "Eier (GutBio)",
            "caloriesPer100g": "152.4",
            "carbsPer100g": "0.6",
            "sugarsPer100g": "0.5",
            "category": "Product", // should be Ingredient
            "favorite": "0",
            "id": "371E5B5E-95E4-43B4-9927-8173DD01721B"
        ]
        
        let foodItem4 = [
            "name": "Marmorkuchen mit Schokoglasur",
            "caloriesPer100g": "384.546",
            "carbsPer100g": "42.25",
            "sugarsPer100g": "23.769",
            "category": "Product",
            "favorite": "1",
            "id": "A22711E7-3D65-404C-BA40-480916687561"
        ]
        
        let ingredient1 = [
            "amount": "123",
            "name": "Andere Kalorien", // unknown name
            "caloriesPer100g": "123.4", // unknows calories
            "carbsPer100g": "0.6",
            "sugarsPer100g": "0.5",
            "category": "Product", // should be Ingredient
            "favorite": "0",
            "id": "371E5B5E-95E4-43B4-9927-8173DD01721B"
        ]
        
        let ingredient2 = [ // identical to foodItem2
            "amount": "5",
            "name": "Backpulver",
            "caloriesPer100g": "90",
            "carbsPer100g": "22",
            "sugarsPer100g": "0",
            "category": "Ingredient",
            "favorite": "1",
            "id": "E446505E-7556-49A9-9397-91C422B9D5E2"
        ]
        
        let ingredient3 = [ // identical to foodItem3
            "amount": "200",
            "name": "Eier (GutBio)",
            "caloriesPer100g": "152.4",
            "carbsPer100g": "0.6",
            "sugarsPer100g": "0.5",
            "category": "Product", // should be Ingredient
            "favorite": "0",
            "id": "371E5B5E-95E4-43B4-9927-8173DD01721B"
        ]
        
        let composedFoodItem4 = [
            "amount": "1200",
            "name": "Marmorkuchen mit Schokoglasur",
            "category": "Ingredient",
            "favorite": "0",
            "id": "B65CB8FC-DF15-457A-A866-01EBEE8653BB",
            "numberOfPortions": "12"
        ]
        
        // Read and load the old model
        let oldModelURL = Bundle(for: AppDelegate.self).url(forResource: "EasyFPU.momd/EasyFPU", withExtension: "mom")!
        let oldManagedObjectModel = NSManagedObjectModel(contentsOf: oldModelURL)
        XCTAssertNotNil(oldManagedObjectModel)
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: oldManagedObjectModel!)
        try! coordinator.addPersistentStore(type: NSPersistentStore.StoreType(rawValue: NSSQLiteStoreType), at: oldModelURL)
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        
        // Add FoodItems, Ingredients and ComposedFoodItems
        addFoodItem(moc: managedObjectContext, foodItem: foodItem1)
        addFoodItem(moc: managedObjectContext, foodItem: foodItem2)
        addFoodItem(moc: managedObjectContext, foodItem: foodItem3)
        addFoodItem(moc: managedObjectContext, foodItem: foodItem4)
        addIngredient(moc: managedObjectContext, ingredient: ingredient1)
        addIngredient(moc: managedObjectContext, ingredient: ingredient2)
        addIngredient(moc: managedObjectContext, ingredient: ingredient3)
        addComposedFoodItem(moc: managedObjectContext, composedFoodItem: composedFoodItem4)
        
        // Try to save
        try! managedObjectContext.save()
        
        // Migrate the store to version 2
        let newModelURL = Bundle(for: AppDelegate.self).url(forResource: "EsayFPU.momd/EasyFPU 2", withExtension: "mom")!
        let newManagedObjectModel = NSManagedObjectModel(contentsOf: newModelURL)

        let mappingModel = NSMappingModel(from: nil, forSourceModel: oldManagedObjectModel, destinationModel: newManagedObjectModel)
        let migrationManager = NSMigrationManager(sourceModel: oldManagedObjectModel!, destinationModel: newManagedObjectModel!)
        try! migrationManager.migrateStore(from: oldModelURL, type: NSPersistentStore.StoreType.sqlite, mapping: mappingModel!, to: newModelURL, type: NSPersistentStore.StoreType.sqlite)
        let newCoordinbator = NSPersistentStoreCoordinator(managedObjectModel: newManagedObjectModel!)
        try! newCoordinbator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: newModelURL, options: nil)
        let newManagedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        newManagedObjectContext.persistentStoreCoordinator = newCoordinbator

        // Get the migrated entities
        let newFoodItemRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FoodItem")
        let newFoodItems = try! newManagedObjectContext.fetch(newFoodItemRequest) as! [NSManagedObject]
        let newIngredientRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Ingredient")
        let newIngredients = try! newManagedObjectContext.fetch(newIngredientRequest) as! [NSManagedObject]
        let newComposedFoodItemRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ComposedFoodItem")
        let newComposedFoodItems = try! newManagedObjectContext.fetch(newComposedFoodItemRequest) as! [NSManagedObject]
        
        // Test FoodItems
        XCTAssertEqual(newFoodItems.count, 4) // We expect 4 FoodItems
        XCTAssertEqual(newFoodItems.first?.value(forKey: "name") as? String, foodItem1["name"])
        XCTAssertEqual(newFoodItems.first?.value(forKey: "caloriesPer100g") as? Double, Double(foodItem1["caloriesPer100g"]!)!)
        XCTAssertEqual(newFoodItems.first?.value(forKey: "carbsPer100g") as? Double, Double(foodItem1["carbsPer100g"]!)!)
        XCTAssertEqual(newFoodItems.first?.value(forKey: "sugarsPer100g") as? Double, Double(foodItem1["sugarsPer100g"]!)!)
        XCTAssertEqual(newFoodItems.first?.value(forKey: "category") as? String, foodItem1["category"])
        XCTAssertEqual(newFoodItems.first?.value(forKey: "favorite") as? Bool, foodItem1["favorite"] == "0" ? false : true)
        XCTAssertEqual(newFoodItems.first?.value(forKey: "id") as? String, foodItem1["id"])
    }
    
    private func addFoodItem(moc: NSManagedObjectContext, foodItem: Dictionary<String, String>) {
        let cdFoodItem = NSEntityDescription.insertNewObject(forEntityName: "FoodItem", into: moc)
        cdFoodItem.setValue(foodItem["name"], forKey: "name")
        cdFoodItem.setValue(Double(foodItem["caloriesPer100g"]!), forKey: "caloriesPer100g")
        cdFoodItem.setValue(Double(foodItem["carbsPer100g"]!), forKey: "carbsPer100g")
        cdFoodItem.setValue(Double(foodItem["sugarsPer100g"]!), forKey: "sugarsPer100g")
        cdFoodItem.setValue(foodItem["category"], forKey: "category")
        cdFoodItem.setValue(foodItem["favorite"] == "0" ? false : true, forKey: "favorite")
        cdFoodItem.setValue(UUID(uuidString: foodItem["id"]!), forKey: "id")
    }
    
    private func addIngredient(moc: NSManagedObjectContext, ingredient: Dictionary<String, String>) {
        let cdIngredient = NSEntityDescription.insertNewObject(forEntityName: "Ingredient", into: moc)
        cdIngredient.setValue(Double(ingredient["amount"]!), forKey: "amount")
        cdIngredient.setValue(ingredient["name"], forKey: "name")
        cdIngredient.setValue(Double(ingredient["caloriesPer100g"]!), forKey: "caloriesPer100g")
        cdIngredient.setValue(Double(ingredient["carbsPer100g"]!), forKey: "carbsPer100g")
        cdIngredient.setValue(Double(ingredient["sugarsPer100g"]!), forKey: "sugarsPer100g")
        cdIngredient.setValue(ingredient["category"], forKey: "category")
        cdIngredient.setValue(ingredient["favorite"] == "0" ? false : true, forKey: "favorite")
        cdIngredient.setValue(UUID(uuidString: ingredient["id"]!), forKey: "id")
    }
    
    private func addComposedFoodItem(moc: NSManagedObjectContext, composedFoodItem: Dictionary<String, String>) {
        let cdComposedFoodItem = NSEntityDescription.insertNewObject(forEntityName: "Ingredient", into: moc)
        cdComposedFoodItem.setValue(Double(composedFoodItem["amount"]!), forKey: "amount")
        cdComposedFoodItem.setValue(composedFoodItem["name"], forKey: "name")
        cdComposedFoodItem.setValue(composedFoodItem["category"], forKey: "category")
        cdComposedFoodItem.setValue(composedFoodItem["favorite"] == "0" ? false : true, forKey: "favorite")
        cdComposedFoodItem.setValue(UUID(uuidString: composedFoodItem["id"]!), forKey: "id")
        cdComposedFoodItem.setValue(Int(composedFoodItem["numberOfPortions"]!), forKey: "numberOfPortions")
    }
}

