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
    
    class func requestHealthDataAccessIfNeeded(toShare shareTypes: Set<HKSampleType>?,
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
                debugPrint("requestAuthorization error:", error.localizedDescription)
            }
            
            if success {
                debugPrint("HealthKit authorization request was successful!")
            } else {
                debugPrint("HealthKit authorization was not successful.")
            }
            
            completion(success)
        }
    }
    
    // MARK: - HKHealthStore
    
    class func saveHealthData(_ data: [HKObject], completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        healthStore.save(data, withCompletion: completion)
    }
}
