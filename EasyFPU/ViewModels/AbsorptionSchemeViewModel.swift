//
//  AbsorptionSchemeViewModel.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 30.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

class AbsorptionSchemeViewModel: ObservableObject {
    @Published var absorptionBlockVMs = [AbsorptionBlockViewModel]() // TODO delete after refactoring
    @Published var absorptionBlocks = [AbsorptionBlock]()
    
    // Absorption block parameters for sugars
    private(set) var delaySugars: Int = AbsorptionSchemeViewModel.absorptionTimeSugarsDelayDefault
    @Published var delaySugarsAsString = "" {
        willSet {
            let result = DataHelper.checkForPositiveInt(valueAsString: newValue, allowZero: true)
            switch result {
            case .success(let value):
                self.delaySugars = value
            case .failure(let err):
                debugPrint(err.evaluate())
                return
            }
        }
    }
    private(set) var intervalSugars: Int = AbsorptionSchemeViewModel.absorptionTimeSugarsIntervalDefault
    @Published var intervalSugarsAsString = "" {
        willSet {
            let result = DataHelper.checkForPositiveInt(valueAsString: newValue, allowZero: false)
            switch result {
            case .success(let value):
                self.intervalSugars = value
            case .failure(let err):
                debugPrint(err.evaluate())
                return
            }
        }
    }
    private(set) var durationSugars: Double = AbsorptionSchemeViewModel.absoprtionTimeSugarsDurationDefault
    @Published var durationSugarsAsString = "" {
        willSet {
            let result = DataHelper.checkForPositiveDouble(valueAsString: newValue, allowZero: false)
            switch result {
            case .success(let value):
                self.durationSugars = value
            case .failure(let err):
                debugPrint(err.evaluate())
                return
            }
        }
    }
    
    // Absorption block parameters for carbs
    private(set) var delayCarbs: Int = AbsorptionSchemeViewModel.absorptionTimeCarbsDelayDefault
    @Published var delayCarbsAsString = "" {
        willSet {
            let result = DataHelper.checkForPositiveInt(valueAsString: newValue, allowZero: true)
            switch result {
            case .success(let value):
                self.delayCarbs = value
            case .failure(let err):
                debugPrint(err.evaluate())
                return
            }
        }
    }
    private(set) var intervalCarbs: Int = AbsorptionSchemeViewModel.absorptionTimeCarbsIntervalDefault
    @Published var intervalCarbsAsString = "" {
        willSet {
            let result = DataHelper.checkForPositiveInt(valueAsString: newValue, allowZero: false)
            switch result {
            case .success(let value):
                self.intervalCarbs = value
            case .failure(let err):
                debugPrint(err.evaluate())
                return
            }
        }
    }
    private(set) var durationCarbs: Double = AbsorptionSchemeViewModel.absoprtionTimeCarbsDurationDefault
    @Published var durationCarbsAsString = "" {
        willSet {
            let result = DataHelper.checkForPositiveDouble(valueAsString: newValue, allowZero: false)
            switch result {
            case .success(let value):
                self.durationCarbs = value
            case .failure(let err):
                debugPrint(err.evaluate())
                return
            }
        }
    }
    
    // Absorption block parameters for e-Carbs
    private(set) var delayECarbs: Int = AbsorptionSchemeViewModel.absorptionTimeECarbsDelayDefault
    @Published var delayECarbsAsString = "" {
        willSet {
            let result = DataHelper.checkForPositiveInt(valueAsString: newValue, allowZero: true)
            switch result {
            case .success(let value):
                self.delayECarbs = value
            case .failure(let err):
                debugPrint(err.evaluate())
                return
            }
        }
    }
    private(set) var intervalECarbs: Int = AbsorptionSchemeViewModel.absorptionTimeECarbsIntervalDefault
    @Published var intervalECarbsAsString = "" {
        willSet {
            let result = DataHelper.checkForPositiveInt(valueAsString: newValue, allowZero: false)
            switch result {
            case .success(let value):
                self.intervalECarbs = value
            case .failure(let err):
                debugPrint(err.evaluate())
                return
            }
        }
    }
    
    // e-Carbs factor
    private(set) var eCarbsFactor: Double = AbsorptionSchemeViewModel.eCarbsFactorDefault
    @Published var eCarbsFactorAsString = "" {
        willSet {
            let result = DataHelper.checkForPositiveDouble(valueAsString: newValue, allowZero: false)
            switch result {
            case .success(let value):
                self.eCarbsFactor = value
            case .failure(let err):
                debugPrint(err.evaluate())
                return
            }
        }
    }
    
    // Treat sugars separately
    @Published var treatSugarsSeparately: Bool = AbsorptionSchemeViewModel.treatSugarsSeparatelyDefault
    
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
        self.delaySugarsAsString = DataHelper.doubleFormatter(numberOfDigits: 0).string(from: NSNumber(value: delaySugars))!
        
        let intervalSugars = UserSettings.shared.absorptionTimeSugarsIntervalInMinutes
        self.intervalSugars = intervalSugars
        self.intervalSugarsAsString = DataHelper.doubleFormatter(numberOfDigits: 0).string(from: NSNumber(value: intervalSugars))!
        
        let durationSugars = UserSettings.shared.absorptionTimeSugarsDurationInHours
        self.durationSugars = durationSugars
        self.durationSugarsAsString = DataHelper.doubleFormatter(numberOfDigits: 0).string(from: NSNumber(value: durationSugars))!
        
        // Carbs
        let delayCarbs = UserSettings.shared.absorptionTimeCarbsDelayInMinutes
        self.delayCarbs = delayCarbs
        self.delayCarbsAsString = DataHelper.doubleFormatter(numberOfDigits: 0).string(from: NSNumber(value: delayCarbs))!
        
        let intervalCarbs = UserSettings.shared.absorptionTimeCarbsIntervalInMinutes
        self.intervalCarbs = intervalCarbs
        self.intervalCarbsAsString = DataHelper.doubleFormatter(numberOfDigits: 0).string(from: NSNumber(value: intervalCarbs))!
        
        let durationCarbs = UserSettings.shared.absorptionTimeCarbsDurationInHours
        self.durationCarbs = durationCarbs
        self.durationCarbsAsString = DataHelper.doubleFormatter(numberOfDigits: 0).string(from: NSNumber(value: durationCarbs))!
        
        // E-Carbs
        let delayECarbs = UserSettings.shared.absorptionTimeECarbsDelayInMinutes
        self.delayECarbs = delayECarbs
        self.delayECarbsAsString = DataHelper.doubleFormatter(numberOfDigits: 0).string(from: NSNumber(value: delayECarbs))!
        
        let intervalECarbs = UserSettings.shared.absorptionTimeECarbsIntervalInMinutes
        self.intervalECarbs = intervalECarbs
        self.intervalECarbsAsString = DataHelper.doubleFormatter(numberOfDigits: 0).string(from: NSNumber(value: intervalECarbs))!
        
        let eCarbsFactor = UserSettings.getValue(for: UserSettings.UserDefaultsDoubleKey.eCarbsFactor) ?? AbsorptionSchemeViewModel.eCarbsFactorDefault
        self.eCarbsFactor = eCarbsFactor
        self.eCarbsFactorAsString = DataHelper.doubleFormatter(numberOfDigits: 0).string(from: NSNumber(value: eCarbsFactor))!
        
        self.treatSugarsSeparately = UserSettings.getValue(for: UserSettings.UserDefaultsBoolKey.treatSugarsSeparately) ?? AbsorptionSchemeViewModel.treatSugarsSeparatelyDefault
    }
    
    /// Initializes the absorption scheme with absorption blocks - this function should be called immeditely after the class has been initialized.
    /// - Parameter cdAbsorptionBlocks: The Core Data absorption blocks to be added.
    func initAbsorptionBlocks(with cdAbsorptionBlocks: FetchedResults<AbsorptionBlock>, errorMessage: inout String) -> Bool {
        // Load absorption blocks
        if cdAbsorptionBlocks.isEmpty {
            // Absorption blocks are empty, so initialize with default absorption scheme
            if !loadDefaultAbsorptionBlocks(errorMessage: &errorMessage) { return false }
        } else {
            // Add absorption blocks loaded from core data
            for absorptionBlock in cdAbsorptionBlocks {
                absorptionBlockVMs.append(AbsorptionBlockViewModel(from: absorptionBlock))
            }
        }
        
        // Sort absorption blocks
        absorptionBlockVMs = absorptionBlockVMs.sorted()
        
        return true
    }
    
    /// Tries to add a new absorption block to the absorption scheme. Several checks ensure that the absorption block fits:
    /// (1) If there are no absorption blocks, the new block is simply added.
    /// (2) There must not be any existing blocks with identical maxFPU value.
    /// (3) Absorption time of the previous absorption block needs to be lower, of the next one higher.
    /// If any of these checks is not passed, the function deletes this block from Core Data and returns false.
    /// - Parameters:
    ///   - newAbsorptionBlock: The absorption block to be added, which is already stored in CoreData.
    ///   - errorMessage: The error message in case of no success.
    /// - Returns: False if any of the checks is not passed, true if the block was added.
    func add(newAbsorptionBlock: AbsorptionBlockViewModel) -> SimpleAlertType? {
        // Check no. 1: If the list is empty, then everything is fine, as the new block is the first one
        if absorptionBlockVMs.count == 0 {
            absorptionBlockVMs.append(newAbsorptionBlock)
            return nil
        }

        // Check no. 2: There are existing blocks, so we must check to not have identical maxFPU values
        for absorptionBlock in absorptionBlockVMs {
            if absorptionBlock.maxFpu == newAbsorptionBlock.maxFpu {
                // Duplicate maxFPU values not allowed
                let alert = SimpleAlertType.error(message: "Maximum FPU value already exists")
                
                // Remove newAbsorptionBlock from Core Data
                AbsorptionBlock.remove(newAbsorptionBlock.cdAbsorptionBlock, saveContext: true)
                
                return alert
            }
        }

        // Now we're sure the new maxFPU is not identical, therefore we add new absorption block and sort
        absorptionBlockVMs.append(newAbsorptionBlock)
        absorptionBlockVMs = absorptionBlockVMs.sorted()

        // Check no. 3: The absorption block before the new one must have a lower, the one after a higher absorption time
        guard let newBlockIndex = absorptionBlockVMs.firstIndex(of: newAbsorptionBlock) else {
            // This should never happen
            let alert = SimpleAlertType.fatalError(message: "Cannot determine absorption block index.")
            
            // Remove newAbsorptionBlock from Core Data
            AbsorptionBlock.remove(newAbsorptionBlock.cdAbsorptionBlock, saveContext: true)
            
            return alert
        }

        // Case 3a: It's the first element, so just check the block after -
        // we have already excluded the case that the new block is the only element in check no. 1!
        if newBlockIndex == 0 {
            if newAbsorptionBlock.absorptionTime >= absorptionBlockVMs[1].absorptionTime {
                // Error: The new block's absorption time is equals or larger than of the one after
                absorptionBlockVMs.remove(at: newBlockIndex)
                let alert = SimpleAlertType.error(message: "Absorption time is equals or larger than the one of the following absorption block")
                
                // Remove newAbsorptionBlock from Core Data
                AbsorptionBlock.remove(newAbsorptionBlock.cdAbsorptionBlock, saveContext: true)
                
                return alert
            } else {
                // No error, so return nil
                return nil
            }
        }

        // Case 3b: It's the last element, so just check the block before
        if newBlockIndex == absorptionBlockVMs.count - 1 {
            if newAbsorptionBlock.absorptionTime <= absorptionBlockVMs[absorptionBlockVMs.count - 2].absorptionTime {
                // Error: The new block's absorption time is equals or less than of the one before
                absorptionBlockVMs.remove(at: newBlockIndex)
                let alert = SimpleAlertType.error(message: "Absorption time is equals or less than the one of the block before")
                
                // Remove newAbsorptionBlock from Core Data
                AbsorptionBlock.remove(newAbsorptionBlock.cdAbsorptionBlock, saveContext: true)
                
                return alert
            } else {
                // No error, so return nil
                return nil
            }
        }

        // Case 3c: It's somewhere in the middle
        if !(newAbsorptionBlock.absorptionTime > absorptionBlockVMs[newBlockIndex - 1].absorptionTime &&
              newAbsorptionBlock.absorptionTime < absorptionBlockVMs[newBlockIndex + 1].absorptionTime) {
            absorptionBlockVMs.remove(at: newBlockIndex)
            let alert = SimpleAlertType.error(message: "Absorption time must be between previous and following block")
            
            // Remove newAbsorptionBlock from Core Data
            AbsorptionBlock.remove(newAbsorptionBlock.cdAbsorptionBlock, saveContext: true)
            
            return alert
        } else {
            // No error, so return nil
            return nil
        }
    }
    
    /// Tries to replace an absorption block with another one. If not successful, the existing absorption block is kept.
    /// - Parameters:
    ///   - existingAbsorptionBlockID: The ID of the existing absorption block to be replaced.
    ///   - newMaxFpuAsString: The maxFPU of the new absorption block.
    ///   - newAbsorptionTimeAsString: The absorptionTime of the new absorption block.
    ///   - errorMessage: Stores the error message if something goes wrong.
    /// - Returns: True in case of a successful replacement, otherwise false (along with the errorMessage).
    func replace(existingAbsorptionBlockID: UUID, newMaxFpuAsString: String, newAbsorptionTimeAsString: String) -> SimpleAlertType? {
        // Find the absorption block to be replaced and store it for later potential undoing
        guard let index = self.absorptionBlockVMs.firstIndex(where: { $0.id == existingAbsorptionBlockID }) else {
            return .fatalError(message: "Could not identify absorption block")
        }
        let existingAbsorptionBlock = self.absorptionBlockVMs[index]
        
        // Remove the existing absorption block
        self.absorptionBlockVMs.remove(at: index)
        
        // Try to create the new absorption block
        var blockAlert: SimpleAlertType? = nil
        if let newAbsorptionBlock = AbsorptionBlockViewModel(maxFpuAsString: newMaxFpuAsString, absorptionTimeAsString: newAbsorptionTimeAsString, activeAlert: &blockAlert) {
            // The absorption block was successfully created (also in Core Data), now add it to the absorption scheme
            if let schemeAlert = self.add(newAbsorptionBlock: newAbsorptionBlock) {
                // Addition was unsuccessful, so undo deletion of block by adding it at the old position
                self.absorptionBlockVMs.insert(existingAbsorptionBlock, at: index)
                return schemeAlert
            } else {
                // Addition was successful, so delete old absorption block in Core Data, as we don't need it any longer
                AbsorptionBlock.remove(existingAbsorptionBlock.cdAbsorptionBlock, saveContext: true)
                
                // Return nil, as job is successfully done
                return nil
            }
        } else {
            // The absorption block was not created successfully, so return false
            return blockAlert
        }
    }
    
    /// Removes the absorptionBlock at the given index from the scheme and deletes it in Core Data.
    /// - Parameter absorptionBlockIndex: The index of the absorptionBlock to be removed.
    /// - Returns: False if the absorptionBlockIndex is out of range, true otherwise.
    func removeAbsorptionBlock(at absorptionBlockIndex: Int) -> Bool {
        if absorptionBlockIndex < absorptionBlockVMs.count {
            // Delete Core Data absorption block
            AbsorptionBlock.remove(absorptionBlockVMs[absorptionBlockIndex].cdAbsorptionBlock, saveContext: true)
            
            // Remove VM from scheme
            absorptionBlockVMs.remove(at: absorptionBlockIndex)
            
            return true
        } else {
            return false
        }
    }
    
    /// Removes all existing absorption blocks and loads the default absorption blocks
    /// - Parameter errorMessage: Stores potential error messages.
    /// - Returns: False if the defaults could not be loaded, otherwise true.
    func resetToDefaultAbsorptionBlocks(errorMessage: inout String) -> Bool {
        // Delete Core Data
        AbsorptionBlock.deleteAll()
        
        // Empty list
        absorptionBlockVMs.removeAll()
        
        if !loadDefaultAbsorptionBlocks(errorMessage: &errorMessage) {
            return false
        } else {
            // Sort absorption blocks
            absorptionBlockVMs = absorptionBlockVMs.sorted()
            
            return true
        }
    }
    
    /// Returns the absorption time for the given FPUs.
    /// - Parameter fpus: The FPUs to be used for querying the absorption time.
    /// - Returns: Nil if the absorption scheme has no absorption blocks (should not happen), otherwise the absorption time related to the given FPUs.
    func getAbsorptionTime(fpus: Double) -> Int? {
        if absorptionBlockVMs.count == 0 {
            // This is to make sure we have no index error and app crash - default will be loaded later
            return nil
        }
        // Round up the fpus - it's more secure to get a longer insulin interval
        let roundedFPUs = Int(fpus.rounded(.up))
        
        // Find associated absorption time
        for absorptionBlock in absorptionBlockVMs {
            if roundedFPUs <= absorptionBlock.maxFpu {
                return Int(absorptionBlock.absorptionTime)
            }
        }
        
        // Seems to be beyond the last block, so return time of the last block
        return Int(absorptionBlockVMs[absorptionBlockVMs.count - 1].absorptionTime)
    }
    
    /// Returns the maximum absorption time of all absorption blocks (i.e., the absorption time of the last block).
    /// - Returns: Nil if the absorption scheme has no absorption blocks (should not happen), otherwise the maximum absorption time.
    func getMaximumAbsorptionTime() -> Int? {
        if absorptionBlockVMs.count > 0 {
            return Int(absorptionBlockVMs[absorptionBlockVMs.count - 1].absorptionTime)
        } else {
            return nil
        }
    }
    
    /// Returns the maximum FPUs of the absorption scheme (i.e., the maxFPU value of the last block).
    /// - Returns: Nil if the absorption scheme has no absorption blocks (should not happen), otherwise the maximum of the maxFPU values.
    func getMaximumFPUs() -> Int? {
        if absorptionBlockVMs.count > 0 {
            return Int(absorptionBlockVMs[absorptionBlockVMs.count - 1].maxFpu)
        } else {
            return nil
        }
    }
    
    private func loadDefaultAbsorptionBlocks(errorMessage: inout String) -> Bool {
        // Absorption blocks are empty, so initialize with default absorption scheme
        guard let defaultAbsorptionBlocks = DataHelper.loadDefaultAbsorptionBlocks(errorMessage: &errorMessage) else {
            return false
        }
        
        // Create absorption blocks from default absorption block, which will store it back to Core Data
        for absorptionBlock in defaultAbsorptionBlocks {
            absorptionBlockVMs.append(AbsorptionBlockViewModel(from: absorptionBlock))
        }
        
        return true
    }
    
    static func sampleData() -> AbsorptionSchemeViewModel {
        let absorptionScheme = AbsorptionSchemeViewModel()
        var alert: SimpleAlertType?
        absorptionScheme.absorptionBlockVMs.append(AbsorptionBlockViewModel(maxFpuAsString: "1", absorptionTimeAsString: "3", activeAlert: &alert)!)
        absorptionScheme.absorptionBlockVMs.append(AbsorptionBlockViewModel(maxFpuAsString: "2", absorptionTimeAsString: "4", activeAlert: &alert)!)
        absorptionScheme.absorptionBlockVMs.append(AbsorptionBlockViewModel(maxFpuAsString: "3", absorptionTimeAsString: "5", activeAlert: &alert)!)
        absorptionScheme.absorptionBlockVMs.append(AbsorptionBlockViewModel(maxFpuAsString: "4", absorptionTimeAsString: "6", activeAlert: &alert)!)
        absorptionScheme.absorptionBlockVMs.append(AbsorptionBlockViewModel(maxFpuAsString: "6", absorptionTimeAsString: "8", activeAlert: &alert)!)
        return absorptionScheme
    }
}
