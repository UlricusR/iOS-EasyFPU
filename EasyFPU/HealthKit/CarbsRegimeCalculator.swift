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
    @Published var carbsRegime: CarbsRegime = CarbsRegime.default
    
    var now: Date
    var eCarbsStart: Date
    var carbsStart: Date
    private var globalStartTime: Date
    private var globalEndTime: Date
    private var intervalInMinutes: Int
    
    // MARK: - Variables required for fitting the chart
    
    var requiresBarSplitting = false
    var maxCarbsWithoutSplitting = 0.0 // The amount of carbs above which splitting of the bar is required
    var regularMultiplier = 0.0
    var appliedMultiplier = 0.0
    var theoreticalMaxBarHeight = 0.0
    
    let previewHeight = 120.0
    private let barMinHeight = 20.0
    
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
        self.includeECarbs = includeECarbs
        self.includeTotalMealCarbs = includeTotalMealCarbs
        self.absorptionTimeInMinutes = absorptionTimeInHours * 60
        
        self.now = Date()
        
        // Determine global start and end time
        self.globalStartTime = now // Start is always now, as we want to visualize the idle time before any carbs hit the body
        self.globalEndTime = max(now.addingTimeInterval(
            includeTotalMealCarbs ? (Double(UserSettings.shared.absorptionTimeMediumDelayInMinutes) + UserSettings.shared.absorptionTimeMediumDurationInHours * 60) * 60 : 0 // either carbs start + duration or zero
        ), now.addingTimeInterval(
            includeECarbs ? TimeInterval((UserSettings.shared.absorptionTimeLongDelayInMinutes + absorptionTimeInMinutes) * 60) : 0 // either eCarbs start + duration or zero
        ))
        self.intervalInMinutes = DataHelper.gcdRecursiveEuklid(UserSettings.shared.absorptionTimeMediumIntervalInMinutes, UserSettings.shared.absorptionTimeLongIntervalInMinutes)
        
        self.eCarbsStart = now.addingTimeInterval(TimeInterval(UserSettings.shared.absorptionTimeLongDelayInMinutes * 60))
        self.carbsStart = now.addingTimeInterval(TimeInterval(UserSettings.shared.absorptionTimeMediumDelayInMinutes * 60))
        
        if includeSugars { calculateTotalMealSugars() }
        if includeTotalMealCarbs { calculateTotalMealCarbs() }
        if includeECarbs { calculateECarbs() }
        
        // Then fit the chart bars
        fitCarbChartBars()
        carbsRegime = CarbsRegime(globalStartTime: self.globalStartTime, globalEndTime: self.globalEndTime, intervalInMinutes: self.intervalInMinutes, sugarsEntries: self.sugarsEntries, carbsEntries: self.carbsEntries, eCarbsEntries: self.eCarbsEntries)
    }
    
    // MARK: - General functions
    
    func recalculate() {
        // First recalculate the HealthKit data model
        hkObjects.removeAll()
        sugarsEntries.removeAll()
        carbsEntries.removeAll()
        eCarbsEntries.removeAll()
        now = Date()
        
        // Determine global start and end time
        globalStartTime = now // Start is always now, as we want to visualize the idle time before any carbs hit the body
        globalEndTime = max(now.addingTimeInterval(
            includeTotalMealCarbs ? (Double(UserSettings.shared.absorptionTimeMediumDelayInMinutes) + UserSettings.shared.absorptionTimeMediumDurationInHours * 60) * 60 : 0 // either carbs start + duration or zero
        ), now.addingTimeInterval(
            includeECarbs ? TimeInterval((UserSettings.shared.absorptionTimeLongDelayInMinutes + absorptionTimeInMinutes) * 60) : 0 // either eCarbs start + duration or zero
        ))
        intervalInMinutes = DataHelper.gcdRecursiveEuklid(UserSettings.shared.absorptionTimeMediumIntervalInMinutes, UserSettings.shared.absorptionTimeLongIntervalInMinutes)
        
        carbsStart = now.addingTimeInterval(TimeInterval(UserSettings.shared.absorptionTimeMediumDelayInMinutes * 60))
        eCarbsStart = now.addingTimeInterval(TimeInterval(UserSettings.shared.absorptionTimeLongDelayInMinutes * 60))
        
        if includeTotalMealSugars { calculateTotalMealSugars() }
        if includeTotalMealCarbs { calculateTotalMealCarbs() }
        if includeECarbs { calculateECarbs() }
        
        // Then fit the chart bars
        fitCarbChartBars()
        carbsRegime = CarbsRegime(globalStartTime: self.globalStartTime, globalEndTime: self.globalEndTime, intervalInMinutes: self.intervalInMinutes, sugarsEntries: self.sugarsEntries, carbsEntries: self.carbsEntries, eCarbsEntries: self.eCarbsEntries)
        
        self.objectWillChange.send()
        self.carbsRegime.objectWillChange.send()
    }
    
    // MARK: - Functions for calculating the HealthKit information
    
    private func calculateTotalMealSugars() {
        if includeTotalMealSugars {
            let entries = generateEntries(amount: meal.sugars, time: now, type: .sugars)
            self.hkObjects.append(entries.hkObject)
            sugarsEntries[now] = entries.carbsEntry
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
                xCarbsEntries: &self.eCarbsEntries,
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
    
    // MARK: - Functions for fitting the chart
    
    func fitCarbChartBars() {
        if includeTotalMealCarbs || includeECarbs || includeTotalMealSugars { // We only need this if carbs are selected
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
    
    private func getMinMaxCarbs() -> (min: Double, max: Double) {
        var minDouble = 0.0
        var maxDouble = 0.0
        
        if includeTotalMealSugars {
            for entry in sugarsEntries.values {
                minDouble = minDouble == 0 ? entry.value : min(minDouble, entry.value)
                maxDouble = max(maxDouble, entry.value)
            }
        }
        
        if includeTotalMealCarbs {
            for entry in carbsEntries.values {
                minDouble = minDouble == 0 ? entry.value : min(minDouble, entry.value)
                maxDouble = max(maxDouble, entry.value)
            }
        }
        
        if includeECarbs {
            for entry in eCarbsEntries.values {
                minDouble = minDouble == 0 ? entry.value : min(minDouble, entry.value)
                maxDouble = max(maxDouble, entry.value)
            }
        }
        
        return (minDouble, maxDouble)
    }
    
    func getSplitBarHeight(carbs: Double) -> Double {
        previewHeight - (theoreticalMaxBarHeight - carbs * regularMultiplier)
    }
}
