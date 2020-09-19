//
//  CarbsEntries.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 10.09.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation
import HealthKit

class CarbsEntries: ObservableObject {
    
    // MARK: - Variables required by the HealthKit data model
    
    @Published var hkObjects: [HKObject]
    var eCarbEntries: [Double]
    var carbsRegime = [(date: Date, carbs: Double)]()
    var start: Date
    var end: Date
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
    var meal: MealViewModel
    var absorptionTimeInMinutes: Double
    
    private var now: Date
    private var eCarbsStart: Date
    
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
    
    static let `default` = CarbsEntries(meal: MealViewModel.default, absorptionTimeInHours: 5, includeECarbs: UserSettings.getValue(for: UserSettings.UserDefaultsBoolKey.exportECarbs) ?? true, includeTotalMealCarbs: UserSettings.getValue(for: UserSettings.UserDefaultsBoolKey.exportTotalMealCarbs) ?? false)
    
    // MARK: - Initializers
    
    init(meal: MealViewModel, absorptionTimeInHours: Int, includeECarbs: Bool, includeTotalMealCarbs: Bool) {
        self.hkObjects = [HKObject]()
        self.eCarbEntries = [Double]()
        self.meal = meal
        self.includeECarbs = includeECarbs
        self.includeTotalMealCarbs = includeTotalMealCarbs
        
        self.now = Date()
        
        self.absorptionTimeInMinutes = Double(absorptionTimeInHours) * 60.0
        self.eCarbsStart = now.addingTimeInterval(UserSettings.shared.absorptionTimeLongDelay * 60.0)
        
        if !(includeTotalMealCarbs || includeECarbs) {
            self.start = now
            self.end = now
        } else {
            self.start = includeTotalMealCarbs ? now : eCarbsStart
            self.end = !includeECarbs ? now : eCarbsStart.addingTimeInterval(absorptionTimeInMinutes * 60.0)
            
            calculateTotalMealCarbs()
            calculateECarbs()
        }
        
        fitCarbChartBars()
        carbsRegime = getCarbRegime()
    }
    
    // MARK: - General functions
    
    func recalculate() {
        // First recalculate the HealthKit data model
        hkObjects.removeAll()
        eCarbEntries.removeAll()
        now = Date()
        eCarbsStart = now.addingTimeInterval(UserSettings.shared.absorptionTimeLongDelay * 60.0)
        
        if !(includeTotalMealCarbs || includeECarbs) {
            start = now
            end = now
        } else {
            start = includeTotalMealCarbs ? now : eCarbsStart
            end = !includeECarbs ? now : eCarbsStart.addingTimeInterval(absorptionTimeInMinutes * 60.0)
            
            calculateTotalMealCarbs()
            calculateECarbs()
        }
        
        // Then fit the chart bars
        fitCarbChartBars()
        carbsRegime = getCarbRegime()
        
        self.objectWillChange.send()
    }
    
    // MARK: - Functions for calculating the HealthKit information
    
    private func calculateECarbs() {
        if includeECarbs {
            // Make sure to not go below 1 for number carb entries, otherwise we'd increase e-carbs amount in the next step
            let numberOfECarbEntries = max(absorptionTimeInMinutes / UserSettings.shared.absorptionTimeLongInterval, 1.0)
            let eCarbsAmount = meal.fpus.getExtendedCarbs() / numberOfECarbEntries
            
            // Generate numberOfECarbEntries, but omit the last one, as it needs to be corrected using the total amount of e-carbs
            // in order to get the exact amount of total e-carbs
            var time = eCarbsStart
            var totalECarbs = 0.0
            repeat {
                let hkObject = HealthDataHelper.processQuantitySample(value: eCarbsAmount, unit: HealthDataHelper.unitCarbs, start: time, end: time, sampleType: HealthDataHelper.objectTypeCarbs)
                self.hkObjects.append(hkObject)
                self.eCarbEntries.append(eCarbsAmount)
                time = time.addingTimeInterval(UserSettings.shared.absorptionTimeLongInterval * 60)
                totalECarbs += eCarbsAmount
            } while time < end.addingTimeInterval(-UserSettings.shared.absorptionTimeLongInterval * 60)
            
            // Now determine the final amount of e-carbs and generate the final entry
            let finalAmountOfECarbs = meal.fpus.getExtendedCarbs() - totalECarbs
            if finalAmountOfECarbs > 0 {
                time = time.addingTimeInterval(UserSettings.shared.absorptionTimeLongInterval * 60)
                let hkObject = HealthDataHelper.processQuantitySample(value: finalAmountOfECarbs, unit: HealthDataHelper.unitCarbs, start: time, end: time, sampleType: HealthDataHelper.objectTypeCarbs)
                self.hkObjects.append(hkObject)
                self.eCarbEntries.append(finalAmountOfECarbs)
            }
        }
    }
    
    private func calculateTotalMealCarbs() {
        if includeTotalMealCarbs {
            let hkObject = HealthDataHelper.processQuantitySample(value: meal.getRegularCarbs(), unit: HealthDataHelper.unitCarbs, start: now, end: now, sampleType: HealthDataHelper.objectTypeCarbs)
            self.hkObjects.append(hkObject)
        }
    }
    
    // MARK: - Functions for caluclating the carbs regime
    
    private func getCarbRegime() -> [(Date, Double)] {
        var carbsRegime = [(Date, Double)]()
        
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
