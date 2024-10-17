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
    /// Does not relate it to a Core Data FoodItem.
    /// - Parameter typicalAmountVM: The source TypicalAmountViewModel.
    /// - Returns: The created Core Data TypicalAmount.
    static func create(from typicalAmountVM: TypicalAmountViewModel) -> TypicalAmount {
        // Create TypicalAmount
        let cdTypicalAmount = TypicalAmount(context: CoreDataStack.viewContext)
        
        // Fill data
        cdTypicalAmount.amount = Int64(typicalAmountVM.amount)
        cdTypicalAmount.comment = typicalAmountVM.comment
        cdTypicalAmount.id = typicalAmountVM.id
        typicalAmountVM.cdTypicalAmount = cdTypicalAmount
        
        // Save new TypicalAmount
        CoreDataStack.shared.save()
        
        return cdTypicalAmount
    }
    
    static func update(with typicalAmountVM: TypicalAmountViewModel) -> TypicalAmount {
        var typicalAmount: TypicalAmount
        
        if typicalAmountVM.cdTypicalAmount != nil {
            typicalAmount = typicalAmountVM.cdTypicalAmount!
        } else {
            typicalAmount = TypicalAmount(context: CoreDataStack.viewContext)
            typicalAmount.id = UUID()
        }
        
        typicalAmount.amount = Int64(typicalAmountVM.amount)
        typicalAmount.comment = typicalAmountVM.comment
        typicalAmountVM.cdTypicalAmount = typicalAmount
        
        try? CoreDataStack.viewContext.save()
        return typicalAmount
    }
}
