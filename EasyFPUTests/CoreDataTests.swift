//
//  CoreDataTests.swift
//  EasyFPUTests
//
//  Created by Ulrich Rüth on 14/10/2024.
//  Copyright © 2024 Ulrich Rüth. All rights reserved.
//

import Testing
import CoreData
@testable import EasyFPU

struct CoreDataTests {
    var coreDataStack: NSObject!
    
    init() {
        coreDataStack = TestCoreDataStack()
    }

    @Test func createFoodItem() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

}
