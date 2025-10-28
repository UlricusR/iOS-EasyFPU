//
//  AbsorptionSchemeViewModel.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 30.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

@Observable class AbsorptionScheme {
    // Make this class a singleton
    static let shared = AbsorptionScheme()
    
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
    
    // Singleton should have private initializer to avoid multiple instances
    private init() {
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
    
    /// Tries to add a new absorption block to the absorption scheme. Several checks ensure that the absorption block fits:
    /// (1) If there are no absorption blocks, the new block is simply added.
    /// (2) There must not be any existing blocks with identical maxFPU value.
    /// (3) Absorption time of the previous absorption block needs to be lower, of the next one higher.
    /// If any of these checks is not passed, the function deletes this block from Core Data and returns false.
    /// - Parameters:
    ///   - maxFPU: The maxFPU of the new absorption block.
    ///   - absorptionTime: The absorption time of the new absorption block.
    ///   - saveContext: Whether to save the Core Data context after the operation.
    /// - Returns: A SimpleAlertType if the addition was not successful, nil otherwise.
    func add(
        maxFpu: Int,
        absorptionTime: Int,
        saveContext: Bool
    ) -> SimpleAlertType? {
        // Check no. 1: Maximum FPU must be positive
        if maxFpu <= 0 {
            return (.error(message: "Maximum FPU must be larger than zero"))
        }
        
        let absorptionBlocks = AbsorptionBlock.fetchAll()
        
        // Check no. 2: If the list is empty, then everything is fine, as the new block is the first one
        if absorptionBlocks.count == 0 {
            // Create the new absorption block
            let _ = AbsorptionBlock.create(absorptionTime: absorptionTime, maxFpu: maxFpu, saveContext: saveContext)
            
            // No error, so return nil
            return nil
        }

        // Check no. 3: There are existing blocks, so we must check to not have identical maxFPU values
        for absorptionBlock in absorptionBlocks {
            if absorptionBlock.maxFpu == maxFpu {
                // Duplicate maxFPU values not allowed
                return .error(message: "Maximum FPU value already exists")
            }
        }

        // Now we're sure the new maxFPU is not identical, so we need to check the neighboring blocks
        // For this we need to find the correct position of the new absorption block in the sorted list
        var newBlockIndex: Int = 0
        for (index, absorptionBlock) in absorptionBlocks.enumerated() {
            if maxFpu < absorptionBlock.maxFpu {
                newBlockIndex = index
                break
            } else {
                newBlockIndex = index + 1
            }
        }
        
        // Check no. 4: The absorption block before the new one must have a lower, the one after a higher absorption time
        
        // Case 4a: It's the first element, so just check the block after (which still has index 0 in the absorptionBlocks array) -
        // we have already excluded the case that the new block is the only element in check no. 1!
        if newBlockIndex == 0 {
            if absorptionTime >= absorptionBlocks[0].absorptionTime {
                // Error: The new block's absorption time is equals or larger than of the one after
                return .error(message: "Absorption time is equals or larger than the one of the following absorption block")
            } else {
                // Create the new absorption block
                let _ = AbsorptionBlock.create(absorptionTime: absorptionTime, maxFpu: maxFpu, saveContext: saveContext)
                
                // No error, so return nil
                return nil
            }
        }

        // Case 4b: It's the last element (i.e., the newBlockIndex is equals the number of the existing blocks), so just check the block before
        if newBlockIndex == absorptionBlocks.count {
            if absorptionTime <= absorptionBlocks[absorptionBlocks.count - 1].absorptionTime {
                // Error: The new block's absorption time is equals or less than of the one before
                return .error(message: "Absorption time is equals or less than the one of the block before")
            } else {
                // Create the new absorption block
                let _ = AbsorptionBlock.create(absorptionTime: absorptionTime, maxFpu: maxFpu, saveContext: saveContext)
                
                // No error, so return nil
                return nil
            }
        }

        // Case 4c: It's somewhere in the middle
        if !(absorptionTime > absorptionBlocks[newBlockIndex - 1].absorptionTime &&
              absorptionTime < absorptionBlocks[newBlockIndex].absorptionTime) {
            return .error(message: "Absorption time must be between previous and following block")
        } else {
            // Create the new absorption block
            let _ = AbsorptionBlock.create(absorptionTime: absorptionTime, maxFpu: maxFpu, saveContext: saveContext)
            
            // No error, so return nil
            return nil
        }
    }
    
    /// Replaces an existing absorption block with a new one. The new absorption block is created from the given parameters.
    /// - Parameters:
    ///   - existingAbsorptionBlockID: The ID of the existing absorption block to be replaced.
    ///   - newMaxFpu: The maxFPU of the new absorption block.
    ///   - newAbsorptionTime: The absorption time of the new absorption block.
    ///   - saveContext: Whether to save the Core Data context after the operation.
    /// - Returns: A SimpleAlertType if the replacement was not successful, nil otherwise.
    func replace(
        existingAbsorptionBlockID: UUID,
        newMaxFpu: Int,
        newAbsorptionTime: Int,
        saveContext: Bool
    ) -> SimpleAlertType? {
        let absorptionBlocks = AbsorptionBlock.fetchAll()
        
        // Find the absorption block to be replaced and store its values for later potential undoing
        guard let index = absorptionBlocks.firstIndex(where: { $0.id == existingAbsorptionBlockID }) else {
            return .fatalError(message: "Could not identify absorption block")
        }
        let existingAbsorptionBlockMaxFpu = absorptionBlocks[index].maxFpu
        let existingAbsorptionBlockAbsorptionTime = absorptionBlocks[index].absorptionTime
        
        // Delete the existing absorption block from the scheme, but don't save the context yet
        AbsorptionBlock.remove(absorptionBlocks[index], saveContext: false)
        
        // Try to add the updated absorption block, still w/o saving the context
        if let schemeAlert = self.add(maxFpu: newMaxFpu, absorptionTime: newAbsorptionTime, saveContext: false) {
            // Addition was unsuccessful, so add the old absorption block
            let _ = AbsorptionBlock.create(absorptionTime: Int(existingAbsorptionBlockAbsorptionTime), maxFpu: Int(existingAbsorptionBlockMaxFpu), saveContext: saveContext)
            return schemeAlert
        } else {
            // Addition was successful, so save context and return nil
            if saveContext {
                CoreDataStack.shared.save()
            }
            return nil
        }
    }
    
    /// Removes all existing absorption blocks and loads the default absorption blocks
    /// - Parameter errorMessage: Stores potential error messages.
    /// - Returns: False if the defaults could not be loaded, otherwise true.
    func resetToDefaultAbsorptionBlocks(saveContext: Bool, errorMessage: inout String) -> Bool {
        // Delete Core Data
        AbsorptionBlock.deleteAll(saveContext: false)
        
        return loadDefaultAbsorptionBlocks(saveContext: saveContext, errorMessage: &errorMessage)
    }
    
    /// Returns the absorption time for the given FPUs.
    /// - Parameter fpus: The FPUs to be used for querying the absorption time.
    /// - Returns: Nil if the absorption scheme has no absorption blocks (should not happen), otherwise the absorption time related to the given FPUs.
    func getAbsorptionTime(fpus: Double) -> Int? {
        // Load absorption blocks
        let absorptionBlocks = AbsorptionBlock.fetchAll()
        
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
    
    private func loadDefaultAbsorptionBlocks(saveContext: Bool, errorMessage: inout String) -> Bool {
        // Absorption blocks are empty, so initialize with default absorption scheme
        guard let defaultAbsorptionBlocks = DataHelper.loadDefaultAbsorptionBlocks(errorMessage: &errorMessage) else {
            return false
        }
        
        // Create absorption blocks from default absorption block, but don't save context yet, but only once after the loop
        for absorptionBlock in defaultAbsorptionBlocks {
            let _ = AbsorptionBlock.create(from: absorptionBlock, id: UUID(), saveContext: false)
        }
        
        // Save the context
        if saveContext {
            CoreDataStack.shared.save()
        }
        
        return true
    }
    
    static func sampleData() -> AbsorptionScheme {
        let absorptionScheme = AbsorptionScheme()
        let _ = AbsorptionBlock.create(absorptionTime: 3, maxFpu: 1, saveContext: false)
        let _ = AbsorptionBlock.create(absorptionTime: 4, maxFpu: 2, saveContext: false)
        let _ = AbsorptionBlock.create(absorptionTime: 5, maxFpu: 3, saveContext: false)
        let _ = AbsorptionBlock.create(absorptionTime: 6, maxFpu: 4, saveContext: false)
        let _ = AbsorptionBlock.create(absorptionTime: 8, maxFpu: 6, saveContext: false)
        return absorptionScheme
    }
}
