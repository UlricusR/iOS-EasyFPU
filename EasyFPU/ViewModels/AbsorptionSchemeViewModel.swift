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
    
    // Absorption block parameters for carbs
    private(set) var delayMedium: Double = AbsorptionSchemeViewModel.absorptionTimeMediumDelayDefault
    @Published var delayMediumAsString = "" {
        willSet {
            let result = DataHelper.checkForPositiveDouble(valueAsString: newValue, allowZero: true)
            switch result {
            case .success(let value):
                self.delayMedium = value
            case .failure(let err):
                debugPrint(DataHelper.getErrorMessage(from: err))
                return
            }
        }
    }
    private(set) var intervalMedium: Double = AbsorptionSchemeViewModel.absorptionTimeMediumIntervalDefault
    @Published var intervalMediumAsString = "" {
        willSet {
            let result = DataHelper.checkForPositiveDouble(valueAsString: newValue, allowZero: false)
            switch result {
            case .success(let value):
                self.intervalMedium = value
            case .failure(let err):
                debugPrint(DataHelper.getErrorMessage(from: err))
                return
            }
        }
    }
    private(set) var durationMedium: Double = AbsorptionSchemeViewModel.absoprtionTimeMediumDurationDefault
    @Published var durationMediumAsString = "" {
        willSet {
            let result = DataHelper.checkForPositiveDouble(valueAsString: newValue, allowZero: false)
            switch result {
            case .success(let value):
                self.durationMedium = value
            case .failure(let err):
                debugPrint(DataHelper.getErrorMessage(from: err))
                return
            }
        }
    }
    
    // Absorption block parameters for e-Carbs
    private(set) var delayLong: Double = AbsorptionSchemeViewModel.absorptionTimeLongDelayDefault
    @Published var delayLongAsString = "" {
        willSet {
            let result = DataHelper.checkForPositiveDouble(valueAsString: newValue, allowZero: true)
            switch result {
            case .success(let value):
                self.delayLong = value
            case .failure(let err):
                debugPrint(DataHelper.getErrorMessage(from: err))
                return
            }
        }
    }
    private(set) var intervalLong: Double = AbsorptionSchemeViewModel.absorptionTimeLongIntervalDefault
    @Published var intervalLongAsString = "" {
        willSet {
            let result = DataHelper.checkForPositiveDouble(valueAsString: newValue, allowZero: false)
            switch result {
            case .success(let value):
                self.intervalLong = value
            case .failure(let err):
                debugPrint(DataHelper.getErrorMessage(from: err))
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
                debugPrint(DataHelper.getErrorMessage(from: err))
                return
            }
        }
    }
    
    static let absorptionTimeMediumDelayDefault: Double = 5 // minutes
    static let absorptionTimeMediumIntervalDefault: Double = 5 // minutes
    static let absoprtionTimeMediumDurationDefault: Double = 3 // hours
    static let absorptionTimeLongDelayDefault: Double = 90 // minutes
    static let absorptionTimeLongIntervalDefault: Double = 10 // minutes
    static let eCarbsFactorDefault: Double = 10 // g e-carbs per FPU
    
    init(from cdAbsorptionScheme: AbsorptionScheme) {
        self.absorptionBlocks = [AbsorptionBlockViewModel]()
        for absorptionBlock in cdAbsorptionScheme.absorptionBlocks {
            let newAbsorptionBlockViewModel = AbsorptionBlockViewModel(from: absorptionBlock)
            if !self.absorptionBlocks.contains(newAbsorptionBlockViewModel) {
                self.absorptionBlocks.append(AbsorptionBlockViewModel(from: absorptionBlock))
            }
        }
        
        let delayMedium = UserSettings.shared.absorptionTimeMediumDelay
        self.delayMedium = delayMedium
        self.delayMediumAsString = DataHelper.doubleFormatter(numberOfDigits: 0).string(from: NSNumber(value: delayMedium))!
        
        let intervalMedium = UserSettings.shared.absorptionTimeMediumInterval
        self.intervalMedium = intervalMedium
        self.intervalMediumAsString = DataHelper.doubleFormatter(numberOfDigits: 0).string(from: NSNumber(value: intervalMedium))!
        
        let durationMedium = UserSettings.shared.absorptionTimeMediumDuration
        self.intervalMedium = durationMedium
        self.durationMediumAsString = DataHelper.doubleFormatter(numberOfDigits: 0).string(from: NSNumber(value: durationMedium))!
        
        let delayLong = UserSettings.shared.absorptionTimeLongDelay
        self.delayLong = delayLong
        self.delayLongAsString = DataHelper.doubleFormatter(numberOfDigits: 0).string(from: NSNumber(value: delayLong))!
        
        let intervalLong = UserSettings.getValue(for: UserSettings.UserDefaultsDoubleKey.absorptionTimeLongInterval) ?? AbsorptionSchemeViewModel.absorptionTimeLongIntervalDefault
        self.intervalLong = intervalLong
        self.intervalLongAsString = DataHelper.doubleFormatter(numberOfDigits: 0).string(from: NSNumber(value: intervalLong))!
        
        let eCarbsFactor = UserSettings.getValue(for: UserSettings.UserDefaultsDoubleKey.eCarbsFactor) ?? AbsorptionSchemeViewModel.eCarbsFactorDefault
        self.eCarbsFactor = eCarbsFactor
        self.eCarbsFactorAsString = DataHelper.doubleFormatter(numberOfDigits: 0).string(from: NSNumber(value: eCarbsFactor))!
    }
    
    func add(newAbsorptionBlock: AbsorptionBlockViewModel, errorMessage: inout String) -> Bool {
        // Check no. 1: If the list only has one element, then everything is fine, as the new block is the first one
        if absorptionBlocks.count == 0 {
            absorptionBlocks.append(newAbsorptionBlock)
            return true
        }

        // Check no. 2: There are existing blocks, so we must check to not have identical maxFPU values
        for absorptionBlock in absorptionBlocks {
            if absorptionBlock.maxFpu == newAbsorptionBlock.maxFpu {
                // Duplicate maxFPU values not allowed
                errorMessage = NSLocalizedString("Maximum FPU value already exists", comment: "")
                return false
            }
        }

        // Now we're sure the new maxFPU is not identical, therefore we add new absorption block and sort
        absorptionBlocks.append(newAbsorptionBlock)
        absorptionBlocks = absorptionBlocks.sorted()

        // Check no. 3: The absorption block before the new one must have a lower, the one after a higher absorption time
        guard let newBlockIndex = absorptionBlocks.firstIndex(of: newAbsorptionBlock) else {
            // This should never happen
            errorMessage = NSLocalizedString("Fatal error: Cannot determine absorption block index, please inform the app developer", comment: "")
            return false
        }

        // Case 3a: It's the first element, so just check the block after -
        // we have already excluded the case that the new block is the only element in check no. 1!
        if newBlockIndex == 0 {
            if newAbsorptionBlock.absorptionTime >= absorptionBlocks[1].absorptionTime {
                // Error: The new block's absorption time is equals or larger than of the one after
                absorptionBlocks.remove(at: newBlockIndex)
                errorMessage = NSLocalizedString("Absorption time is equals or larger than the one of the following absorption block", comment: "")
                return false
            } else {
                return true
            }
        }

        // Case 3b: It's the last element, so just check the block before
        if newBlockIndex == absorptionBlocks.count - 1 {
            if newAbsorptionBlock.absorptionTime <= absorptionBlocks[absorptionBlocks.count - 2].absorptionTime {
                // Error: The new block's absorption time is equals or less than of the one before
                absorptionBlocks.remove(at: newBlockIndex)
                errorMessage = NSLocalizedString("Absorption time is equals or less than the one of the block before", comment: "")
                return false
            } else {
                return true
            }
        }

        // Case 3c: It's somewhere in the middle
        if !(newAbsorptionBlock.absorptionTime > absorptionBlocks[newBlockIndex - 1].absorptionTime &&
              newAbsorptionBlock.absorptionTime < absorptionBlocks[newBlockIndex + 1].absorptionTime) {
            absorptionBlocks.remove(at: newBlockIndex)
            errorMessage = NSLocalizedString("Absorption time must be between previous and following block", comment: "")
            return false
        } else {
            return true
        }
    }
}
