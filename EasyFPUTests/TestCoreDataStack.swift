//
//  TestCoreDataStack.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 14/10/2024.
//  Copyright © 2024 Ulrich Rüth. All rights reserved.
//

import CoreData
@testable import EasyFPU

class TestCoreDataStack: NSObject {
    lazy var persistentContainer: NSPersistentContainer = {
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        let container = NSPersistentContainer(name: AppDelegate.DataStoreName)
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
}
