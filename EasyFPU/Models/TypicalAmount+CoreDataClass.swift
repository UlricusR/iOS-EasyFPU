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
    static func fetchAll(viewContext: NSManagedObjectContext = AppDelegate.viewContext) -> [TypicalAmount] {
        let request: NSFetchRequest<TypicalAmount> = TypicalAmount.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "amount", ascending: true)]
        
        guard let typicalAmounts = try? AppDelegate.viewContext.fetch(request) else {
            return []
        }
        return typicalAmounts
    }
    
    static func deleteAll(viewContext: NSManagedObjectContext = AppDelegate.viewContext) {
        TypicalAmount.fetchAll(viewContext: viewContext).forEach({
            viewContext.delete($0)
        })
        
        try? viewContext.save()
    }
    
    static func create(from typicalAmountVM: TypicalAmountViewModel) -> TypicalAmount {
        let moc = AppDelegate.viewContext
        
        // Create TypicalAmount
        let cdTypicalAmount = TypicalAmount(context: moc)
        
        // Fill data
        cdTypicalAmount.amount = Int64(typicalAmountVM.amount)
        cdTypicalAmount.comment = typicalAmountVM.comment
        
        // Save new Ingredient
        try? moc.save()
        
        return cdTypicalAmount
    }
}
