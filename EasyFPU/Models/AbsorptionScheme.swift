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
        return Int(absorptionBlocks[absorptionBlocks.count - 1].absorptionTime)
    }
    
    func getMaximumAbsorptionTime() -> Int? {
        if absorptionBlocks.count > 0 {
            return Int(absorptionBlocks[absorptionBlocks.count - 1].absorptionTime)
        } else {
            return nil
        }
    }
    
    func getMaximumFPUs() -> Int? {
        if absorptionBlocks.count > 0 {
            return Int(absorptionBlocks[absorptionBlocks.count - 1].maxFpu)
        } else {
            return nil
        }
    }
    
    static func == (lhs: AbsorptionScheme, rhs: AbsorptionScheme) -> Bool {
        guard
            let lhsMaxAbsorptionTime = lhs.getMaximumAbsorptionTime(),
            let rhsMaxAbsorptionTime = rhs.getMaximumAbsorptionTime(),
            let lhsMaxFPUs = lhs.getMaximumFPUs(),
            let rhsMaxFPUs = rhs.getMaximumFPUs()
        else {
            return false
        }
        
        if lhsMaxAbsorptionTime != rhsMaxAbsorptionTime {
            return false
        }
        
        if lhsMaxFPUs != rhsMaxFPUs {
            return false
        }
        
        return true
    }
}
