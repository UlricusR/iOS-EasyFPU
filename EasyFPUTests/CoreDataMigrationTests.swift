//
//  EasyFPUTests.swift
//  EasyFPUTests
//
//  Created by Ulrich Rüth on 14/10/2024.
//  Copyright © 2024 Ulrich Rüth. All rights reserved.
//

import Testing
@testable import EasyFPU
import CoreData

class CoreDataMigrationTests {
    private let momdURL = DataModel.bundle.url(forResource: AppDelegate.DataStoreName, withExtension: "momd")!
    private let storeType = NSSQLiteStoreType
    
    private var sourceContainer: NSPersistentContainer?
    private var targetContainer: NSPersistentContainer?
    private var sourceMoc: NSManagedObjectContext?
    private var targetMoc: NSManagedObjectContext?
    private var sourceStoreUrl: URL?
    private var targetStoreUrl: URL?
    private var sourceMom: NSManagedObjectModel?
    private var targetMom: NSManagedObjectModel?
    
    private var foodItem1 = Dictionary<String, String>()
    private var foodItem2 = Dictionary<String, String>()
    private var foodItem3 = Dictionary<String, String>()
    private var foodItem4 = Dictionary<String, String>()
    private var ingredient1 = Dictionary<String, String>()
    private var ingredient2 = Dictionary<String, String>()
    private var ingredient3 = Dictionary<String, String>()
    private var ingredient4 = Dictionary<String, String>()
    private var composedFoodItem1 = Dictionary<String, String>()
    private var composedFoodItem2 = Dictionary<String, String>()
    
    init() throws {
        // Prepare databases
        sourceMoc = try prepareDatabase(versionName: AppDelegate.DataStoreName, persistentStoreUrl: &sourceStoreUrl, managedObjectModel: &sourceMom)
        targetMoc = try prepareDatabase(versionName: AppDelegate.DataStoreName + " 2", persistentStoreUrl: &targetStoreUrl, managedObjectModel: &targetMom)
        
        // Output the storeURLs
        print("Source DB: " + sourceStoreUrl!.absoluteString)
        print("Target DB: " + targetStoreUrl!.absoluteString)
        
        // Define data
        foodItem1 = [
            "name": "Alpenzwerg",
            "caloriesPer100g": "72",
            "carbsPer100g": "10.4",
            "sugarsPer100g": "9.4",
            "category": "Product",
            "favorite": "0",
            "id": "220458AD-3216-45A2-9FC3-32285A2A36D0"
        ]
        
        foodItem2 = [
            "name": "Backpulver",
            "caloriesPer100g": "90",
            "carbsPer100g": "22",
            "sugarsPer100g": "0",
            "category": "Ingredient",
            "favorite": "1",
            "id": "E446505E-7556-49A9-9397-91C422B9D5E2"
        ]
        
        foodItem3 = [
            "name": "Eier (GutBio)",
            "caloriesPer100g": "152.4",
            "carbsPer100g": "0.6",
            "sugarsPer100g": "0.5",
            "category": "Product", // should be Ingredient
            "favorite": "0",
            "id": "371E5B5E-95E4-43B4-9927-8173DD01721B"
        ]
        
        foodItem4 = [
            "name": "Marmorkuchen mit Schokoglasur",
            "caloriesPer100g": "384.546",
            "carbsPer100g": "42.25",
            "sugarsPer100g": "23.769",
            "category": "Product",
            "favorite": "1",
            "id": "A22711E7-3D65-404C-BA40-480916687561"
        ]
        
        ingredient1 = [ // For composedFoodItem1, should create a new FoodItem, as unknown
            "amount": "123",
            "name": "Andere Kalorien", // unknown name
            "caloriesPer100g": "123.4", // unknows calories
            "carbsPer100g": "0.6",
            "sugarsPer100g": "0.5",
            "category": "Product", // should be Ingredient
            "favorite": "0",
            "id": "371E5B5E-95E4-43B4-9927-123456789012"
        ]
        
        ingredient2 = [ // For composedFoodItem1, identical to foodItem2, so should not be created
            "amount": "5",
            "name": "Backpulver",
            "caloriesPer100g": "90",
            "carbsPer100g": "22",
            "sugarsPer100g": "0",
            "category": "Ingredient",
            "favorite": "1",
            "id": "E446505E-7556-49A9-9397-91C422B9D5E2"
        ]
        
        ingredient3 = [ // For composedFoodItem1, identical to foodItem3, so should not be created
            "amount": "200",
            "name": "Eier (GutBio)",
            "caloriesPer100g": "152.4",
            "carbsPer100g": "0.6",
            "sugarsPer100g": "0.5",
            "category": "Product", // should be Ingredient
            "favorite": "0",
            "id": "371E5B5E-95E4-43B4-9927-987654321098"
        ]
        
        ingredient4 = [ // For composedFoodItem2, identical to foodItem3, so should not be created
            "amount": "400",
            "name": "Eier (GutBio)",
            "caloriesPer100g": "152.4",
            "carbsPer100g": "0.6",
            "sugarsPer100g": "0.5",
            "category": "Product", // should be Ingredient
            "favorite": "0",
            "id": "371E5B5E-95E4-43B4-9927-765432109876"
        ]
        
        composedFoodItem1 = [
            "amount": "1200",
            "name": "Marmorkuchen mit Schokoglasur", // Related: foodItem4
            "category": "Ingredient",
            "favorite": "0",
            "id": "B65CB8FC-DF15-457A-A866-01EBEE8653BB",
            "numberOfPortions": "12"
        ]
        
        composedFoodItem2 = [
            "amount": "1234",
            "name": "ComposedFoodItem w/o related FoodItem", // No related FoodItem
            "category": "Ingredient",
            "favorite": "0",
            "id": "B65CB8FC-DF15-457A-A866-876543210987",
            "numberOfPortions": "12"
        ]
    }
    
    deinit {
        // Remove references
        sourceMom = nil
        targetMom = nil
        sourceMoc = nil
        targetMoc = nil
        sourceContainer = nil
        targetContainer = nil
        
        // Delete the databases
        _ = try? FileManager.default.removeItem(at: sourceStoreUrl!)
        _ = try? FileManager.default.removeItem(at: targetStoreUrl!)
    }

    
    @Test("Migrating data model 1 to 2", .disabled("We currently use automated migration w/o a migration model."))
    func migrateModel1To2() async throws {
        // Add FoodItems, Ingredients and ComposedFoodItems
        let cdFoodItem1 = addFoodItem(moc: sourceMoc!, foodItem: foodItem1)
        let cdFoodItem2 = addFoodItem(moc: sourceMoc!, foodItem: foodItem2)
        let cdFoodItem3 = addFoodItem(moc: sourceMoc!, foodItem: foodItem3)
        let cdFoodItem4 = addFoodItem(moc: sourceMoc!, foodItem: foodItem4)
        let cdIngredient1 = addIngredient(moc: sourceMoc!, ingredient: ingredient1)
        let cdIngredient2 = addIngredient(moc: sourceMoc!, ingredient: ingredient2)
        let cdIngredient3 = addIngredient(moc: sourceMoc!, ingredient: ingredient3)
        let cdIngredient4 = addIngredient(moc: sourceMoc!, ingredient: ingredient4)
        let cdComposedFoodItem1 = addComposedFoodItem(moc: sourceMoc!, composedFoodItem: composedFoodItem1)
        let cdComposedFoodItem2 = addComposedFoodItem(moc: sourceMoc!, composedFoodItem: composedFoodItem2)
        
        // Create relationships between composedFoodItem1 and the three ingredients
        var cdIngredientsForCFI1 = Set<NSManagedObject>()
        cdIngredientsForCFI1.insert(cdIngredient1)
        cdIngredientsForCFI1.insert(cdIngredient2)
        cdIngredientsForCFI1.insert(cdIngredient3)
        cdComposedFoodItem1.setValue(cdIngredientsForCFI1, forKey: "ingredients")
        
        // Create relationships between composedFoodItem2 and the three ingredients
        var cdIngredientsForCFI2 = Set<NSManagedObject>()
        cdIngredientsForCFI2.insert(cdIngredient4)
        cdComposedFoodItem2.setValue(cdIngredientsForCFI2, forKey: "ingredients")

        // Try to save
        try sourceMoc!.save()
        
        // Migrate the store to version 2
        let mappingModel = NSMappingModel(from: nil, forSourceModel: sourceMom, destinationModel: targetMom)
        try #require(mappingModel != nil)
        let migrationManager = NSMigrationManager(sourceModel: sourceMom!, destinationModel: targetMom!)
        try! migrationManager.migrateStore(from: sourceStoreUrl!, type: NSPersistentStore.StoreType.sqlite, mapping: mappingModel!, to: targetStoreUrl!, type: NSPersistentStore.StoreType.sqlite)
        
        // Get the migrated entities
        let foodItemRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FoodItem")
        let newFoodItems = try! targetMoc!.fetch(foodItemRequest) as! [NSManagedObject]
        let ingredientRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Ingredient")
        let newIngredients = try! targetMoc!.fetch(ingredientRequest) as! [NSManagedObject]
        let composedFoodItemRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ComposedFoodItem")
        let newComposedFoodItems = try! targetMoc!.fetch(composedFoodItemRequest) as! [NSManagedObject]
        
        //
        // Tests
        //
        
        // We expect 4 FoodItems, foodItem1..4 and none from ingredient1
        #expect(newFoodItems.count == 4)
        
        // There shouldn't be any Ingredients or ComposedFoodItems
        #expect(newIngredients.isEmpty || newIngredients.count == 0)
        #expect(newComposedFoodItems.isEmpty || newComposedFoodItems.count == 0)
        
        // Check FoodItem content
        for newFoodItem in newFoodItems {
            // Check if newFoodItem has ID
            #expect(newFoodItem.value(forKey: "id") != nil)
            
            // Check if new values are identical to old values
            let oldFoodItems = try! sourceMoc!.fetch(foodItemRequest) as! [NSManagedObject]
            if let oldFoodItem = getFoodItemByName(for: newFoodItem, from: oldFoodItems) {
                #expect(newFoodItem.value(forKey: "name") as? String == oldFoodItem.value(forKey: "name") as? String)
                #expect(newFoodItem.value(forKey: "caloriesPer100g") as? Double == oldFoodItem.value(forKey: "caloriesPer100g") as? Double)
                #expect(newFoodItem.value(forKey: "carbsPer100g") as? Double == oldFoodItem.value(forKey: "carbsPer100g") as? Double)
                #expect(newFoodItem.value(forKey: "sugarsPer100g") as? Double == oldFoodItem.value(forKey: "sugarsPer100g") as? Double)
                #expect(newFoodItem.value(forKey: "category") as? String == oldFoodItem.value(forKey: "category") as? String)
                #expect(newFoodItem.value(forKey: "favorite") as? Bool == oldFoodItem.value(forKey: "favorite") as? Bool)
            }
        }
    }
    
    //
    // Data prep functions
    //
    
    private func addFoodItem(moc: NSManagedObjectContext, foodItem: Dictionary<String, String>) -> NSManagedObject {
        let cdFoodItem = NSEntityDescription.insertNewObject(forEntityName: "FoodItem", into: moc)
        cdFoodItem.setValue(foodItem["name"], forKey: "name")
        cdFoodItem.setValue(Double(foodItem["caloriesPer100g"]!), forKey: "caloriesPer100g")
        cdFoodItem.setValue(Double(foodItem["carbsPer100g"]!), forKey: "carbsPer100g")
        cdFoodItem.setValue(Double(foodItem["sugarsPer100g"]!), forKey: "sugarsPer100g")
        cdFoodItem.setValue(foodItem["category"], forKey: "category")
        cdFoodItem.setValue(foodItem["favorite"] == "0" ? false : true, forKey: "favorite")
        cdFoodItem.setValue(UUID(uuidString: foodItem["id"]!), forKey: "id")
        return cdFoodItem
    }
    
    private func addIngredient(moc: NSManagedObjectContext, ingredient: Dictionary<String, String>) -> NSManagedObject {
        let cdIngredient = NSEntityDescription.insertNewObject(forEntityName: "Ingredient", into: moc)
        cdIngredient.setValue(Double(ingredient["amount"]!), forKey: "amount")
        cdIngredient.setValue(ingredient["name"], forKey: "name")
        cdIngredient.setValue(Double(ingredient["caloriesPer100g"]!), forKey: "caloriesPer100g")
        cdIngredient.setValue(Double(ingredient["carbsPer100g"]!), forKey: "carbsPer100g")
        cdIngredient.setValue(Double(ingredient["sugarsPer100g"]!), forKey: "sugarsPer100g")
        cdIngredient.setValue(ingredient["category"], forKey: "category")
        cdIngredient.setValue(ingredient["favorite"] == "0" ? false : true, forKey: "favorite")
        cdIngredient.setValue(UUID(uuidString: ingredient["id"]!), forKey: "id")
        return cdIngredient
    }
    
    private func addComposedFoodItem(moc: NSManagedObjectContext, composedFoodItem: Dictionary<String, String>) -> NSManagedObject {
        let cdComposedFoodItem = NSEntityDescription.insertNewObject(forEntityName: "ComposedFoodItem", into: moc)
        cdComposedFoodItem.setValue(Double(composedFoodItem["amount"]!), forKey: "amount")
        cdComposedFoodItem.setValue(composedFoodItem["name"], forKey: "name")
        cdComposedFoodItem.setValue(composedFoodItem["category"], forKey: "category")
        cdComposedFoodItem.setValue(composedFoodItem["favorite"] == "0" ? false : true, forKey: "favorite")
        cdComposedFoodItem.setValue(UUID(uuidString: composedFoodItem["id"]!), forKey: "id")
        cdComposedFoodItem.setValue(Int16(composedFoodItem["numberOfPortions"]!), forKey: "numberOfPortions")
        return cdComposedFoodItem
    }

    /// Returns the first FoodItem with the given name from a set of FoodItems
    private func getFoodItemByName(for foodItem: NSManagedObject, from foodItems: [NSManagedObject]) -> NSManagedObject? {
        guard let name = foodItem.value(forKey: "name") as? String else {
            return nil
        }
        for foundFoodItem in foodItems {
            guard let foodItemName = foundFoodItem.value(forKey: "name") as? String else {
                return nil
            }
            if name == foodItemName {
                return foodItem
            }
        }
        
        return nil
    }
    
    //
    // Functions to create Core Data stack
    //
    
    private func prepareDatabase(versionName: String, persistentStoreUrl: inout URL?, managedObjectModel: inout NSManagedObjectModel?) throws -> NSManagedObjectContext {
        // Read and load the old model
        let mom = createManagedObjectModel(versionName: versionName)
        try #require(mom != nil)
        managedObjectModel = mom!
        
        // Create persistent container
        let container = try startPersistentContainer(model: managedObjectModel!, storeUrl: &persistentStoreUrl)
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel!)
        let _ = try coordinator.addPersistentStore(type: NSPersistentStore.StoreType(rawValue: storeType), at: persistentStoreUrl!)
        
        // Create managed object context
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        
        return managedObjectContext
    }
    
    private func createManagedObjectModel(versionName: String) -> NSManagedObjectModel? {
        let url = momdURL.appendingPathComponent(versionName).appendingPathExtension("mom")
        return NSManagedObjectModel(contentsOf: url)
    }
    
    /// Create and load a store using the given model version. The store will be located in a
    /// temporary directory.
    ///
    /// - Parameter versionName: The name of the model (`.xcdatamodel`). For example, `"App V1"`.
    /// - Returns: An `NSPersistentContainer` that is loaded and ready for usage.
    private func startPersistentContainer(model: NSManagedObjectModel, storeUrl: inout URL?) throws -> NSPersistentContainer {
        storeUrl = makeTemporaryStoreURL()
        let container = makePersistentContainer(
            storeURL: storeUrl!,
            managedObjectModel: model
        )
        container.loadPersistentStores { _, error in
            #expect(error == nil)
        }

        return container
    }
    
    private func makeTemporaryStoreURL() -> URL {
        URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("sqlite")
    }
    
    private func makePersistentContainer(
        storeURL: URL,
        managedObjectModel: NSManagedObjectModel
    ) -> NSPersistentContainer {
        let description = NSPersistentStoreDescription(url: storeURL)
        // In order to have more control over when the migration happens, we're setting
        // `shouldMigrateStoreAutomatically` to `false` to stop `NSPersistentContainer`
        // from **automatically** migrating the store. Leaving this as `true` might result in false positives.
        description.shouldMigrateStoreAutomatically = false
        description.type = storeType

        let container = NSPersistentContainer(name: "App Container", managedObjectModel: managedObjectModel)
        container.persistentStoreDescriptions = [description]

        return container
    }
}
