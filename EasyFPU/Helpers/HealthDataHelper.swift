//
//  HealthKitHelper.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 07.09.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation
import HealthKit

class HealthDataHelper {
    static private var healthStore: HKHealthStore = HKHealthStore()
    static var errorMessage: String?
    
    // MARK: - Authorization
    
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
    
    private static let objectTypeCarbs = HKObjectType.quantityType(forIdentifier: .dietaryCarbohydrates)!
    private static let objectTypeCalories = HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
    
    static func requestHealthDataAccessIfNeeded(completion: @escaping (_ success: Bool) -> Void) {
        requestHealthDataAccessIfNeeded(toShare: Set([objectTypeCarbs, objectTypeCalories]), read: nil, completion: completion)
    }
    
    static func processHealthSample(
        for meal: MealViewModel,
        with absorptionScheme: AbsorptionScheme,
        exportECarbs: Bool,
        exportTotalMealCarbs: Bool,
        exportTotalMealCalories: Bool,
        delayInMinutes: Double,
        intervalInMinutes: Double,
        errorMessage: inout String
    ) -> [HKObject]? {
        var hkObjects = [HKObject]()
        let unitCarbs = HKUnit.gram()
        let now = Date()
        
        if exportECarbs {
            guard let absorptionTimeInHours = meal.fpus.getAbsorptionTime(absorptionScheme: absorptionScheme) else {
                errorMessage = NSLocalizedString("Fatal error, cannot export data, please contact the app developer: Absorption Scheme has no Absorption Blocks", comment: "")
                return nil
            }
            let absorptionTimeInMinutes = Double(absorptionTimeInHours) * 60.0
            let start = now.addingTimeInterval(delayInMinutes * 60.0)
            let end = start.addingTimeInterval(absorptionTimeInMinutes * 60.0)
            
            // Make sure to not go below 1 for number carb entries, otherwise we'd increase e-carbs amount in the next step
            let numberOfECarbEntries = max(absorptionTimeInMinutes / intervalInMinutes, 1.0)
            let eCarbsAmount = meal.fpus.getExtendedCarbs() / numberOfECarbEntries
            
            // Generate numberOfECarbEntries, but omit the last one, as it needs to be corrected using the total amount of e-carbs
            // in order to get the exact amount of total e-carbs
            var time = start
            var totalECarbs = 0.0
            repeat {
                hkObjects.append(processQuantitySample(value: eCarbsAmount, unit: unitCarbs, start: time, end: time, sampleType: objectTypeCarbs))
                time = time.addingTimeInterval(intervalInMinutes * 60)
                totalECarbs += eCarbsAmount
            } while time < end.addingTimeInterval(-intervalInMinutes * 60)
            
            // Now determine the final amount of e-carbs and generate the final entry
            let finalAmountOfECarbs = meal.fpus.getExtendedCarbs() - totalECarbs
            if finalAmountOfECarbs > 0 {
                hkObjects.append(processQuantitySample(value: finalAmountOfECarbs, unit: unitCarbs, start: end, end: end, sampleType: objectTypeCarbs))
            }
        }
        
        if exportTotalMealCarbs {
            hkObjects.append(processQuantitySample(value: meal.carbs, unit: unitCarbs, start: now, end: now, sampleType: objectTypeCarbs))
        }
        
        if exportTotalMealCalories {
            hkObjects.append(processQuantitySample(value: meal.calories, unit: HKUnit.kilocalorie(), start: now, end: now, sampleType: objectTypeCalories))
        }
        
        return hkObjects
    }
    
    private static func processQuantitySample(value: Double, unit: HKUnit, start: Date, end: Date, sampleType: HKObjectType) -> HKObject {
        let quantity = HKQuantity(unit: unit, doubleValue: value)
        let hkQuantitySample = HKQuantitySample(type: sampleType as! HKQuantityType, quantity: quantity, start: start, end: end)
        return hkQuantitySample
    }
}
