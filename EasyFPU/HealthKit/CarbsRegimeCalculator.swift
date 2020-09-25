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
    var meal: MealViewModel
    var absorptionTimeInMinutes: Int
    
    
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
    
    // MARK: - Static variables / constants
    
    static let `default` = CarbsRegimeCalculator(
        meal: MealViewModel.default,
        absorptionTimeInHours: 5,
        includeSugars: UserSettings.getValue(for: UserSettings.UserDefaultsBoolKey.exportTotalMealSugars) ?? false,
        includeTotalMealCarbs: UserSettings.getValue(for: UserSettings.UserDefaultsBoolKey.exportTotalMealCarbs) ?? false,
        includeECarbs: UserSettings.getValue(for: UserSettings.UserDefaultsBoolKey.exportECarbs) ?? true
    )
    
    // MARK: - Initializers
    
    init(meal: MealViewModel, absorptionTimeInHours: Int, includeSugars: Bool, includeTotalMealCarbs: Bool, includeECarbs: Bool) {
        self.hkObjects = [HKObject]()
        self.sugarsEntries = [Date: CarbsEntry]()
        self.carbsEntries = [Date: CarbsEntry]()
        self.eCarbsEntries = [Date: CarbsEntry]()
        self.meal = meal
        self.includeTotalMealSugars = includeSugars
        self.includeTotalMealCarbs = includeTotalMealCarbs
        self.includeECarbs = includeECarbs
        self.absorptionTimeInMinutes = absorptionTimeInHours * 60
        
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
        
        self.objectWillChange.send()
        self.carbsRegime.objectWillChange.send()
    }
    
    // MARK: - Functions for calculating the HealthKit information
    
    private func setParameters() {
        now = Date()
        
        // Determine global start and end time
        globalStartTime = now // Start is always now, as we want to visualize the idle time before any carbs hit the body
        globalEndTime = max(
            now.addingTimeInterval(includeTotalMealSugars ? (Double(UserSettings.shared.absorptionTimeSugarsDelayInMinutes) + UserSettings.shared.absorptionTimeSugarsDurationInHours * 60) * 60 : 0), // either sugars start + duration or zero
            now.addingTimeInterval(includeTotalMealCarbs ? (Double(UserSettings.shared.absorptionTimeCarbsDelayInMinutes) + UserSettings.shared.absorptionTimeCarbsDurationInHours * 60) * 60 : 0), // either carbs start + duration or zero
            now.addingTimeInterval(includeECarbs ? TimeInterval((UserSettings.shared.absorptionTimeECarbsDelayInMinutes + absorptionTimeInMinutes) * 60) : 0) // either eCarbs start + duration or zero
        )
        intervalInMinutes = DataHelper.gcd([UserSettings.shared.absorptionTimeSugarsIntervalInMinutes, UserSettings.shared.absorptionTimeCarbsIntervalInMinutes, UserSettings.shared.absorptionTimeECarbsIntervalInMinutes])
        
        sugarsStart = now.addingTimeInterval(TimeInterval(UserSettings.shared.absorptionTimeSugarsDelayInMinutes * 60))
        carbsStart = now.addingTimeInterval(TimeInterval(UserSettings.shared.absorptionTimeCarbsDelayInMinutes * 60))
        eCarbsStart = now.addingTimeInterval(TimeInterval(UserSettings.shared.absorptionTimeECarbsDelayInMinutes * 60))
        
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
            let totalSugars = meal.sugars
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
            let totalCarbs = meal.getRegularCarbs()
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
            let numberOfECarbEntries = max(absorptionTimeInMinutes / UserSettings.shared.absorptionTimeECarbsIntervalInMinutes, 1)
            let totalECarbs = meal.fpus.getExtendedCarbs()
            calculateXCarbs(
                xCarbsEntries: &self.eCarbsEntries,
                numberOfXCarbsEntries: numberOfECarbEntries,
                totalXCarbs: totalECarbs,
                xCarbsStart: eCarbsStart,
                xCarbsEnd: eCarbsStart.addingTimeInterval(TimeInterval(absorptionTimeInMinutes * 60)),
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
