//
//  AbsorptionBlockViewModel.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 30.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class AbsorptionBlockViewModel: ObservableObject, Hashable, Comparable {
    var id = UUID()
    var maxFpuAsString: String
    var absorptionTimeAsString: String
    private(set) var maxFpu: Int
    private(set) var absorptionTime: Int
    
    init(from absorptionBlock: AbsorptionBlock) {
        self.maxFpu = absorptionBlock.maxFpu
        self.maxFpuAsString = String(absorptionBlock.maxFpu)
        self.absorptionTime = absorptionBlock.absorptionTime
        self.absorptionTimeAsString = String(absorptionBlock.absorptionTime)
    }
    
    init?(maxFpuAsString: String, absorptionTimeAsString: String, errorMessage: inout String) {
        // Check for valid max fpu
        let resultMaxFpu = FoodItemViewModel.checkForPositiveInt(valueAsString: maxFpuAsString, allowZero: false)
        switch resultMaxFpu {
        case .success(let maxFpu):
            self.maxFpu = maxFpu
        case .failure(let err):
            errorMessage = err.localizedDescription
            return nil
        }
        self.maxFpuAsString = maxFpuAsString
        
        // Check for valid absorption time
        let resultAbsorptionTime = FoodItemViewModel.checkForPositiveInt(valueAsString: absorptionTimeAsString, allowZero: false)
        switch resultAbsorptionTime {
        case .success(let absorptionTime):
            self.absorptionTime = absorptionTime
        case .failure(let err):
            errorMessage = err.localizedDescription
            return nil
        }
        self.absorptionTimeAsString = absorptionTimeAsString
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func < (lhs: AbsorptionBlockViewModel, rhs: AbsorptionBlockViewModel) -> Bool {
        lhs.maxFpu < rhs.maxFpu
    }
    
    static func == (lhs: AbsorptionBlockViewModel, rhs: AbsorptionBlockViewModel) -> Bool {
        lhs.id == rhs.id
    }
}
