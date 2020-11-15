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
    static func fetchAll(viewContext: NSManagedObjectContext = AppDelegate.viewContext) -> [AbsorptionBlock] {
        let request: NSFetchRequest<AbsorptionBlock> = AbsorptionBlock.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "maxFpu", ascending: true)]
        
        guard let absorptionBlocks = try? AppDelegate.viewContext.fetch(request) else {
            return []
        }
        return absorptionBlocks
    }
    
    static func deleteAll(viewContext: NSManagedObjectContext = AppDelegate.viewContext) {
        AbsorptionBlock.fetchAll(viewContext: viewContext).forEach({
            viewContext.delete($0)
        })
        
        try? viewContext.save()
    }
    
    static func create(from absorptionBlockFromJson: AbsorptionBlockFromJson) -> AbsorptionBlock {
        let moc = AppDelegate.viewContext
        let cdAbsorptionBlock = AbsorptionBlock(context: moc)
        cdAbsorptionBlock.id = UUID()
        cdAbsorptionBlock.absorptionTime = Int64(absorptionBlockFromJson.absorptionTime)
        cdAbsorptionBlock.maxFpu = Int64(absorptionBlockFromJson.maxFpu)
        
        try? moc.save()
        return cdAbsorptionBlock
    }
    
    static func create(from absorptionBlockFromJson: AbsorptionBlockViewModel) -> AbsorptionBlock {
        let moc = AppDelegate.viewContext
        let cdAbsorptionBlock = AbsorptionBlock(context: moc)
        cdAbsorptionBlock.id = UUID()
        cdAbsorptionBlock.absorptionTime = Int64(absorptionBlockFromJson.absorptionTime)
        cdAbsorptionBlock.maxFpu = Int64(absorptionBlockFromJson.maxFpu)
        
        try? moc.save()
        return cdAbsorptionBlock
    }
    
    static func remove(_ absorptionBlock: AbsorptionBlock, from absorptionScheme: AbsorptionScheme) {
        let moc = AppDelegate.viewContext
        absorptionScheme.removeFromAbsorptionBlocks(absorptionBlockToBeDeleted: absorptionBlock)
        moc.delete(absorptionBlock)
        try? moc.save()
    }
}
