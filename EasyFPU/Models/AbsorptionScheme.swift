//
//  AbsorptionScheme.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 11.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

class AbsorptionScheme: Equatable {
    var absorptionBlocks: [AbsorptionBlock]
    @Environment(\.managedObjectContext) var managedObjectContext
    
    init(absorptionBlocks: [AbsorptionBlock]) {
        self.absorptionBlocks = absorptionBlocks
    }
    
    init(absorptionBlocksFromJson: [AbsorptionBlockFromJson]) {
        self.absorptionBlocks = [AbsorptionBlock]()
        for absorptionBlock in absorptionBlocksFromJson {
            let newAbsorptionBlock = AbsorptionBlock(context: managedObjectContext)
            newAbsorptionBlock.maxFpu = Int64(absorptionBlock.maxFpu)
            newAbsorptionBlock.absorptionTime = Int64(absorptionBlock.absorptionTime)
            self.absorptionBlocks.append(newAbsorptionBlock)
        }
    }
    
    func addToAbsorptionBlocks(newAbsorptionBlock: AbsorptionBlock) {
        absorptionBlocks.append(newAbsorptionBlock)
        absorptionBlocks = absorptionBlocks.sorted()
    }
    
    func removeFromAbsorptionBlocks(absorptionBlockToBeDeleted: AbsorptionBlock) {
        guard let index = absorptionBlocks.firstIndex(where: { $0 == absorptionBlockToBeDeleted }) else {
            return
        }
        absorptionBlocks.remove(at: index)
        managedObjectContext.delete(absorptionBlockToBeDeleted)
    }
    
    func getAbsorptionTime(fpus: Double) -> Int {
        // Round up the fpus - it's more secure to get a longer insulin interval
        let roundedFPUs = Int(fpus.rounded(.up))
        
        // Find associated absorption time
        for absorptionBlock in absorptionBlocks {
            if roundedFPUs <= absorptionBlock.maxFpu {
                return Int(absorptionBlock.absorptionTime)
            }
        }
        
        // Seems to be beyond the last block, so return time of the last block
        return Int(absorptionBlocks[absorptionBlocks.count - 1].maxFpu)
    }
    
    func getMaximumAbsorptionTime() -> Int {
        Int(absorptionBlocks[absorptionBlocks.count - 1].absorptionTime)
    }
    
    func getMaximumFPUs() -> Int {
        Int(absorptionBlocks[absorptionBlocks.count - 1].maxFpu)
    }
    
    static func == (lhs: AbsorptionScheme, rhs: AbsorptionScheme) -> Bool {
        if lhs.getMaximumAbsorptionTime() != rhs.getMaximumAbsorptionTime() {
            return false
        }
        
        if lhs.getMaximumFPUs() != rhs.getMaximumFPUs() {
            return false
        }
        
        return true
    }
}
