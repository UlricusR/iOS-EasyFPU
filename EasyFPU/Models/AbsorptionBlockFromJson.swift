//
//  AbsorptionBlock.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 11.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class AbsorptionBlockFromJson: Codable {
    enum CodingKeys: String, CodingKey {
        case maxFpu, absorptionTime
    }
    
    var maxFpu: Int
    var absorptionTime: Int
    
    init(maxFpu: Int, absorptionTime: Int) {
        self.maxFpu = maxFpu
        self.absorptionTime = absorptionTime
    }
}
