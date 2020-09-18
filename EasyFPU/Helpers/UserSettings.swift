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
    }
    
    enum UserDefaultsBoolKey: String, CaseIterable {
        case disclaimerAccepted = "DisclaimerAccepted"
        case exportECarbs = "ExportECarbs"
        case exportTotalMealCarbs = "ExportTotalMealCarbs"
        case exportTotalMealCalories = "ExportTotalMealCalories"
    }
    
    enum UserDefaultsDoubleKey: String, CaseIterable {
        case absorptionTimeMediumDelay = "AbsorptionTimeMediumDelay"
        case absorptionTimeMediumInterval = "AbsorptionTimeMediumInterval"
        case absorptionTimeMediumDuration = "AbsorptionTimeMediumDuration"
        case absorptionTimeLongDelay = "AbsorptionTimeLongDelay"
        case absorptionTimeLongInterval = "AbsorptionTimeLongInterval"
        case eCarbsFactor = "ECarbsFactor"
    }
    
    // MARK: - The key store for syncing via iCloud
    private static var keyStore = NSUbiquitousKeyValueStore()
    
    // MARK: - Dynamic user settings are treated here
    
    @Published var absorptionTimeLongDelay: Double
    @Published var absorptionTimeLongInterval: Double
    @Published var absorptionTimeMediumDelay: Double
    @Published var absorptionTimeMediumInterval: Double
    @Published var absorptionTimeMediumDuration: Double
    @Published var eCarbsFactor: Double
    
    static let shared = UserSettings(
        absorptionTimeLongDelay: UserSettings.getValue(for: UserDefaultsDoubleKey.absorptionTimeLongDelay) ?? AbsorptionSchemeViewModel.absorptionTimeLongDelayDefault,
        absorptionTimeLongInterval: UserSettings.getValue(for: UserDefaultsDoubleKey.absorptionTimeLongInterval) ?? AbsorptionSchemeViewModel.absorptionTimeLongIntervalDefault,
        absorptionTimeMediumDelay: UserSettings.getValue(for: UserDefaultsDoubleKey.absorptionTimeMediumDelay) ?? AbsorptionSchemeViewModel.absorptionTimeMediumDelayDefault,
        absorptionTimeMediumInterval: UserSettings.getValue(for: UserDefaultsDoubleKey.absorptionTimeMediumInterval) ?? AbsorptionSchemeViewModel.absorptionTimeMediumIntervalDefault,
        absorptionTimeMediumDuration: UserSettings.getValue(for: UserDefaultsDoubleKey.absorptionTimeMediumDuration) ?? AbsorptionSchemeViewModel.absoprtionTimeMediumDurationDefault,
        eCarbsFactor: UserSettings.getValue(for: UserDefaultsDoubleKey.eCarbsFactor) ?? AbsorptionSchemeViewModel.eCarbsFactorDefault
    )
    
    private init(
        absorptionTimeLongDelay: Double,
        absorptionTimeLongInterval: Double,
        absorptionTimeMediumDelay: Double,
        absorptionTimeMediumInterval: Double,
        absorptionTimeMediumDuration: Double,
        eCarbsFactor: Double
    ) {
        self.absorptionTimeLongDelay = absorptionTimeLongDelay
        self.absorptionTimeLongInterval = absorptionTimeLongInterval
        self.absorptionTimeMediumDelay = absorptionTimeMediumDelay
        self.absorptionTimeMediumInterval = absorptionTimeMediumInterval
        self.absorptionTimeMediumDuration = absorptionTimeMediumDuration
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
}
