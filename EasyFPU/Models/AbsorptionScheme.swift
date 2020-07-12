//
//  AbsorptionScheme.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 11.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class AbsorptionScheme: Equatable, Codable {
    var absorptionBlocks: [AbsorptionBlock]
    
    init(absorptionBlocks: [AbsorptionBlock]) {
        self.absorptionBlocks = absorptionBlocks
    }
    
    func getAbsorptionTime(fpus: Double) -> Int {
        // Round up the fpus - it's more secure to get a longer insulin interval
        let roundedFPUs = Int(fpus.rounded(.up))
        
        // Find associated absorption time
        for absorptionBlock in absorptionBlocks {
            if roundedFPUs <= absorptionBlock.maxFpu {
                return absorptionBlock.absorptionTime
            }
        }
        
        // Seems to be beyond the last block, so return time of the last block
        return absorptionBlocks[absorptionBlocks.endIndex].maxFpu
    }
    
    func getMaximumAbsorptionTime() -> Int {
        absorptionBlocks[absorptionBlocks.endIndex].absorptionTime
    }
    
    func getMaximumFPUs() -> Int {
        absorptionBlocks[absorptionBlocks.endIndex].maxFpu
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
