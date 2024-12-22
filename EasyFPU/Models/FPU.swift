//
//  FPU.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 11.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

struct FPU {
    var fpu: Double
    
    init(fpu: Double) {
        self.fpu = fpu
    }
    
    func getExtendedCarbs() -> Double {
        fpu * UserSettings.shared.eCarbsFactor
    }
    
    func getAbsorptionTime(absorptionScheme: AbsorptionSchemeViewModel) -> Int? {
        absorptionScheme.getAbsorptionTime(fpus: fpu)
    }
}
