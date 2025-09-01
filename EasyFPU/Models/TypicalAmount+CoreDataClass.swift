//
//  TypicalAmount+CoreDataClass.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 15.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//
//

import Foundation
import CoreData


public class TypicalAmount: NSManagedObject {
    
    //
    // MARK: - Static methods for entity creation/deletion/fetching
    //
    
    static func fetchAll(viewContext: NSManagedObjectContext = CoreDataStack.viewContext) -> [TypicalAmount] {
        let request: NSFetchRequest<TypicalAmount> = TypicalAmount.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "amount", ascending: true)]
        
        guard let typicalAmounts = try? CoreDataStack.viewContext.fetch(request) else {
            return []
        }
        return typicalAmounts
    }
    
    static func deleteAll(viewContext: NSManagedObjectContext = CoreDataStack.viewContext) {
        TypicalAmount.fetchAll(viewContext: viewContext).forEach({
            viewContext.delete($0)
        })
        
        try? viewContext.save()
    }
    
    /// Creates a Core Data TypicalAmount from the passed TypicalAmountViewModel and creates a relation between the two.
    /// Does not relate it to a Core Data FoodItem. Saves the context.
    /// - Parameter typicalAmountVM: The source TypicalAmountViewModel.
    /// - Parameter saveContext: A Boolean indicating whether to save the Core Data context after creating.
    /// - Returns: The created Core Data TypicalAmount.
    static func create(from typicalAmountVM: TypicalAmountViewModel, saveContext: Bool) -> TypicalAmount {
        // Create TypicalAmount
        let cdTypicalAmount = TypicalAmount(context: CoreDataStack.viewContext)
        
        // Fill data
        cdTypicalAmount.amount = Int64(typicalAmountVM.amount)
        cdTypicalAmount.comment = typicalAmountVM.comment
        cdTypicalAmount.id = typicalAmountVM.id
        typicalAmountVM.cdTypicalAmount = cdTypicalAmount
        
        // Save new TypicalAmount
        if saveContext {
            CoreDataStack.shared.save()
        }
        
        return cdTypicalAmount
    }
    
    /// Creates a Core Data TypicalAmount from the passed parameters. Does not save the context.
    /// - Parameters:
    ///   - amount: The amount in grams.
    ///   - comment: The related comment.
    /// - Returns: The created Core Data TypicalAmount.
    static func create(amount: Int64, comment: String) -> TypicalAmount {
        // Create TypicalAmount
        let cdTypicalAmount = TypicalAmount(context: CoreDataStack.viewContext)
        
        // Fill data
        cdTypicalAmount.id = UUID()
        cdTypicalAmount.amount = amount
        cdTypicalAmount.comment = comment
        
        return cdTypicalAmount
    }
    
    /// Deletes the given TypicalAmount from Core Data. Does not save the context.
    /// - Parameter typicalAmount: The TypicalAmount to be deleted.
    static func delete(_ typicalAmount: TypicalAmount) {
        // Delete the typical amount
        CoreDataStack.viewContext.delete(typicalAmount)
    }
    
    /**
     Returns the Core Data TypicalAmount with the given id.
     
     - Parameter id: The Core Data entry id.
     
     - Returns: The related Core Data TypicalAmount, nil if not found.
     */
    static func getTypicalAmountByID(id: UUID) -> TypicalAmount? {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        let request: NSFetchRequest<TypicalAmount> = TypicalAmount.fetchRequest()
        request.predicate = predicate
        do {
            let result = try CoreDataStack.viewContext.fetch(request)
            if !result.isEmpty {
                return result[0]
            }
        } catch {
            debugPrint("Error fetching typical amount: \(error)")
        }
        return nil
    }
}
