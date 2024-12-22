//
//  AbsorptionBlock+CoreDataClass.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 02.08.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//
//

import Foundation
import CoreData

@objc(AbsorptionBlock)
public class AbsorptionBlock: NSManagedObject {
    static func fetchAll(viewContext: NSManagedObjectContext = CoreDataStack.viewContext) -> [AbsorptionBlock] {
        let request: NSFetchRequest<AbsorptionBlock> = AbsorptionBlock.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "maxFpu", ascending: true)]
        
        guard let absorptionBlocks = try? CoreDataStack.viewContext.fetch(request) else {
            return []
        }
        return absorptionBlocks
    }
    
    static func deleteAll(viewContext: NSManagedObjectContext = CoreDataStack.viewContext) {
        AbsorptionBlock.fetchAll(viewContext: viewContext).forEach({
            viewContext.delete($0)
        })
        
        try? viewContext.save()
    }
    
    static func create(absorptionTime: Int, maxFpu: Int) -> AbsorptionBlock {
        let cdAbsorptionBlock = AbsorptionBlock(context: CoreDataStack.viewContext)
        cdAbsorptionBlock.id = UUID()
        cdAbsorptionBlock.absorptionTime = Int64(absorptionTime)
        cdAbsorptionBlock.maxFpu = Int64(maxFpu)
        
        CoreDataStack.shared.save()
        return cdAbsorptionBlock
    }
    
    static func create(from absorptionBlockFromJson: AbsorptionBlockFromJson, id: UUID) -> AbsorptionBlock {
        let cdAbsorptionBlock = AbsorptionBlock(context: CoreDataStack.viewContext)
        cdAbsorptionBlock.id = id
        cdAbsorptionBlock.absorptionTime = Int64(absorptionBlockFromJson.absorptionTime)
        cdAbsorptionBlock.maxFpu = Int64(absorptionBlockFromJson.maxFpu)
        
        CoreDataStack.shared.save()
        return cdAbsorptionBlock
    }
    
    static func create(from absorptionBlockVM: AbsorptionBlockViewModel) -> AbsorptionBlock {
        let cdAbsorptionBlock = AbsorptionBlock(context: CoreDataStack.viewContext)
        cdAbsorptionBlock.id = UUID()
        cdAbsorptionBlock.absorptionTime = Int64(absorptionBlockVM.absorptionTime)
        cdAbsorptionBlock.maxFpu = Int64(absorptionBlockVM.maxFpu)
        
        CoreDataStack.shared.save()
        return cdAbsorptionBlock
    }
    
    static func updateAbsorptionTime(cdAbsorptionBlock: AbsorptionBlock, with absorptionTime: Int) {
        cdAbsorptionBlock.absorptionTime = Int64(absorptionTime)
        CoreDataStack.shared.save()
    }
    
    static func updateMaxFpu(cdAbsorptionBlock: AbsorptionBlock, with maxFpu: Int) {
        cdAbsorptionBlock.maxFpu = Int64(maxFpu)
        CoreDataStack.shared.save()
    }
    
    static func remove(_ cdAbsorptionBlock: AbsorptionBlock) {
        CoreDataStack.viewContext.delete(cdAbsorptionBlock)
        CoreDataStack.shared.save()
    }
    
    static func getAbsorptionBlockByID(id: UUID) -> AbsorptionBlock? {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        let request: NSFetchRequest<AbsorptionBlock> = AbsorptionBlock.fetchRequest()
        request.predicate = predicate
        do {
            let result = try CoreDataStack.viewContext.fetch(request)
            if !result.isEmpty {
                return result[0]
            }
        } catch {
            debugPrint("Error fetching absorption block: \(error)")
        }
        return nil
    }
}
