//
//  DynamicList.swift
//  EasyFPU
// Related tutorial: https://youtu.be/O4043RVjCGU?si=xnmf9FtA9YUzb4IR
//
//  Created by Ulrich Rüth on 17/08/2025.
//  Copyright © 2025 Ulrich Rüth. All rights reserved.
//

import SwiftUI
import CoreData

struct DynamicList<T: NSManagedObject, Content: View>: View {
    @FetchRequest var fetchRequest: FetchedResults<T>
    let content: (T) -> Content
    let emptyStateMessage: String
    
    var body: some View {
        List(fetchRequest, id: \.self) { item in
            self.content(item)
        }
        
        // Empty state view
        if fetchRequest.isEmpty {
            Text(emptyStateMessage)
                .foregroundColor(.gray)
                .padding()
        }
        
    }
    
    init<U: CVarArg>(
        filterKey: String,
        filterValue: U,
        sortKey: String,
        sortAscending: Bool,
        emptyStateMessage: String = "No items found",
        @ViewBuilder content: @escaping (T) -> Content
    ) throws {
        // Configure the fetch request based on the parameters
        guard let entityName = T.entity().name else {
            throw NSError(domain: "DynamicListError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Entity name not found for \(T.self)"])
        }
        let request = NSFetchRequest<T>(entityName: entityName)
        request.predicate = NSPredicate(format: "%K == %@", filterKey, filterValue)
        request.sortDescriptors = [NSSortDescriptor(key: sortKey, ascending: sortAscending)]
        
        // Initialize the FetchRequest with the configured request
        _fetchRequest = FetchRequest<T>(fetchRequest: request)
        
        // Assign the content closure
        self.content = content
        
        // Assign the empty state closure
        self.emptyStateMessage = emptyStateMessage
    }
}
