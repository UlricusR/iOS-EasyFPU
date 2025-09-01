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
    
    //
    // MARK: - Static methods for entity creation/deletion/fetching
    //
    
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
    
    /// Creates a new Core Data AbsorptionBlock after validating the input strings. If validation fails, sets an appropriate alert message.
    /// - Parameters:
    ///   - maxFpuAsString: The maximum FPU as String
    ///   - absorptionTimeAsString: The absorption time as String
    ///   - activeAlert: An inout parameter for setting an alert message in case of validation failure.
    /// - Returns: The created AbsorptionBlock object, or nil if validation fails.
    static func create(maxFpuAsString: String, absorptionTimeAsString: String, activeAlert: inout SimpleAlertType?) -> AbsorptionBlock? {
        var maxFPUCandidate: Int = 0
        var absorptionTimeCandidate: Int = 0
        
        // Check for valid max fpu
        let resultMaxFpu = DataHelper.checkForPositiveInt(valueAsString: maxFpuAsString, allowZero: false)
        switch resultMaxFpu {
        case .success(let maxFpu):
            maxFPUCandidate = maxFpu
        case .failure(let err):
            activeAlert = .error(message: err.evaluate())
            return nil
        }
        
        // Check for valid absorption time
        let resultAbsorptionTime = DataHelper.checkForPositiveInt(valueAsString: absorptionTimeAsString, allowZero: false)
        switch resultAbsorptionTime {
        case .success(let absorptionTime):
            absorptionTimeCandidate = absorptionTime
        case .failure(let err):
            activeAlert = .error(message: err.evaluate())
            return nil
        }
        
        // Create Core Data absorption block
        return AbsorptionBlock.create(absorptionTime: absorptionTimeCandidate, maxFpu: maxFPUCandidate, saveContext: true)
    }
    
    /// Creates a new Core Data AbsorptionBlock with the given values. Does not check for duplicates.
    /// - Parameters:
    ///   - absorptionTime: The absorption time in minutes.
    ///   - maxFpu: The maximum FPU value for this block.
    ///   - saveContext: A Boolean indicating whether to save the Core Data context after creating.
    /// - Returns: The created AbsorptionBlock object.
    static func create(absorptionTime: Int, maxFpu: Int, saveContext: Bool) -> AbsorptionBlock {
        let cdAbsorptionBlock = AbsorptionBlock(context: CoreDataStack.viewContext)
        cdAbsorptionBlock.id = UUID()
        cdAbsorptionBlock.absorptionTime = Int64(absorptionTime)
        cdAbsorptionBlock.maxFpu = Int64(maxFpu)
        
        if saveContext {
            CoreDataStack.shared.save()
        }
        return cdAbsorptionBlock
    }
    
    /// Creates a new Core Data AbsorptionBlock from the given AbsorptionBlockFromJson and id. Saves the context.
    /// - Parameters:
    ///   - absorptionBlockFromJson: The AbsorptionBlockFromJson to create the AbsorptionBlock from.
    ///   - id: The unique identifier for the AbsorptionBlock.
    ///   - saveContext: A Boolean indicating whether to save the Core Data context after creating.
    /// - Returns: The created AbsorptionBlock object.
    static func create(from absorptionBlockFromJson: AbsorptionBlockFromJson, id: UUID, saveContext: Bool) -> AbsorptionBlock {
        let cdAbsorptionBlock = AbsorptionBlock(context: CoreDataStack.viewContext)
        cdAbsorptionBlock.id = id
        cdAbsorptionBlock.absorptionTime = Int64(absorptionBlockFromJson.absorptionTime)
        cdAbsorptionBlock.maxFpu = Int64(absorptionBlockFromJson.maxFpu)
        
        if saveContext {
            CoreDataStack.shared.save()
        }
        return cdAbsorptionBlock
    }
    
    /// Removes the given Core Data AbsorptionBlock from the context and optionally saves the context.
    /// - Parameters:
    ///   - cdAbsorptionBlock: The AbsorptionBlock to remove.
    ///   - saveContext: A Boolean indicating whether to save the Core Data context after removal.
    static func remove(_ cdAbsorptionBlock: AbsorptionBlock, saveContext: Bool) {
        CoreDataStack.viewContext.delete(cdAbsorptionBlock)
        if saveContext {
            CoreDataStack.shared.save()
        }
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
