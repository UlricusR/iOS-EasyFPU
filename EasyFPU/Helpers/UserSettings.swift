//
//  SettingsHelper.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 09.09.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class UserSettings: ObservableObject {
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
        case exportECarbs = "ExportECarbs"
        case exportTotalMealCarbs = "ExportTotalMealCarbs"
        case exportTotalMealSugars = "ExportTotalMealSugars"
        case exportTotalMealCalories = "ExportTotalMealCalories"
        case treatSugarsSeparately = "TreatSugarsSeparately"
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
    }
    
    enum UserDefaultsDateKey: String, CaseIterable {
        case lastSugarsExport = "LastSugarsExport"
        case lastCarbsExport = "LastCarbsExport"
        case lastECarbsExport = "LastECarbsExport"
        case lastCaloriesExport = "LastCaloriesExport"
    }
    
    enum UserDefaultsStringKey: String, CaseIterable {
        case countryCode = "CountryCode"
    }
    
    // MARK: - The key store for syncing via iCloud
    private static var keyStore = NSUbiquitousKeyValueStore()
    
    // MARK: - Dynamic user settings are treated here
    @Published var disclaimerAccepted: Bool
    @Published var absorptionTimeSugarsDelayInMinutes: Int
    @Published var absorptionTimeSugarsIntervalInMinutes: Int
    @Published var absorptionTimeSugarsDurationInHours: Double
    @Published var absorptionTimeCarbsDelayInMinutes: Int
    @Published var absorptionTimeCarbsIntervalInMinutes: Int
    @Published var absorptionTimeCarbsDurationInHours: Double
    @Published var absorptionTimeECarbsDelayInMinutes: Int
    @Published var absorptionTimeECarbsIntervalInMinutes: Int
    @Published var eCarbsFactor: Double
    @Published var treatSugarsSeparately: Bool
    @Published var mealDelayInMinutes: Int = 0
    @Published var alertPeriodAfterExportInMinutes: Int = 15
    @Published var foodDatabase: FoodDatabase
    @Published var countryCode: String?
    
    static let shared = UserSettings(
        disclaimerAccepted: UserSettings.getValue(for: UserDefaultsBoolKey.disclaimerAccepted) ?? false,
        absorptionTimeSugarsDelayInMinutes: UserSettings.getValue(for: UserDefaultsIntKey.absorptionTimeSugarsDelay) ?? AbsorptionSchemeViewModel.absorptionTimeSugarsDelayDefault,
        absorptionTimeSugarsIntervalInMinutes: UserSettings.getValue(for: UserDefaultsIntKey.absorptionTimeSugarsInterval) ?? AbsorptionSchemeViewModel.absorptionTimeSugarsIntervalDefault,
        absorptionTimeSugarsDurationInHours: UserSettings.getValue(for: UserDefaultsDoubleKey.absorptionTimeSugarsDuration) ?? AbsorptionSchemeViewModel.absoprtionTimeSugarsDurationDefault,
        absorptionTimeCarbsDelayInMinutes: UserSettings.getValue(for: UserDefaultsIntKey.absorptionTimeCarbsDelay) ?? AbsorptionSchemeViewModel.absorptionTimeCarbsDelayDefault,
        absorptionTimeCarbsIntervalInMinutes: UserSettings.getValue(for: UserDefaultsIntKey.absorptionTimeCarbsInterval) ?? AbsorptionSchemeViewModel.absorptionTimeCarbsIntervalDefault,
        absorptionTimeCarbsDurationInHours: UserSettings.getValue(for: UserDefaultsDoubleKey.absorptionTimeCarbsDuration) ?? AbsorptionSchemeViewModel.absoprtionTimeCarbsDurationDefault,
        absorptionTimeECarbsDelayInMinutes: UserSettings.getValue(for: UserDefaultsIntKey.absorptionTimeECarbsDelay) ?? AbsorptionSchemeViewModel.absorptionTimeECarbsDelayDefault,
        absorptionTimeECarbsIntervalInMinutes: UserSettings.getValue(for: UserDefaultsIntKey.absorptionTimeECarbsInterval) ?? AbsorptionSchemeViewModel.absorptionTimeECarbsIntervalDefault,
        eCarbsFactor: UserSettings.getValue(for: UserDefaultsDoubleKey.eCarbsFactor) ?? AbsorptionSchemeViewModel.eCarbsFactorDefault,
        treatSugarsSeparately: UserSettings.getValue(for: UserDefaultsBoolKey.treatSugarsSeparately) ?? AbsorptionSchemeViewModel.treatSugarsSeparatelyDefault,
        foodDatabase: UserSettings.getFoodDatabase(),
        countryCode: UserSettings.getValue(for: UserDefaultsStringKey.countryCode)
    )
    
    private init(
        disclaimerAccepted: Bool,
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
        foodDatabase: FoodDatabase,
        countryCode: String?
    ) {
        self.disclaimerAccepted = disclaimerAccepted
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
        self.foodDatabase = foodDatabase
        self.countryCode = countryCode
    }
    
    // MARK: - Static helper functions
    
    static func set(_ parameter: UserDefaultsType, errorMessage: inout String) -> Bool {
        switch parameter {
        case .bool(let value, let key):
            if !UserDefaultsBoolKey.allCases.contains(key) {
                errorMessage = NSLocalizedString("Fatal error, please inform app developer: Cannot store parameter: ", comment: "") + key.rawValue
                return false
            }
            UserSettings.keyStore.set(value, forKey: key.rawValue)
        case .double(let value, let key):
            if !UserDefaultsDoubleKey.allCases.contains(key) {
                errorMessage = NSLocalizedString("Fatal error, please inform app developer: Cannot store parameter: ", comment: "") + key.rawValue
                return false
            }
            UserSettings.keyStore.set(value, forKey: key.rawValue)
        case .int(let value, let key):
            if !UserDefaultsIntKey.allCases.contains(key) {
                errorMessage = NSLocalizedString("Fatal error, please inform app developer: Cannot store parameter: ", comment: "") + key.rawValue
                return false
            }
            UserSettings.keyStore.set(value, forKey: key.rawValue)
        case .date(let value, let key):
            if !UserDefaultsDateKey.allCases.contains(key) {
                errorMessage = NSLocalizedString("Fatal error, please inform app developer: Cannot store parameter: ", comment: "") + key.rawValue
                return false
            }
            UserSettings.keyStore.set(value, forKey: key.rawValue)
        case .string(let value, let key):
            if !UserDefaultsStringKey.allCases.contains(key) {
                errorMessage = NSLocalizedString("Fatal error, please inform app developer: Cannot store parameter: ", comment: "") + key.rawValue
                return false
            }
            UserSettings.keyStore.set(value, forKey: key.rawValue)
        }
        
        // Synchronize
        UserSettings.keyStore.synchronize()
        return true
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
    
    private static func getFoodDatabase() -> FoodDatabase {
        let foodDatabaseValue = UserSettings.keyStore.object(forKey: FoodDatabaseType.key) == nil ? FoodDatabaseType.openFoodFacts.rawValue : UserSettings.keyStore.string(forKey: FoodDatabaseType.key)
        switch foodDatabaseValue {
        case FoodDatabaseType.openFoodFacts.rawValue:
            return OpenFoodFacts()
        default:
            return OpenFoodFacts()
        }
    }
}
