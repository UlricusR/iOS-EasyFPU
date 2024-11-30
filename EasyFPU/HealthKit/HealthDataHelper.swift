//
//  HealthKitHelper.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 07.09.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation
import HealthKit

struct HealthDataHelper {
    static private var healthStore: HKHealthStore = HKHealthStore()
    static var errorMessage: String?
    
    // MARK: - Authorization
    
    static func healthKitIsAvailable() -> Bool {
        HKHealthStore.isHealthDataAvailable()
    }
    
    private static func requestHealthDataAccessIfNeeded(toShare shareTypes: Set<HKSampleType>?,
                                               read readTypes: Set<HKObjectType>?,
                                               completion: @escaping (_ success: Bool) -> Void) {
        if !HKHealthStore.isHealthDataAvailable() {
            debugPrint("Cannot write data: HealthKit seem not to be available on your device.")
            errorMessage = NSLocalizedString("Cannot write data: HealthKit seem not to be available on your device.", comment: "")
            completion(false)
        }
        
        debugPrint("Requesting HealthKit authorization...")
        healthStore.requestAuthorization(toShare: shareTypes, read: readTypes) { (success, error) in
            if let error = error {
                errorMessage = NSLocalizedString("Error requesting authorization to write to Health: ", comment: "") + error.localizedDescription
                debugPrint(errorMessage!)
            }
            
            if success {
                debugPrint("HealthKit authorization request was successful!")
            } else {
                debugPrint("HealthKit authorization was not successful.")
            }
            
            completion(success)
        }
    }
    
    // MARK: - Generic HKHealthStore
    
    static func saveHealthData(_ data: [HKObject], completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        healthStore.save(data, withCompletion: completion)
    }
    
    // MARK: - Meal specific export functions
    
    static let objectTypeCarbs = HKObjectType.quantityType(forIdentifier: .dietaryCarbohydrates)!
    static let objectTypeCalories = HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
    static let unitCarbs = HKUnit.gram()
    static let unitCalories = HKUnit.kilocalorie()
    
    static func requestHealthDataAccessIfNeeded(completion: @escaping (_ success: Bool) -> Void) {
        requestHealthDataAccessIfNeeded(toShare: Set([objectTypeCarbs, objectTypeCalories]), read: nil, completion: completion)
    }
    
    static func processQuantitySample(value: Double, unit: HKUnit, start: Date, end: Date, sampleType: HKObjectType) -> HKObject {
        let quantity = HKQuantity(unit: unit, doubleValue: value)
        let hkQuantitySample = HKQuantitySample(type: sampleType as! HKQuantityType, quantity: quantity, start: start, end: end)
        return hkQuantitySample
    }
}
