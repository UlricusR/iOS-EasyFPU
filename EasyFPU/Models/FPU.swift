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
    var eCarbsFactor: Double = UserSettings.getValue(for: UserSettings.UserDefaultsDoubleKey.eCarbsFactor) ?? AbsorptionSchemeViewModel.eCarbsFactorDefault
    
    init(fpu: Double) {
        self.fpu = fpu
    }
    
    func getExtendedCarbs() -> Double {
        fpu * eCarbsFactor
    }
    
    func getAbsorptionTime(absorptionScheme: AbsorptionScheme) -> Int? {
        absorptionScheme.getAbsorptionTime(fpus: fpu)
    }
}
