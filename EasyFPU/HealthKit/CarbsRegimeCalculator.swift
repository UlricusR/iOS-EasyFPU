//
//  CarbsEntries.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 10.09.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation
import HealthKit

class CarbsRegimeCalculator: ObservableObject {
    
    // MARK: - Variables required by the HealthKit data model
    
    @Published var hkObjects: [HKObject]
    var sugarsEntries: [Date: CarbsEntry]
    var carbsEntries: [Date: CarbsEntry]
    var eCarbsEntries: [Date: CarbsEntry]
    @Published var includeECarbs: Bool {
        didSet {
            recalculate()
        }
    }
    @Published var includeTotalMealCarbs: Bool {
        didSet {
            recalculate()
        }
    }
    @Published var includeTotalMealSugars: Bool {
        didSet {
            recalculate()
        }
    }
    var composedFoodItem: ComposedFoodItem
    var eCarbsAbsorptionTimeInMinutes: Int
    
    // Parameters that change every time the carbs regime is changed by the user (e.g. include sugars, exclude carbs, etc.)
    // We set these to default values, but need give them proper values in the initializer / in the setParameters function
    var now = Date()
    private var globalStartTime = Date()
    private var globalEndTime = Date()
    private var intervalInMinutes: Int = 0
    var sugarsStart = Date()
    var carbsStart = Date()
    var eCarbsStart = Date()
    @Published var carbsRegime: CarbsRegime = CarbsRegime.default
    
    // MARK: - Initializers
    
    init(composedFoodItem: ComposedFoodItem, eCarbsAbsorptionTimeInHours: Int, includeSugars: Bool, includeTotalMealCarbs: Bool, includeECarbs: Bool) {
        self.hkObjects = [HKObject]()
        self.sugarsEntries = [Date: CarbsEntry]()
        self.carbsEntries = [Date: CarbsEntry]()
        self.eCarbsEntries = [Date: CarbsEntry]()
        self.composedFoodItem = composedFoodItem
        self.includeTotalMealSugars = includeSugars
        self.includeTotalMealCarbs = includeTotalMealCarbs
        self.includeECarbs = includeECarbs
        self.eCarbsAbsorptionTimeInMinutes = eCarbsAbsorptionTimeInHours * 60
        
        // Determine parameters
        self.setParameters()
    }
    
    // MARK: - General functions
    
    func recalculate() {
        // First recalculate the HealthKit data model
        hkObjects.removeAll()
        sugarsEntries.removeAll()
        carbsEntries.removeAll()
        eCarbsEntries.removeAll()
        
        // Determine parameters
        setParameters()
    }
    
    // MARK: - Functions for calculating the HealthKit information
    
    private func setParameters() {
        now = Date()
        let mealStartTime = now.addingTimeInterval(TimeInterval(UserSettings.shared.mealDelayInMinutes * 60))
        
        // Determine global start and end time
        globalStartTime = now // Start is always now, as we want to visualize the idle time before any carbs hit the body
        globalEndTime = max(
            mealStartTime.addingTimeInterval(includeTotalMealSugars ? (Double(UserSettings.shared.absorptionTimeSugarsDelayInMinutes) + UserSettings.shared.absorptionTimeSugarsDurationInHours * 60) * 60 : 0), // either sugars start + duration or zero
            mealStartTime.addingTimeInterval(includeTotalMealCarbs ? (Double(UserSettings.shared.absorptionTimeCarbsDelayInMinutes) + UserSettings.shared.absorptionTimeCarbsDurationInHours * 60) * 60 : 0), // either carbs start + duration or zero
            mealStartTime.addingTimeInterval(includeECarbs ? TimeInterval((UserSettings.shared.absorptionTimeECarbsDelayInMinutes + eCarbsAbsorptionTimeInMinutes) * 60) : 0) // either eCarbs start + duration or zero
        )
        intervalInMinutes = DataHelper.gcd([UserSettings.shared.absorptionTimeSugarsIntervalInMinutes, UserSettings.shared.absorptionTimeCarbsIntervalInMinutes, UserSettings.shared.absorptionTimeECarbsIntervalInMinutes])
        
        sugarsStart = mealStartTime.addingTimeInterval(TimeInterval(UserSettings.shared.absorptionTimeSugarsDelayInMinutes * 60))
        carbsStart = mealStartTime.addingTimeInterval(TimeInterval(UserSettings.shared.absorptionTimeCarbsDelayInMinutes * 60))
        eCarbsStart = mealStartTime.addingTimeInterval(TimeInterval(UserSettings.shared.absorptionTimeECarbsDelayInMinutes * 60))
        
        if includeTotalMealSugars { calculateTotalMealSugars() }
        if includeTotalMealCarbs { calculateTotalMealCarbs() }
        if includeECarbs { calculateECarbs() }
        
        // Then fit the chart bars
        carbsRegime = CarbsRegime(globalStartTime: self.globalStartTime, globalEndTime: self.globalEndTime, intervalInMinutes: self.intervalInMinutes, sugarsEntries: self.sugarsEntries, carbsEntries: self.carbsEntries, eCarbsEntries: self.eCarbsEntries)
    }
    
    private func calculateTotalMealSugars() {
        if includeTotalMealSugars {
            // Make sure to not go below 1 for number sugars entries, otherwise we'd increase sugars amount in the next step
            let numberOfSugarsEntries = max(Int(UserSettings.shared.absorptionTimeSugarsDurationInHours * 60) / UserSettings.shared.absorptionTimeSugarsIntervalInMinutes, 1)
            let totalSugars = composedFoodItem.sugars(treatSugarsSeparately: UserSettings.shared.treatSugarsSeparately)
            calculateXCarbs(
                xCarbsEntries: &self.sugarsEntries,
                numberOfXCarbsEntries: numberOfSugarsEntries,
                totalXCarbs: totalSugars,
                xCarbsStart: sugarsStart,
                xCarbsEnd: sugarsStart.addingTimeInterval(UserSettings.shared.absorptionTimeSugarsDurationInHours * 60 * 60),
                xCarbsType: .sugars,
                timeIntervalInMinutes: UserSettings.shared.absorptionTimeSugarsIntervalInMinutes
            )
        }
    }
    
    private func calculateTotalMealCarbs() {
        if includeTotalMealCarbs {
            // Make sure to not go below 1 for number carb entries, otherwise we'd increase carbs amount in the next step
            let numberOfCarbEntries = max(Int(UserSettings.shared.absorptionTimeCarbsDurationInHours * 60) / UserSettings.shared.absorptionTimeCarbsIntervalInMinutes, 1)
            let totalCarbs = composedFoodItem.regularCarbs(treatSugarsSeparately: UserSettings.shared.treatSugarsSeparately)
            calculateXCarbs(
                xCarbsEntries: &self.carbsEntries,
                numberOfXCarbsEntries: numberOfCarbEntries,
                totalXCarbs: totalCarbs,
                xCarbsStart: carbsStart,
                xCarbsEnd: carbsStart.addingTimeInterval(UserSettings.shared.absorptionTimeCarbsDurationInHours * 60 * 60),
                xCarbsType: .carbs,
                timeIntervalInMinutes: UserSettings.shared.absorptionTimeCarbsIntervalInMinutes
            )
        }
    }
    
    private func calculateECarbs() {
        if includeECarbs {
            // Make sure to not go below 1 for number carb entries, otherwise we'd increase e-carbs amount in the next step
            let numberOfECarbEntries = max(eCarbsAbsorptionTimeInMinutes / UserSettings.shared.absorptionTimeECarbsIntervalInMinutes, 1)
            let totalECarbs = composedFoodItem.fpus.getExtendedCarbs()
            calculateXCarbs(
                xCarbsEntries: &self.eCarbsEntries,
                numberOfXCarbsEntries: numberOfECarbEntries,
                totalXCarbs: totalECarbs,
                xCarbsStart: eCarbsStart,
                xCarbsEnd: eCarbsStart.addingTimeInterval(TimeInterval(eCarbsAbsorptionTimeInMinutes * 60)),
                xCarbsType: .eCarbs,
                timeIntervalInMinutes: UserSettings.shared.absorptionTimeECarbsIntervalInMinutes
            )
        }
    }
    
    private func calculateXCarbs(xCarbsEntries: inout [Date: CarbsEntry], numberOfXCarbsEntries: Int, totalXCarbs: Double, xCarbsStart: Date, xCarbsEnd: Date, xCarbsType: CarbsEntryType, timeIntervalInMinutes: Int) {
        // Generate numberOfECarbEntries, but omit the last one, as it needs to be corrected using the total amount of e-carbs
        // in order to get the exact amount of total e-carbs
        let xCarbsAmount = totalXCarbs / Double(numberOfXCarbsEntries)
        var time = xCarbsStart
        var totalCarbs = 0.0
        repeat {
            let entries = generateEntries(amount: xCarbsAmount, time: time, type: xCarbsType)
            self.hkObjects.append(entries.hkObject)
            xCarbsEntries[time] = entries.carbsEntry
            
            time = time.addingTimeInterval(TimeInterval(timeIntervalInMinutes * 60))
            totalCarbs += xCarbsAmount
        } while time < xCarbsEnd.addingTimeInterval(-TimeInterval(timeIntervalInMinutes * 60))
        
        // Now determine the final amount of e-carbs and generate the final entry
        let finalAmountOfXCarbs = totalXCarbs - totalCarbs
        if finalAmountOfXCarbs > 0 {
            let entries = generateEntries(amount: finalAmountOfXCarbs, time: time, type: xCarbsType)
            self.hkObjects.append(entries.hkObject)
            xCarbsEntries[time] = entries.carbsEntry
        }
    }
    
    private func generateEntries(amount: Double, time: Date, type: CarbsEntryType) -> (hkObject: HKObject, carbsEntry: CarbsEntry) {
        let hkObject = HealthDataHelper.processQuantitySample(value: amount, unit: HealthDataHelper.unitCarbs, start: time, end: time, sampleType: HealthDataHelper.objectTypeCarbs)
        let xCarbsEntry = CarbsEntry(type: type, value: amount, date: time)
        return (hkObject, xCarbsEntry)
    }
}
