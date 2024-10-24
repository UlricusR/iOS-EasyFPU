//
//  CoreDataStack.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 15/10/2024.
//  Copyright © 2024 Ulrich Rüth. All rights reserved.
//

import CoreData

final class CoreDataStack {
    static let dataStoreName = "EasyFPU"
    static let shared = CoreDataStack()
    
    let storeType: String
    
    // Create a persistent container as a lazy variable to defer instantiation until its first use.
    lazy var persistentContainer: NSPersistentContainer = {
        var container: NSPersistentContainer
        
        if storeType == NSInMemoryStoreType {
            let description = NSPersistentStoreDescription()
            description.type = storeType
            
            // Create an in-memory store
            container = NSPersistentContainer(name: CoreDataStack.dataStoreName)
            container.persistentStoreDescriptions = [description]
        } else {
            // Create an SQLite store
            container = NSPersistentCloudKitContainer(name: CoreDataStack.dataStoreName)
        }
        
        // Load any persistent stores, which creates a store if none exists.
        container.loadPersistentStores { _, error in
            if let error {
                // Handle the error appropriately. However, it's useful to use
                // `fatalError(_:file:line:)` during development.
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Failed to load persistent stores: \(error.localizedDescription)")
            }
        }
        return container
    }()
    
    static var persistentContainer: NSPersistentContainer {
        return CoreDataStack.shared.persistentContainer
    }
    
    static var viewContext: NSManagedObjectContext {
        let viewContext = persistentContainer.viewContext
        viewContext.automaticallyMergesChangesFromParent = true
        return viewContext
    }
        
    private init() {
        if ProcessInfo.processInfo.environment["persistent_store_type"] == "in_memory" {
            self.storeType = NSInMemoryStoreType
        } else {
            self.storeType = NSSQLiteStoreType
        }
    }
}

extension CoreDataStack {
    
    // MARK: - Core Data Saving support
    
    func save() {
        // Verify that the context has uncommitted changes.
        guard persistentContainer.viewContext.hasChanges else { return }
        
        do {
            // Attempt to save changes.
            try persistentContainer.viewContext.save()
        } catch {
            // Handle the error appropriately.
            print("Failed to save the context:", error.localizedDescription)
        }
    }
}
