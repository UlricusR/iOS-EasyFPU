//
//  AbsorptionSchemeViewModel.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 30.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class AbsorptionSchemeViewModel: ObservableObject {
    var absorptionBlocks: [AbsorptionBlockViewModel]
    
    init(from cdAbsorptionScheme: AbsorptionScheme) {
        self.absorptionBlocks = [AbsorptionBlockViewModel]()
        for absorptionBlock in cdAbsorptionScheme.absorptionBlocks {
            self.absorptionBlocks.append(AbsorptionBlockViewModel(from: absorptionBlock))
        }
    }
}
