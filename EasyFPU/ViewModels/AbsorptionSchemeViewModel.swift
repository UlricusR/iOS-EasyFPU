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
    private(set) var delay: Double = AbsorptionSchemeViewModel.absorptionTimeLongDelayDefault
    @Published var delayAsString = "" {
        willSet {
            let result = FoodItemViewModel.checkForPositiveDouble(valueAsString: newValue, allowZero: true)
            switch result {
            case .success(let value):
                self.delay = value
            case .failure(let err):
                debugPrint(FoodItemViewModel.getErrorMessage(from: err))
                return
            }
        }
    }
    private(set) var interval: Double = AbsorptionSchemeViewModel.absorptionTimeLongIntervalDefault
    @Published var intervalAsString = "" {
        willSet {
            let result = FoodItemViewModel.checkForPositiveDouble(valueAsString: newValue, allowZero: false)
            switch result {
            case .success(let value):
                self.interval = value
            case .failure(let err):
                debugPrint(FoodItemViewModel.getErrorMessage(from: err))
                return
            }
        }
    }
    
    static let absorptionTimeLongDelayDefault: Double = 90
    static let absorptionTimeLongIntervalDefault: Double = 10
    
    init(from cdAbsorptionScheme: AbsorptionScheme) {
        self.absorptionBlocks = [AbsorptionBlockViewModel]()
        for absorptionBlock in cdAbsorptionScheme.absorptionBlocks {
            self.absorptionBlocks.append(AbsorptionBlockViewModel(from: absorptionBlock))
        }
        
        let delay = UserSettings.getValue(for: UserSettings.UserDefaultsDoubleKey.absorptionTimeLongDelay) ?? AbsorptionSchemeViewModel.absorptionTimeLongDelayDefault
        self.delay = delay
        self.delayAsString = FoodItemViewModel.doubleFormatter(numberOfDigits: 0).string(from: NSNumber(value: delay))!
        
        let interval = UserSettings.getValue(for: UserSettings.UserDefaultsDoubleKey.absorptionTimeLongInterval) ?? AbsorptionSchemeViewModel.absorptionTimeLongIntervalDefault
        self.interval = interval
        self.intervalAsString = FoodItemViewModel.doubleFormatter(numberOfDigits: 0).string(from: NSNumber(value: interval))!
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
