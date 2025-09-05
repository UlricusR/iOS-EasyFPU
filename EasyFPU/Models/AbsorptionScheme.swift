//
//  AbsorptionSchemeViewModel.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 30.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

@Observable class AbsorptionScheme {
    var absorptionBlocks = [AbsorptionBlock]()
    
    // Absorption block parameters for sugars
    var delaySugars: Int = AbsorptionScheme.absorptionTimeSugarsDelayDefault
    var intervalSugars: Int = AbsorptionScheme.absorptionTimeSugarsIntervalDefault
    var durationSugars: Double = AbsorptionScheme.absoprtionTimeSugarsDurationDefault
    
    // Absorption block parameters for carbs
    var delayCarbs: Int = AbsorptionScheme.absorptionTimeCarbsDelayDefault
    var intervalCarbs: Int = AbsorptionScheme.absorptionTimeCarbsIntervalDefault
    var durationCarbs: Double = AbsorptionScheme.absoprtionTimeCarbsDurationDefault
    
    // Absorption block parameters for e-Carbs
    var delayECarbs: Int = AbsorptionScheme.absorptionTimeECarbsDelayDefault
    var intervalECarbs: Int = AbsorptionScheme.absorptionTimeECarbsIntervalDefault
    
    // e-Carbs factor
    var eCarbsFactor: Double = AbsorptionScheme.eCarbsFactorDefault
    
    // Treat sugars separately
    var treatSugarsSeparately: Bool = AbsorptionScheme.treatSugarsSeparatelyDefault
    
    static let absorptionTimeSugarsDelayDefault: Int = 0 // minutes
    static let absorptionTimeSugarsIntervalDefault: Int = 5 // minutes
    static let absoprtionTimeSugarsDurationDefault: Double = 2 // hours
    static let absorptionTimeCarbsDelayDefault: Int = 5 // minutes
    static let absorptionTimeCarbsIntervalDefault: Int = 5 // minutes
    static let absoprtionTimeCarbsDurationDefault: Double = 3 // hours
    static let absorptionTimeECarbsDelayDefault: Int = 90 // minutes
    static let absorptionTimeECarbsIntervalDefault: Int = 10 // minutes
    static let eCarbsFactorDefault: Double = 10 // g e-carbs per FPU
    static let treatSugarsSeparatelyDefault: Bool = true
    
    init() {
        // Sugars
        let delaySugars = UserSettings.shared.absorptionTimeSugarsDelayInMinutes
        self.delaySugars = delaySugars
        
        let intervalSugars = UserSettings.shared.absorptionTimeSugarsIntervalInMinutes
        self.intervalSugars = intervalSugars
        
        let durationSugars = UserSettings.shared.absorptionTimeSugarsDurationInHours
        self.durationSugars = durationSugars
        
        // Carbs
        let delayCarbs = UserSettings.shared.absorptionTimeCarbsDelayInMinutes
        self.delayCarbs = delayCarbs
        
        let intervalCarbs = UserSettings.shared.absorptionTimeCarbsIntervalInMinutes
        self.intervalCarbs = intervalCarbs
        
        let durationCarbs = UserSettings.shared.absorptionTimeCarbsDurationInHours
        self.durationCarbs = durationCarbs
        
        // E-Carbs
        let delayECarbs = UserSettings.shared.absorptionTimeECarbsDelayInMinutes
        self.delayECarbs = delayECarbs
        
        let intervalECarbs = UserSettings.shared.absorptionTimeECarbsIntervalInMinutes
        self.intervalECarbs = intervalECarbs
        
        let eCarbsFactor = UserSettings.getValue(for: UserSettings.UserDefaultsDoubleKey.eCarbsFactor) ?? AbsorptionScheme.eCarbsFactorDefault
        self.eCarbsFactor = eCarbsFactor
        
        self.treatSugarsSeparately = UserSettings.getValue(for: UserSettings.UserDefaultsBoolKey.treatSugarsSeparately) ?? AbsorptionScheme.treatSugarsSeparatelyDefault
    }
    
    /// Initializes the absorption scheme with absorption blocks - this function should be called immeditely after the class has been initialized.
    /// - Parameter cdAbsorptionBlocks: The Core Data absorption blocks to be added.
    func initAbsorptionBlocks(with cdAbsorptionBlocks: FetchedResults<AbsorptionBlock>, saveContext: Bool, errorMessage: inout String) -> Bool {
        // Load absorption blocks
        if cdAbsorptionBlocks.isEmpty {
            // Absorption blocks are empty, so initialize with default absorption scheme
            if !loadDefaultAbsorptionBlocks(saveContext: saveContext, errorMessage: &errorMessage) { return false }
        } else {
            self.absorptionBlocks = Array(cdAbsorptionBlocks)
        }
        
        // Sort absorption blocks
        absorptionBlocks = absorptionBlocks.sorted()
        
        return true
    }
    
    func add(maxFPU: Int, absorptionTime: Int, saveContext: Bool) -> SimpleAlertType? {
        let newAbsorptionBlock = AbsorptionBlock.create(absorptionTime: absorptionTime, maxFpu: maxFPU, saveContext: saveContext)
        return add(newAbsorptionBlock: newAbsorptionBlock, saveContext: saveContext)
    }
    
    /// Tries to add a new absorption block to the absorption scheme. Several checks ensure that the absorption block fits:
    /// (1) If there are no absorption blocks, the new block is simply added.
    /// (2) There must not be any existing blocks with identical maxFPU value.
    /// (3) Absorption time of the previous absorption block needs to be lower, of the next one higher.
    /// If any of these checks is not passed, the function deletes this block from Core Data and returns false.
    /// - Parameters:
    ///   - newAbsorptionBlock: The absorption block to be added.
    ///   - errorMessage: The error message in case of no success.
    /// - Returns: False if any of the checks is not passed, true if the block was added.
    func add(newAbsorptionBlock: AbsorptionBlock, saveContext: Bool) -> SimpleAlertType? {
        // Check no. 1: If the list is empty, then everything is fine, as the new block is the first one
        if absorptionBlocks.count == 0 {
            absorptionBlocks.append(newAbsorptionBlock)
            return nil
        }

        // Check no. 2: There are existing blocks, so we must check to not have identical maxFPU values
        for absorptionBlock in absorptionBlocks {
            if absorptionBlock.maxFpu == newAbsorptionBlock.maxFpu {
                // Duplicate maxFPU values not allowed
                let alert = SimpleAlertType.error(message: "Maximum FPU value already exists")
                
                // Remove newAbsorptionBlock from Core Data
                AbsorptionBlock.remove(newAbsorptionBlock, saveContext: saveContext)
                
                return alert
            }
        }

        // Now we're sure the new maxFPU is not identical, therefore we add new absorption block and sort
        absorptionBlocks.append(newAbsorptionBlock)
        absorptionBlocks = absorptionBlocks.sorted()

        // Check no. 3: The absorption block before the new one must have a lower, the one after a higher absorption time
        guard let newBlockIndex = absorptionBlocks.firstIndex(of: newAbsorptionBlock) else {
            // This should never happen
            let alert = SimpleAlertType.fatalError(message: "Cannot determine absorption block index.")
            
            // Remove newAbsorptionBlock from Core Data
            AbsorptionBlock.remove(newAbsorptionBlock, saveContext: saveContext)
            
            return alert
        }

        // Case 3a: It's the first element, so just check the block after -
        // we have already excluded the case that the new block is the only element in check no. 1!
        if newBlockIndex == 0 {
            if newAbsorptionBlock.absorptionTime >= absorptionBlocks[1].absorptionTime {
                // Error: The new block's absorption time is equals or larger than of the one after
                absorptionBlocks.remove(at: newBlockIndex)
                let alert = SimpleAlertType.error(message: "Absorption time is equals or larger than the one of the following absorption block")
                
                // Remove newAbsorptionBlock from Core Data
                AbsorptionBlock.remove(newAbsorptionBlock, saveContext: saveContext)
                
                return alert
            } else {
                // No error, so return nil
                return nil
            }
        }

        // Case 3b: It's the last element, so just check the block before
        if newBlockIndex == absorptionBlocks.count - 1 {
            if newAbsorptionBlock.absorptionTime <= absorptionBlocks[absorptionBlocks.count - 2].absorptionTime {
                // Error: The new block's absorption time is equals or less than of the one before
                absorptionBlocks.remove(at: newBlockIndex)
                let alert = SimpleAlertType.error(message: "Absorption time is equals or less than the one of the block before")
                
                // Remove newAbsorptionBlock from Core Data
                AbsorptionBlock.remove(newAbsorptionBlock, saveContext: saveContext)
                
                return alert
            } else {
                // No error, so return nil
                return nil
            }
        }

        // Case 3c: It's somewhere in the middle
        if !(newAbsorptionBlock.absorptionTime > absorptionBlocks[newBlockIndex - 1].absorptionTime &&
              newAbsorptionBlock.absorptionTime < absorptionBlocks[newBlockIndex + 1].absorptionTime) {
            absorptionBlocks.remove(at: newBlockIndex)
            let alert = SimpleAlertType.error(message: "Absorption time must be between previous and following block")
            
            // Remove newAbsorptionBlock from Core Data
            AbsorptionBlock.remove(newAbsorptionBlock, saveContext: saveContext)
            
            return alert
        } else {
            // No error, so return nil
            return nil
        }
    }
    
    /// Replaces an existing absorption block with a new one. The new absorption block is created from the given parameters.
    /// - Parameters:
    ///   - existingAbsorptionBlockID: The ID of the existing absorption block to be replaced.
    ///   - newMaxFpu: The maxFPU of the new absorption block.
    ///   - newAbsorptionTime: The absorption time of the new absorption block.
    /// - Returns: A SimpleAlertType if the replacement was not successful, nil otherwise.
    func replace(existingAbsorptionBlockID: UUID, newMaxFpu: Int, newAbsorptionTime: Int, saveContext: Bool) -> SimpleAlertType? {
        // Find the absorption block to be replaced and store it for later potential undoing
        guard let index = self.absorptionBlocks.firstIndex(where: { $0.id == existingAbsorptionBlockID }) else {
            return .fatalError(message: "Could not identify absorption block")
        }
        let existingAbsorptionBlock = self.absorptionBlocks[index]
        
        // Remove the existing absorption block
        self.absorptionBlocks.remove(at: index)
        
        // Try to create the new absorption block
        let newAbsorptionBlock = AbsorptionBlock.create(absorptionTime: newAbsorptionTime, maxFpu: newMaxFpu, saveContext: saveContext)
        
        // The absorption block was successfully created, now add it to the absorption scheme
        if let schemeAlert = self.add(newAbsorptionBlock: newAbsorptionBlock, saveContext: saveContext) {
            // Addition was unsuccessful, so undo deletion of block by adding it at the old position
            self.absorptionBlocks.insert(existingAbsorptionBlock, at: index)
            return schemeAlert
        } else {
            // Addition was successful, so delete old absorption block in Core Data, as we don't need it any longer
            AbsorptionBlock.remove(existingAbsorptionBlock, saveContext: saveContext)
            
            // Return nil, as job is successfully done
            return nil
        }
    }
    
    /// Removes the absorptionBlock at the given index from the scheme and deletes it in Core Data.
    /// - Parameter absorptionBlockIndex: The index of the absorptionBlock to be removed.
    /// - Returns: False if the absorptionBlockIndex is out of range, true otherwise.
    func removeAbsorptionBlock(at absorptionBlockIndex: Int, saveContext: Bool) -> Bool {
        if absorptionBlockIndex < absorptionBlocks.count {
            // Delete Core Data absorption block
            AbsorptionBlock.remove(absorptionBlocks[absorptionBlockIndex], saveContext: saveContext)
            
            // Remove VM from scheme
            absorptionBlocks.remove(at: absorptionBlockIndex)
            
            return true
        } else {
            return false
        }
    }
    
    /// Removes all existing absorption blocks and loads the default absorption blocks
    /// - Parameter errorMessage: Stores potential error messages.
    /// - Returns: False if the defaults could not be loaded, otherwise true.
    func resetToDefaultAbsorptionBlocks(saveContext: Bool, errorMessage: inout String) -> Bool {
        // Delete Core Data
        AbsorptionBlock.deleteAll()
        
        // Empty list
        absorptionBlocks.removeAll()
        
        if !loadDefaultAbsorptionBlocks(saveContext: saveContext, errorMessage: &errorMessage) {
            return false
        } else {
            // Sort absorption blocks
            absorptionBlocks = absorptionBlocks.sorted()
            
            return true
        }
    }
    
    /// Returns the absorption time for the given FPUs.
    /// - Parameter fpus: The FPUs to be used for querying the absorption time.
    /// - Returns: Nil if the absorption scheme has no absorption blocks (should not happen), otherwise the absorption time related to the given FPUs.
    func getAbsorptionTime(fpus: Double) -> Int? {
        if absorptionBlocks.count == 0 {
            // This is to make sure we have no index error and app crash - default will be loaded later
            return nil
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
    
    /// Returns the maximum absorption time of all absorption blocks (i.e., the absorption time of the last block).
    /// - Returns: Nil if the absorption scheme has no absorption blocks (should not happen), otherwise the maximum absorption time.
    func getMaximumAbsorptionTime() -> Int? {
        if absorptionBlocks.count > 0 {
            return Int(absorptionBlocks[absorptionBlocks.count - 1].absorptionTime)
        } else {
            return nil
        }
    }
    
    /// Returns the maximum FPUs of the absorption scheme (i.e., the maxFPU value of the last block).
    /// - Returns: Nil if the absorption scheme has no absorption blocks (should not happen), otherwise the maximum of the maxFPU values.
    func getMaximumFPUs() -> Int? {
        if absorptionBlocks.count > 0 {
            return Int(absorptionBlocks[absorptionBlocks.count - 1].maxFpu)
        } else {
            return nil
        }
    }
    
    private func loadDefaultAbsorptionBlocks(saveContext: Bool, errorMessage: inout String) -> Bool {
        // Absorption blocks are empty, so initialize with default absorption scheme
        guard let defaultAbsorptionBlocks = DataHelper.loadDefaultAbsorptionBlocks(errorMessage: &errorMessage) else {
            return false
        }
        
        // Create absorption blocks from default absorption block, but don't save context yet, but only once after the loop
        for absorptionBlock in defaultAbsorptionBlocks {
            absorptionBlocks.append(AbsorptionBlock.create(from: absorptionBlock, id: UUID(), saveContext: saveContext))
        }
        
        // Save the context
        if saveContext {
            CoreDataStack.shared.save()
        }
        
        return true
    }
    
    static func sampleData() -> AbsorptionScheme {
        let absorptionScheme = AbsorptionScheme()
        absorptionScheme.absorptionBlocks.append(AbsorptionBlock.create(absorptionTime: 3, maxFpu: 1, saveContext: false))
        absorptionScheme.absorptionBlocks.append(AbsorptionBlock.create(absorptionTime: 4, maxFpu: 2, saveContext: false))
        absorptionScheme.absorptionBlocks.append(AbsorptionBlock.create(absorptionTime: 5, maxFpu: 3, saveContext: false))
        absorptionScheme.absorptionBlocks.append(AbsorptionBlock.create(absorptionTime: 6, maxFpu: 4, saveContext: false))
        absorptionScheme.absorptionBlocks.append(AbsorptionBlock.create(absorptionTime: 8, maxFpu: 6, saveContext: false))
        return absorptionScheme
    }
}
