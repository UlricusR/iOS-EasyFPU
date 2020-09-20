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
    }
    
    enum UserDefaultsBoolKey: String, CaseIterable {
        case disclaimerAccepted = "DisclaimerAccepted"
        case exportECarbs = "ExportECarbs"
        case exportTotalMealCarbs = "ExportTotalMealCarbs"
        case exportTotalMealSugars = "ExportTotalMealSugars"
        case exportTotalMealCalories = "ExportTotalMealCalories"
    }
    
    enum UserDefaultsDoubleKey: String, CaseIterable {
        case absorptionTimeMediumDuration = "AbsorptionTimeMediumDuration"
        case eCarbsFactor = "ECarbsFactor"
    }
    
    enum UserDefaultsIntKey: String, CaseIterable {
        case absorptionTimeMediumDelay = "AbsorptionTimeMediumDelay"
        case absorptionTimeMediumInterval = "AbsorptionTimeMediumInterval"
        case absorptionTimeLongDelay = "AbsorptionTimeLongDelay"
        case absorptionTimeLongInterval = "AbsorptionTimeLongInterval"
    }
    
    // MARK: - The key store for syncing via iCloud
    private static var keyStore = NSUbiquitousKeyValueStore()
    
    // MARK: - Dynamic user settings are treated here
    
    @Published var absorptionTimeLongDelayInMinutes: Int
    @Published var absorptionTimeLongIntervalInMinutes: Int
    @Published var absorptionTimeMediumDelayInMinutes: Int
    @Published var absorptionTimeMediumIntervalInMinutes: Int
    @Published var absorptionTimeMediumDurationInHours: Double
    @Published var eCarbsFactor: Double
    
    static let shared = UserSettings(
        absorptionTimeLongDelayInMinutes: UserSettings.getValue(for: UserDefaultsIntKey.absorptionTimeLongDelay) ?? AbsorptionSchemeViewModel.absorptionTimeLongDelayDefault,
        absorptionTimeLongIntervalInMinutes: UserSettings.getValue(for: UserDefaultsIntKey.absorptionTimeLongInterval) ?? AbsorptionSchemeViewModel.absorptionTimeLongIntervalDefault,
        absorptionTimeMediumDelayInMinutes: UserSettings.getValue(for: UserDefaultsIntKey.absorptionTimeMediumDelay) ?? AbsorptionSchemeViewModel.absorptionTimeMediumDelayDefault,
        absorptionTimeMediumIntervalInMinutes: UserSettings.getValue(for: UserDefaultsIntKey.absorptionTimeMediumInterval) ?? AbsorptionSchemeViewModel.absorptionTimeMediumIntervalDefault,
        absorptionTimeMediumDurationInHours: UserSettings.getValue(for: UserDefaultsDoubleKey.absorptionTimeMediumDuration) ?? AbsorptionSchemeViewModel.absoprtionTimeMediumDurationDefault,
        eCarbsFactor: UserSettings.getValue(for: UserDefaultsDoubleKey.eCarbsFactor) ?? AbsorptionSchemeViewModel.eCarbsFactorDefault
    )
    
    private init(
        absorptionTimeLongDelayInMinutes: Int,
        absorptionTimeLongIntervalInMinutes: Int,
        absorptionTimeMediumDelayInMinutes: Int,
        absorptionTimeMediumIntervalInMinutes: Int,
        absorptionTimeMediumDurationInHours: Double,
        eCarbsFactor: Double
    ) {
        self.absorptionTimeLongDelayInMinutes = absorptionTimeLongDelayInMinutes // in minutes
        self.absorptionTimeLongIntervalInMinutes = absorptionTimeLongIntervalInMinutes // in minutes
        self.absorptionTimeMediumDelayInMinutes = absorptionTimeMediumDelayInMinutes // in minutes
        self.absorptionTimeMediumIntervalInMinutes = absorptionTimeMediumIntervalInMinutes // in minutes
        self.absorptionTimeMediumDurationInHours = absorptionTimeMediumDurationInHours // in hours
        self.eCarbsFactor = eCarbsFactor
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
}
