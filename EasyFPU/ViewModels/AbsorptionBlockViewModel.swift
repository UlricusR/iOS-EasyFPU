//
//  AbsorptionBlockViewModel.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 30.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class AbsorptionBlockViewModel: ObservableObject, Hashable, Comparable, Identifiable {
    var id: UUID
    
    /// The string representation of maxFpu. If modified, it will automatically set the respective Int variable and also update the Core Data entry.
    @Published var maxFpuAsString: String {
        willSet {
            let result = DataHelper.checkForPositiveInt(valueAsString: newValue, allowZero: false)
            switch result {
            case .success(let maxFpu):
                self.maxFpu = maxFpu
                
                // Update Core Data AbsorptionBlock
                AbsorptionBlock.updateMaxFpu(cdAbsorptionBlock: cdAbsorptionBlock, with: maxFpu)
            case .failure(let err):
                debugPrint(err.evaluate())
                return
            }
        }
    }
    
    /// The string representation of absorptionTime. If modified, it will automatically set the respective Int variable and also update the Core Data entry.
    var absorptionTimeAsString: String {
        willSet {
            let result = DataHelper.checkForPositiveInt(valueAsString: newValue, allowZero: false)
            switch result {
            case .success(let absorptionTime):
                self.absorptionTime = absorptionTime
                
                // Update Core Data AbsorptionBlock
                AbsorptionBlock.updateAbsorptionTime(cdAbsorptionBlock: cdAbsorptionBlock, with: absorptionTime)
            case .failure(let err):
                debugPrint(err.evaluate())
                return
            }
        }
    }
    private(set) var maxFpu: Int
    private(set) var absorptionTime: Int
    var cdAbsorptionBlock: AbsorptionBlock
    
    init(from absorptionBlock: AbsorptionBlock) {
        self.id = absorptionBlock.id ?? UUID()
        self.cdAbsorptionBlock = absorptionBlock
        self.maxFpu = Int(absorptionBlock.maxFpu)
        self.maxFpuAsString = String(absorptionBlock.maxFpu)
        self.absorptionTime = Int(absorptionBlock.absorptionTime)
        self.absorptionTimeAsString = String(absorptionBlock.absorptionTime)
    }
    
    init(from absorptionBlock: AbsorptionBlockFromJson) {
        self.id = UUID()
        self.cdAbsorptionBlock = AbsorptionBlock.create(from: absorptionBlock, id: self.id)
        self.maxFpu = absorptionBlock.maxFpu
        self.maxFpuAsString = String(absorptionBlock.maxFpu)
        self.absorptionTime = absorptionBlock.absorptionTime
        self.absorptionTimeAsString = String(absorptionBlock.absorptionTime)
    }
    
    init?(maxFpuAsString: String, absorptionTimeAsString: String, activeAlert: inout SimpleAlertType?) {
        // Check for valid max fpu
        let resultMaxFpu = DataHelper.checkForPositiveInt(valueAsString: maxFpuAsString, allowZero: false)
        switch resultMaxFpu {
        case .success(let maxFpu):
            self.maxFpu = maxFpu
        case .failure(let err):
            activeAlert = .error(message: err.evaluate())
            return nil
        }
        self.maxFpuAsString = maxFpuAsString
        
        // Check for valid absorption time
        let resultAbsorptionTime = DataHelper.checkForPositiveInt(valueAsString: absorptionTimeAsString, allowZero: false)
        switch resultAbsorptionTime {
        case .success(let absorptionTime):
            self.absorptionTime = absorptionTime
        case .failure(let err):
            activeAlert = .error(message: err.evaluate())
            return nil
        }
        self.absorptionTimeAsString = absorptionTimeAsString
        
        // Create ID
        self.id = UUID()
        
        // Create Core Data absorption block
        self.cdAbsorptionBlock = AbsorptionBlock.create(absorptionTime: absorptionTime, maxFpu: maxFpu)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func < (lhs: AbsorptionBlockViewModel, rhs: AbsorptionBlockViewModel) -> Bool {
        lhs.maxFpu < rhs.maxFpu
    }
    
    static func == (lhs: AbsorptionBlockViewModel, rhs: AbsorptionBlockViewModel) -> Bool {
        lhs.absorptionTime == rhs.absorptionTime && lhs.maxFpu == rhs.maxFpu
    }
}
