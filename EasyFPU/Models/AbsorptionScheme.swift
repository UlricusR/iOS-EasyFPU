//
//  AbsorptionScheme.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 11.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

class AbsorptionScheme: Equatable {
    var absorptionBlocks = [AbsorptionBlock]()
    
    func addToAbsorptionBlocks(newAbsorptionBlock: AbsorptionBlock) {
        absorptionBlocks.append(newAbsorptionBlock)
        absorptionBlocks = absorptionBlocks.sorted()
    }
    
    func removeFromAbsorptionBlocks(absorptionBlockToBeDeleted: AbsorptionBlock) {
        guard let index = absorptionBlocks.firstIndex(where: { $0 == absorptionBlockToBeDeleted }) else {
            return
        }
        absorptionBlocks.remove(at: index)
    }
    
    func getAbsorptionTime(fpus: Double) -> Int {
        if absorptionBlocks.count == 0 {
            // This is to make sure we have no index error and app crash - default will be loaded later
            return 100
        }
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
