//
//  SettingsHelper.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 09.09.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation
import SwiftUI

@Observable class UserSettings {
    // MARK: - The keys
    enum UserDefaultsType {
        case bool(Bool, UserSettings.UserDefaultsBoolKey)
        case double(Double, UserSettings.UserDefaultsDoubleKey)
        case int(Int, UserSettings.UserDefaultsIntKey)
        case date(Date, UserSettings.UserDefaultsDateKey)
        case string(String, UserSettings.UserDefaultsStringKey)
    }
    
    enum UserDefaultsBoolKey: String, CaseIterable {
        case disclaimerAccepted = "DisclaimerAccepted"
        case foodDatabaseUseAtOwnRiskAccepted = "FoodDatabaseUseAtOwnRiskAccepted"
        case exportECarbs = "ExportECarbs"
        case exportTotalMealCarbs = "ExportTotalMealCarbs"
        case exportTotalMealSugars = "ExportTotalMealSugars"
        case exportTotalMealCalories = "ExportTotalMealCalories"
        case treatSugarsSeparately = "TreatSugarsSeparately"
        case searchWorldwide = "SearchWorldwide"
        case groupProductsByCategory = "GroupProductsByCategory"
        case groupIngredientsByCategory = "GroupIngredientsByCategory"
    }
    
    enum UserDefaultsDoubleKey: String, CaseIterable {
        case absorptionTimeSugarsDuration = "AbsorptionTimeSugarsDuration"
        case absorptionTimeCarbsDuration = "AbsorptionTimeCarbsDuration"
        case eCarbsFactor = "ECarbsFactor"
    }
    
    enum UserDefaultsIntKey: String, CaseIterable {
        case absorptionTimeSugarsDelay = "AbsorptionTimeSugarsDelay"
        case absorptionTimeSugarsInterval = "AbsorptionTimeSugarsInterval"
        case absorptionTimeCarbsDelay = "AbsorptionTimeCarbsDelay"
        case absorptionTimeCarbsInterval = "AbsorptionTimeCarbsInterval"
        case absorptionTimeECarbsDelay = "AbsorptionTimeECarbsDelay"
        case absorptionTimeECarbsInterval = "AbsorptionTimeECarbsInterval"
        case alertPeriodAfterExportInMinutes = "AlertPeriodAfterExportInMinutes"
    }
    
    enum UserDefaultsDateKey: String, CaseIterable {
        case lastSugarsExport = "LastSugarsExport"
        case lastCarbsExport = "LastCarbsExport"
        case lastECarbsExport = "LastECarbsExport"
        case lastCaloriesExport = "LastCaloriesExport"
    }
    
    enum UserDefaultsStringKey: String, CaseIterable {
        case foodDatabase = "FoodDatabase"
        case countryCode = "CountryCode"
    }
    
    // MARK: - The key store for syncing via iCloud
    private static let keyStore = NSUbiquitousKeyValueStore()
    
    // MARK: - Dynamic user settings are treated here
    var disclaimerAccepted: Bool
    var foodDatabaseUseAtOwnRiskAccepted: Bool
    var absorptionTimeSugarsDelayInMinutes: Int
    var absorptionTimeSugarsIntervalInMinutes: Int
    var absorptionTimeSugarsDurationInHours: Double
    var absorptionTimeCarbsDelayInMinutes: Int
    var absorptionTimeCarbsIntervalInMinutes: Int
    var absorptionTimeCarbsDurationInHours: Double
    var absorptionTimeECarbsDelayInMinutes: Int
    var absorptionTimeECarbsIntervalInMinutes: Int
    var eCarbsFactor: Double
    var treatSugarsSeparately: Bool
    var mealDelayInMinutes: Int = 0
    var alertPeriodAfterExportInMinutes: Int = 15
    var foodDatabase: FoodDatabase
    var searchWorldwide: Bool
    var countryCode: String?
    var groupProductsByCategory: Bool
    var groupIngredientsByCategory: Bool
    
    static let shared = UserSettings(
        disclaimerAccepted: UserSettings.getValue(for: UserDefaultsBoolKey.disclaimerAccepted) ?? false,
        foodDatabaseUseAtOwnRiskAccepted: UserSettings.getValue(for: UserDefaultsBoolKey.foodDatabaseUseAtOwnRiskAccepted) ?? false,
        absorptionTimeSugarsDelayInMinutes: UserSettings.getValue(for: UserDefaultsIntKey.absorptionTimeSugarsDelay) ?? AbsorptionScheme.absorptionTimeSugarsDelayDefault,
        absorptionTimeSugarsIntervalInMinutes: UserSettings.getValue(for: UserDefaultsIntKey.absorptionTimeSugarsInterval) ?? AbsorptionScheme.absorptionTimeSugarsIntervalDefault,
        absorptionTimeSugarsDurationInHours: UserSettings.getValue(for: UserDefaultsDoubleKey.absorptionTimeSugarsDuration) ?? AbsorptionScheme.absoprtionTimeSugarsDurationDefault,
        absorptionTimeCarbsDelayInMinutes: UserSettings.getValue(for: UserDefaultsIntKey.absorptionTimeCarbsDelay) ?? AbsorptionScheme.absorptionTimeCarbsDelayDefault,
        absorptionTimeCarbsIntervalInMinutes: UserSettings.getValue(for: UserDefaultsIntKey.absorptionTimeCarbsInterval) ?? AbsorptionScheme.absorptionTimeCarbsIntervalDefault,
        absorptionTimeCarbsDurationInHours: UserSettings.getValue(for: UserDefaultsDoubleKey.absorptionTimeCarbsDuration) ?? AbsorptionScheme.absoprtionTimeCarbsDurationDefault,
        absorptionTimeECarbsDelayInMinutes: UserSettings.getValue(for: UserDefaultsIntKey.absorptionTimeECarbsDelay) ?? AbsorptionScheme.absorptionTimeECarbsDelayDefault,
        absorptionTimeECarbsIntervalInMinutes: UserSettings.getValue(for: UserDefaultsIntKey.absorptionTimeECarbsInterval) ?? AbsorptionScheme.absorptionTimeECarbsIntervalDefault,
        eCarbsFactor: UserSettings.getValue(for: UserDefaultsDoubleKey.eCarbsFactor) ?? AbsorptionScheme.eCarbsFactorDefault,
        treatSugarsSeparately: UserSettings.getValue(for: UserDefaultsBoolKey.treatSugarsSeparately) ?? AbsorptionScheme.treatSugarsSeparatelyDefault,
        alertPeriodAfterExportInMinutes: UserSettings.getValue(for: UserDefaultsIntKey.alertPeriodAfterExportInMinutes) ?? 15,
        foodDatabase: FoodDatabaseType.getFoodDatabase(type: UserSettings.getFoodDatabaseType()),
        searchWorldwide: UserSettings.getValue(for: UserDefaultsBoolKey.searchWorldwide) ?? false,
        countryCode: UserSettings.getValue(for: UserDefaultsStringKey.countryCode) ?? Locale.current.region?.identifier,
        groupProductsByCategory: UserSettings.getValue(for: UserDefaultsBoolKey.groupProductsByCategory) ?? true,
        groupIngredientsByCategory: UserSettings.getValue(for: UserDefaultsBoolKey.groupIngredientsByCategory) ?? true
    )
    
    private init(
        disclaimerAccepted: Bool,
        foodDatabaseUseAtOwnRiskAccepted: Bool,
        absorptionTimeSugarsDelayInMinutes: Int,
        absorptionTimeSugarsIntervalInMinutes: Int,
        absorptionTimeSugarsDurationInHours: Double,
        absorptionTimeCarbsDelayInMinutes: Int,
        absorptionTimeCarbsIntervalInMinutes: Int,
        absorptionTimeCarbsDurationInHours: Double,
        absorptionTimeECarbsDelayInMinutes: Int,
        absorptionTimeECarbsIntervalInMinutes: Int,
        eCarbsFactor: Double,
        treatSugarsSeparately: Bool,
        alertPeriodAfterExportInMinutes: Int,
        foodDatabase: FoodDatabase,
        searchWorldwide: Bool,
        countryCode: String?,
        groupProductsByCategory: Bool,
        groupIngredientsByCategory: Bool
    ) {
        self.disclaimerAccepted = disclaimerAccepted
        self.foodDatabaseUseAtOwnRiskAccepted = foodDatabaseUseAtOwnRiskAccepted
        self.absorptionTimeSugarsDelayInMinutes = absorptionTimeSugarsDelayInMinutes // in minutes
        self.absorptionTimeSugarsIntervalInMinutes = absorptionTimeSugarsIntervalInMinutes // in minutes
        self.absorptionTimeSugarsDurationInHours = absorptionTimeSugarsDurationInHours // in hours
        self.absorptionTimeCarbsDelayInMinutes = absorptionTimeCarbsDelayInMinutes // in minutes
        self.absorptionTimeCarbsIntervalInMinutes = absorptionTimeCarbsIntervalInMinutes // in minutes
        self.absorptionTimeCarbsDurationInHours = absorptionTimeCarbsDurationInHours // in hours
        self.absorptionTimeECarbsDelayInMinutes = absorptionTimeECarbsDelayInMinutes // in minutes
        self.absorptionTimeECarbsIntervalInMinutes = absorptionTimeECarbsIntervalInMinutes // in minutes
        self.eCarbsFactor = eCarbsFactor
        self.treatSugarsSeparately = treatSugarsSeparately
        self.alertPeriodAfterExportInMinutes = alertPeriodAfterExportInMinutes
        self.foodDatabase = foodDatabase
        self.searchWorldwide = searchWorldwide
        self.countryCode = countryCode
        self.groupProductsByCategory = groupProductsByCategory
        self.groupIngredientsByCategory = groupIngredientsByCategory
    }
    
    // MARK: - Static helper functions
    
    static func set(_ parameter: UserDefaultsType, errorMessage: inout String) -> Bool {
        switch parameter {
        case .bool(let value, let key):
            if !UserDefaultsBoolKey.allCases.contains(key) {
                errorMessage = NSLocalizedString("Cannot store parameter: ", comment: "") + key.rawValue
                return false
            }
            UserSettings.keyStore.set(value, forKey: key.rawValue)
        case .double(let value, let key):
            if !UserDefaultsDoubleKey.allCases.contains(key) {
                errorMessage = NSLocalizedString("Cannot store parameter: ", comment: "") + key.rawValue
                return false
            }
            UserSettings.keyStore.set(value, forKey: key.rawValue)
        case .int(let value, let key):
            if !UserDefaultsIntKey.allCases.contains(key) {
                errorMessage = NSLocalizedString("Cannot store parameter: ", comment: "") + key.rawValue
                return false
            }
            UserSettings.keyStore.set(value, forKey: key.rawValue)
        case .date(let value, let key):
            if !UserDefaultsDateKey.allCases.contains(key) {
                errorMessage = NSLocalizedString("Cannot store parameter: ", comment: "") + key.rawValue
                return false
            }
            UserSettings.keyStore.set(value, forKey: key.rawValue)
        case .string(let value, let key):
            if !UserDefaultsStringKey.allCases.contains(key) {
                errorMessage = NSLocalizedString("Cannot store parameter: ", comment: "") + key.rawValue
                return false
            }
            UserSettings.keyStore.set(value, forKey: key.rawValue)
        }
        
        // Synchronize
        UserSettings.keyStore.synchronize()
        return true
    }
    
    static func remove(_ key: String) {
        UserSettings.keyStore.removeObject(forKey: key)
    }
    
    static func getValue(for key: UserDefaultsBoolKey) -> Bool? {
        UserSettings.keyStore.object(forKey: key.rawValue) == nil ? nil : UserSettings.keyStore.bool(forKey: key.rawValue)
    }
    
    static func getValue(for key: UserDefaultsDoubleKey) -> Double? {
        UserSettings.keyStore.object(forKey: key.rawValue) == nil ? nil : UserSettings.keyStore.double(forKey: key.rawValue)
    }
    
    static func getValue(for key: UserDefaultsIntKey) -> Int? {
        UserSettings.keyStore.object(forKey: key.rawValue) == nil ? nil : Int(UserSettings.keyStore.longLong(forKey: key.rawValue))
    }
    
    static func getValue(for key: UserDefaultsDateKey) -> Date? {
        UserSettings.keyStore.object(forKey: key.rawValue) == nil ? nil : UserSettings.keyStore.object(forKey: key.rawValue) as? Date
    }
    
    static func getValue(for key: UserDefaultsStringKey) -> String? {
        UserSettings.keyStore.object(forKey: key.rawValue) == nil ? nil : UserSettings.keyStore.string(forKey: key.rawValue)
    }
    
    static func getFoodDatabaseType() -> FoodDatabaseType {
        let foodDatabaseValue = UserSettings.keyStore.object(forKey: FoodDatabaseType.key) == nil ? FoodDatabaseType.getDefaultFoodDatabaseType().rawValue : UserSettings.keyStore.string(forKey: FoodDatabaseType.key)!
        
        // If we don't have a key, we return the default
        if let foodDatabaseType = FoodDatabaseType.init(rawValue: foodDatabaseValue) {
            return foodDatabaseType
        } else {
            // Return the default
            return FoodDatabaseType.getDefaultFoodDatabaseType()
        }
    }
    
    static func getCountryCode() -> String? {
        if let countryCode = UserSettings.shared.countryCode {
            return countryCode
        } else if let countryCode = UserSettings.getValue(for: UserSettings.UserDefaultsStringKey.countryCode) {
            return countryCode
        } else {
            return nil
        }
    }
}
