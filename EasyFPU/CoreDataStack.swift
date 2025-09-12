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
    static let tempConfiguration = "Temp"
    static let cloudConfiguration = "Cloud"
    static let shared = CoreDataStack()
    
    let storeType: String
    
    // Create a persistent container as a lazy variable to defer instantiation until its first use.
    lazy var persistentContainer: NSPersistentContainer = {
        var container: NSPersistentContainer
        var descriptions: [NSPersistentStoreDescription] = []
        
        // Create an in-memory store to use for temporary storage of data
        let tempDescription = NSPersistentStoreDescription()
        tempDescription.type = NSInMemoryStoreType
        tempDescription.configuration = CoreDataStack.tempConfiguration
        descriptions.append(tempDescription)
        
        if storeType == NSInMemoryStoreType { // Used for testing only
            let description = NSPersistentStoreDescription()
            description.type = storeType
            description.configuration = CoreDataStack.cloudConfiguration // Use the Cloud configuration, so that we have the same model as the SQLite store
            descriptions.append(description)
            
            // Create an in-memory store
            container = NSPersistentContainer(name: CoreDataStack.dataStoreName)
        } else { // Used for normal app usage
            // Define the SQLite store location
            let storeURL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("\(CoreDataStack.dataStoreName).sqlite")
            let description = NSPersistentStoreDescription(url: storeURL)
            description.configuration = CoreDataStack.cloudConfiguration
            description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.info.rueth.EasyFPU")
            descriptions.append(description)
            
            // Create an SQLite store
            container = NSPersistentCloudKitContainer(name: CoreDataStack.dataStoreName)
        }
        
        // Add the store descriptions to the container. The order of the descriptions
        // in the array is important. The first description is the one used by
        // defaultFetchRequestTemplate, and the first SQLite description is the
        // one used by viewContext.
        // The order of the descriptions in the array is also important for
        // determining which stores are used for which configurations.
        // The first description is used for the default configuration, the second
        // for the second configuration, and so on.
        // In our case, the first description is the in-memory store for the Temp configuration,
        // the second description is the SQLite store for the Cloud configuration.
        container.persistentStoreDescriptions = descriptions
        
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
