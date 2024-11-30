//
//  AbsorptionBlockViewModel.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 30.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class AbsorptionBlockViewModel: ObservableObject, Hashable, Comparable, Identifiable {
    var id: UUID? {
        // We reuse the id of the CoreData AbsorptionBlock
        cdAbsorptionBlock?.id
    }
    
    @Published var maxFpuAsString: String {
        willSet {
            let result = DataHelper.checkForPositiveInt(valueAsString: newValue, allowZero: false)
            switch result {
            case .success(let maxFpu):
                self.maxFpu = maxFpu
            case .failure(let err):
                debugPrint(err.evaluate())
                return
            }
        }
    }
    var absorptionTimeAsString: String {
        willSet {
            let result = DataHelper.checkForPositiveInt(valueAsString: newValue, allowZero: false)
            switch result {
            case .success(let absorptionTime):
                self.absorptionTime = absorptionTime
            case .failure(let err):
                debugPrint(err.evaluate())
                return
            }
        }
    }
    private(set) var maxFpu: Int
    private(set) var absorptionTime: Int
    var cdAbsorptionBlock: AbsorptionBlock?
    
    init(from absorptionBlock: AbsorptionBlock) {
        self.cdAbsorptionBlock = absorptionBlock
        self.maxFpu = Int(absorptionBlock.maxFpu)
        self.maxFpuAsString = String(absorptionBlock.maxFpu)
        self.absorptionTime = Int(absorptionBlock.absorptionTime)
        self.absorptionTimeAsString = String(absorptionBlock.absorptionTime)
    }
    
    init(from absorptionBlock: AbsorptionBlockFromJson) {
        self.maxFpu = absorptionBlock.maxFpu
        self.maxFpuAsString = String(absorptionBlock.maxFpu)
        self.absorptionTime = absorptionBlock.absorptionTime
        self.absorptionTimeAsString = String(absorptionBlock.absorptionTime)
    }
    
    init?(maxFpuAsString: String, absorptionTimeAsString: String, errorMessage: inout String) {
        // Check for valid max fpu
        let resultMaxFpu = DataHelper.checkForPositiveInt(valueAsString: maxFpuAsString, allowZero: false)
        switch resultMaxFpu {
        case .success(let maxFpu):
            self.maxFpu = maxFpu
        case .failure(let err):
            errorMessage = err.evaluate()
            return nil
        }
        self.maxFpuAsString = maxFpuAsString
        
        // Check for valid absorption time
        let resultAbsorptionTime = DataHelper.checkForPositiveInt(valueAsString: absorptionTimeAsString, allowZero: false)
        switch resultAbsorptionTime {
        case .success(let absorptionTime):
            self.absorptionTime = absorptionTime
        case .failure(let err):
            errorMessage = err.evaluate()
            return nil
        }
        self.absorptionTimeAsString = absorptionTimeAsString
    }
    
    func hasAssociatedAbsorptionBlock() -> Bool {
        cdAbsorptionBlock != nil
    }
    
    /// Creates a new Core Data AbsorptionBlock from the passed AbsorptionBlockViewModel
    /// and adds it to the AbsorptionScheme associated with the AbsorptionSchemeViewModel.
    /// - Parameter absorptionScheme: The AbsorptionSchemeViewModel, the Core Data AbsorptionScheme of which the AbsorptionBlock should be added.
    func save(to absorptionScheme: AbsorptionSchemeViewModel) {
        let newCdAbsorptionBlock = AbsorptionBlock.create(from: self)
        absorptionScheme.cdAbsorptionScheme.addToAbsorptionBlocks(newAbsorptionBlock: newCdAbsorptionBlock)
    }
    
    /// Removes the Core Data AbsorptionBlock from the AbsorptionScheme related to the passed AbsorptionSchemeViewModel.
    /// - Parameter absorptionScheme: The AbsorptionSchemeViewModel the AbsorptionScheme is related to.
    /// - Returns: False if the AbsorptionBlockViewModel has no Core Data AbsorptionBlock (should not happen), otherwise true.
    func remove(from absorptionScheme: AbsorptionSchemeViewModel) -> Bool {
        guard let cdAbsorptionBlock else { return false }
        AbsorptionBlock.remove(cdAbsorptionBlock, from: absorptionScheme.cdAbsorptionScheme)
        return true
    }
    
    func updateCdAbsorptionBlock() -> Bool {
        if cdAbsorptionBlock == nil {
            return false
        } else {
            cdAbsorptionBlock!.maxFpu = Int64(maxFpu)
            cdAbsorptionBlock!.absorptionTime = Int64(absorptionTime)
            return true
        }
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
