//
//  FPU.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 11.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class FPU {
    var fpu: Double
    
    init(fpu: Double) {
        self.fpu = fpu
    }
    
    func getExtendedCarbs() -> Double {
        fpu * 10
    }
    
    func getAbsorptionTime(absorptionScheme: AbsorptionScheme) -> Int? {
        absorptionScheme.getAbsorptionTime(fpus: fpu)
    }
}
