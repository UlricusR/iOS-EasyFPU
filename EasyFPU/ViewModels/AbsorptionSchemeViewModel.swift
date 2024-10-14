//
//  AbsorptionSchemeViewModel.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 30.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class AbsorptionSchemeViewModel: ObservableObject {
    @Published var absorptionBlocks: [AbsorptionBlockViewModel]
    var cdAbsorptionScheme: AbsorptionScheme
    
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
    
    init(from cdAbsorptionScheme: AbsorptionScheme) {
        self.cdAbsorptionScheme = cdAbsorptionScheme
        self.absorptionBlocks = [AbsorptionBlockViewModel]()
        for absorptionBlock in cdAbsorptionScheme.absorptionBlocks {
            let newAbsorptionBlockViewModel = AbsorptionBlockViewModel(from: absorptionBlock)
            if !self.absorptionBlocks.contains(newAbsorptionBlockViewModel) {
                self.absorptionBlocks.append(AbsorptionBlockViewModel(from: absorptionBlock))
            }
        }
        
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
