//
//  EasyFPUApp.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 05/01/2025.
//  Copyright © 2025 Ulrich Rüth. All rights reserved.
//

import SwiftUI

@main
struct EasyFPUApp: App {
    let context = CoreDataStack.shared.persistentContainer.viewContext
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, context)
        }
    }
}
