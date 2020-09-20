//
//  CarbsEntries.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 10.09.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation
import HealthKit

class CarbsRegime: ObservableObject {
    
    // MARK: - Variables required by the HealthKit data model
    
    @Published var hkObjects: [HKObject]
    var sugarEntries: [Date: CarbsEntry]
    var carbsEntries: [Date: CarbsEntry]
    var eCarbEntries: [Date: CarbsEntry]
    var carbsRegime = [Date: [CarbsEntry]]()
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
    
    private var now: Date
    private var eCarbsStart: Date
    private var carbsStart: Date
    
    // MARK: - Variables required for fitting the chart
    
    var requiresBarSplitting = false
    var maxCarbsWithoutSplitting = 0.0 // The amount of carbs above which splitting of the bar is required
    var regularMultiplier = 0.0
    var appliedMultiplier = 0.0
    var theoreticalMaxBarHeight = 0.0
    var timeSplittingAfterIndex = 0
    
    let previewHeight = 120.0
    private let barMinHeight = 20.0
    
    // MARK: - Static variables / constants
    
    static let `default` = CarbsRegime(
        meal: MealViewModel.default,
        absorptionTimeInHours: 5,
        includeSugars: UserSettings.getValue(for: UserSettings.UserDefaultsBoolKey.exportTotalMealSugars) ?? false,
        includeTotalMealCarbs: UserSettings.getValue(for: UserSettings.UserDefaultsBoolKey.exportTotalMealCarbs) ?? false,
        includeECarbs: UserSettings.getValue(for: UserSettings.UserDefaultsBoolKey.exportECarbs) ?? true
    )
    
    // MARK: - Initializers
    
    init(meal: MealViewModel, absorptionTimeInHours: Int, includeSugars: Bool, includeTotalMealCarbs: Bool, includeECarbs: Bool) {
        self.hkObjects = [HKObject]()
        self.sugarEntries = [Date: CarbsEntry]()
        self.carbsEntries = [Date: CarbsEntry]()
        self.eCarbEntries = [Date: CarbsEntry]()
        self.meal = meal
        self.includeTotalMealSugars = includeSugars
        self.includeECarbs = includeECarbs
        self.includeTotalMealCarbs = includeTotalMealCarbs
        
        self.now = Date()
        
        self.absorptionTimeInMinutes = absorptionTimeInHours * 60
        self.eCarbsStart = now.addingTimeInterval(TimeInterval(UserSettings.shared.absorptionTimeLongDelayInMinutes * 60))
        self.carbsStart = now.addingTimeInterval(TimeInterval(UserSettings.shared.absorptionTimeMediumDelayInMinutes * 60))
        
        if includeSugars { calculateTotalMealSugars() }
        if includeTotalMealCarbs { calculateTotalMealCarbs() }
        if includeECarbs { calculateECarbs() }
        
        // Then fit the chart bars
        fitCarbChartBars()
        carbsRegime = getCarbRegime()
    }
    
    // MARK: - General functions
    
    func recalculate() {
        // First recalculate the HealthKit data model
        hkObjects.removeAll()
        sugarEntries.removeAll()
        carbsEntries.removeAll()
        eCarbEntries.removeAll()
        now = Date()
        carbsStart = now.addingTimeInterval(TimeInterval(UserSettings.shared.absorptionTimeMediumDelayInMinutes * 60))
        eCarbsStart = now.addingTimeInterval(TimeInterval(UserSettings.shared.absorptionTimeLongDelayInMinutes * 60))
        
        if includeTotalMealSugars { calculateTotalMealSugars() }
        if includeTotalMealCarbs { calculateTotalMealCarbs() }
        if includeECarbs { calculateECarbs() }
        
        // Then fit the chart bars
        fitCarbChartBars()
        carbsRegime = getCarbRegime()
        
        self.objectWillChange.send()
    }
    
    // MARK: - Functions for calculating the HealthKit information
    
    private func calculateTotalMealSugars() {
        if includeTotalMealSugars {
            let entries = generateEntries(amount: meal.sugars, time: now, type: .sugars)
            self.hkObjects.append(entries.hkObject)
            sugarEntries[now] = entries.carbsEntry
        }
    }
    
    private func calculateTotalMealCarbs() {
        if includeTotalMealCarbs {
            // Make sure to not go below 1 for number carb entries, otherwise we'd increase carbs amount in the next step
            let numberOfCarbEntries = max(Int(UserSettings.shared.absorptionTimeMediumDurationInHours * 60) / UserSettings.shared.absorptionTimeMediumIntervalInMinutes, 1)
            let totalCarbs = meal.getRegularCarbs()
            calculateXCarbs(
                xCarbsEntries: &self.carbsEntries,
                numberOfXCarbsEntries: numberOfCarbEntries,
                totalXCarbs: totalCarbs,
                xCarbsStart: carbsStart,
                xCarbsEnd: carbsStart.addingTimeInterval(UserSettings.shared.absorptionTimeMediumDurationInHours * 60 * 60),
                xCarbsType: .carbs,
                timeIntervalInMinutes: UserSettings.shared.absorptionTimeMediumIntervalInMinutes
            )
        }
    }
    
    private func calculateECarbs() {
        if includeECarbs {
            // Make sure to not go below 1 for number carb entries, otherwise we'd increase e-carbs amount in the next step
            let numberOfECarbEntries = max(absorptionTimeInMinutes / UserSettings.shared.absorptionTimeLongIntervalInMinutes, 1)
            let totalECarbs = meal.fpus.getExtendedCarbs()
            calculateXCarbs(
                xCarbsEntries: &self.eCarbEntries,
                numberOfXCarbsEntries: numberOfECarbEntries,
                totalXCarbs: totalECarbs,
                xCarbsStart: eCarbsStart,
                xCarbsEnd: eCarbsStart.addingTimeInterval(TimeInterval(absorptionTimeInMinutes * 60)),
                xCarbsType: .eCarbs,
                timeIntervalInMinutes: UserSettings.shared.absorptionTimeLongIntervalInMinutes
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
            time = time.addingTimeInterval(TimeInterval(timeIntervalInMinutes * 60))
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
    
    // MARK: - Functions for caluclating the carbs regime
    
    private func getCarbRegime() -> [Date: [CarbsEntry]] {
        var carbsRegime = [Date: [CarbsEntry]]()
        
        // Determine min interval from carbs and eCarbs, global start and end time
        let intervalInMinutes = gcdRecursiveEuklid(UserSettings.shared.absorptionTimeMediumIntervalInMinutes, UserSettings.shared.absorptionTimeLongIntervalInMinutes)
        let globalStartTime = now // Start is always now, as we want to visualize the idle time before any carbs hit the body
        let globalEndTime = max(now.addingTimeInterval(
            includeTotalMealCarbs ? (Double(UserSettings.shared.absorptionTimeMediumDelayInMinutes) + UserSettings.shared.absorptionTimeMediumDurationInHours * 60) * 60 : 0 // either carbs start + duration or zero
        ), now.addingTimeInterval(
            includeECarbs ? TimeInterval((UserSettings.shared.absorptionTimeLongDelayInMinutes + absorptionTimeInMinutes) * 60) : 0 // either eCarbs start + duration or zero
        ))
        
        // Iterate through sugar/carbs/eCarbs entries and put together the total regime
        
        
        // The first entry is either the total meal carbs or zero, if e-carbs are included
        if includeTotalMealCarbs {
            carbsRegime.append((now, meal.getRegularCarbs()))
        } else if includeECarbs {
            carbsRegime.append((now, 0.0))
        }
        
        if includeECarbs {
            // Append the delay entries
            let numberOfDelaySegments = Int((UserSettings.shared.absorptionTimeLongDelay / UserSettings.shared.absorptionTimeLongInterval).rounded(.up)) - 1
            if numberOfDelaySegments <= 3 {
                // We don't need to split the x axis, as there are sufficiently few delay segments
                timeSplittingAfterIndex = -1
                if numberOfDelaySegments > 0 {
                    for index in (1...numberOfDelaySegments) {
                        carbsRegime.append((now.addingTimeInterval(UserSettings.shared.absorptionTimeLongInterval * Double(index) * 60), 0.0))
                    }
                }
            } else {
                // We need to split the time axis
                timeSplittingAfterIndex = 1
                
                // Add one delay segment after the total meal carbs, one before e-carbs entries start
                carbsRegime.append((now.addingTimeInterval(UserSettings.shared.absorptionTimeLongInterval * 60), 0.0))
                carbsRegime.append((eCarbsStart.addingTimeInterval(-UserSettings.shared.absorptionTimeLongInterval * 60), 0.0))
            }
            
            // Append the e-carbs entries
            for index in (0..<eCarbEntries.count) {
                carbsRegime.append((eCarbsStart.addingTimeInterval(UserSettings.shared.absorptionTimeLongInterval * Double(index) * 60), eCarbEntries[index]))
            }
        } else {
            timeSplittingAfterIndex = -1
        }
        
        return carbsRegime
    }
    
    private func getMinMaxCarbs() -> (min: Double, max: Double) {
        var minDouble = includeTotalMealCarbs ? meal.getRegularCarbs() : 0
        var maxDouble = includeTotalMealCarbs ? meal.getRegularCarbs() : 0
        
        if includeECarbs {
            for entry in eCarbEntries {
                minDouble = minDouble == 0 ? entry : min(minDouble, entry)
                maxDouble = max(maxDouble, entry)
            }
        }
        
        return (minDouble, maxDouble)
    }
    
    func gcdRecursiveEuklid(_ m: Int, _ n: Int) -> Int {
        let r: Int = m % n
        if r != 0 {
            return gcdRecursiveEuklid(n, r)
        } else {
            return n
        }
    }
    
    // MARK: - Functions for fitting the chart
    
    func fitCarbChartBars() {
        if includeTotalMealCarbs || includeECarbs { // We only need this if carbs are selected
            let minMaxCarbs = getMinMaxCarbs()
            regularMultiplier = previewHeight / minMaxCarbs.max
            
            if minMaxCarbs.min * regularMultiplier < barMinHeight {
                // We need to split some bars
                requiresBarSplitting = true
                theoreticalMaxBarHeight = regularMultiplier * minMaxCarbs.max
                maxCarbsWithoutSplitting = previewHeight / barMinHeight
                appliedMultiplier = barMinHeight / minMaxCarbs.min
            } else {
                requiresBarSplitting = false
                theoreticalMaxBarHeight = regularMultiplier * minMaxCarbs.min
                maxCarbsWithoutSplitting = minMaxCarbs.max
                appliedMultiplier = regularMultiplier
            }
        }
    }
    
    func getSplitBarHeight(carbs: Double) -> Double {
        previewHeight - (theoreticalMaxBarHeight - carbs * regularMultiplier)
    }
}
