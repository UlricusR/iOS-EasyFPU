//
//  SwiftUIView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 07/11/2024.
//  Copyright © 2024 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct AbsorptionParameterSettingsView: View {
    @ObservedObject var draftAbsorptionScheme: AbsorptionSchemeViewModel
    @Binding var errorMessage: String
    @Binding var showingAlert: Bool
    
    var body: some View {
        // Sugars
        Section(header: Text("Absorption Time Parameters for Sugars")) {
            Toggle("Treat sugars separately", isOn: $draftAbsorptionScheme.treatSugarsSeparately)
                .onChange(of: draftAbsorptionScheme.treatSugarsSeparately) {
                    if !UserSettings.set(UserSettings.UserDefaultsType.bool(self.draftAbsorptionScheme.treatSugarsSeparately, UserSettings.UserDefaultsBoolKey.treatSugarsSeparately), errorMessage: &self.errorMessage) {
                        showingAlert = true
                    } else {
                        UserSettings.shared.treatSugarsSeparately = self.draftAbsorptionScheme.treatSugarsSeparately
                    }
                }
                .accessibilityIdentifierLeaf("TreatSugarsSeparatelyToggle")
            
            if draftAbsorptionScheme.treatSugarsSeparately {
                HStack {
                    Text("Delay")
                        .accessibilityIdentifierLeaf("SugarsDelayLabel")
                    CustomTextField(titleKey: "Delay", text: $draftAbsorptionScheme.delaySugarsAsString, keyboardType: .numberPad)
                        .onChange(of: draftAbsorptionScheme.delaySugarsAsString) {
                            if !UserSettings.set(UserSettings.UserDefaultsType.int(self.draftAbsorptionScheme.delaySugars, UserSettings.UserDefaultsIntKey.absorptionTimeSugarsDelay), errorMessage: &self.errorMessage) {
                                showingAlert = true
                            } else {
                                UserSettings.shared.absorptionTimeSugarsDelayInMinutes = self.draftAbsorptionScheme.delaySugars
                            }
                        }
                        .multilineTextAlignment(.trailing)
                        .accessibilityIdentifierLeaf("SugarsDelayValue")
                    Text("min")
                        .accessibilityIdentifierLeaf("SugarsDelayUnit")
                }
                
                HStack {
                    Text("Duration")
                        .accessibilityIdentifierLeaf("SugarsDurationLabel")
                    CustomTextField(titleKey: "Duration", text: $draftAbsorptionScheme.durationSugarsAsString, keyboardType: .numberPad)
                        .onChange(of: draftAbsorptionScheme.durationSugarsAsString) {
                            if !UserSettings.set(UserSettings.UserDefaultsType.double(self.draftAbsorptionScheme.durationSugars, UserSettings.UserDefaultsDoubleKey.absorptionTimeSugarsDuration), errorMessage: &self.errorMessage) {
                                showingAlert = true
                            } else {
                                UserSettings.shared.absorptionTimeSugarsDurationInHours = self.draftAbsorptionScheme.durationSugars
                            }
                        }
                        .multilineTextAlignment(.trailing)
                        .accessibilityIdentifierLeaf("SugarsDurationValue")
                    Text("h")
                        .accessibilityIdentifierLeaf("SugarsDurationUnit")
                }
                
                HStack {
                    Text("Interval")
                        .accessibilityIdentifierLeaf("SugarsIntervalLabel")
                    CustomTextField(titleKey: "Interval", text: $draftAbsorptionScheme.intervalSugarsAsString, keyboardType: .numberPad)
                        .onChange(of: draftAbsorptionScheme.intervalSugarsAsString) {
                            if !UserSettings.set(UserSettings.UserDefaultsType.int(self.draftAbsorptionScheme.intervalSugars, UserSettings.UserDefaultsIntKey.absorptionTimeSugarsInterval), errorMessage: &self.errorMessage) {
                                showingAlert = true
                            } else {
                                UserSettings.shared.absorptionTimeSugarsIntervalInMinutes = self.draftAbsorptionScheme.intervalSugars
                            }
                        }
                        .multilineTextAlignment(.trailing)
                        .accessibilityIdentifierLeaf("SugarsIntervalValue")
                    Text("min")
                        .accessibilityIdentifierLeaf("SugarsIntervalUnit")
                }
                
                // The reset button
                Button("Reset to default") {
                    self.resetSugarsToDefaults()
                }
                .accessibilityIdentifierLeaf("SugarsResetButton")
            }
        }
        
        // Carbs
        Section(header: Text("Absorption Time Parameters for Carbs")) {
            HStack {
                Text("Delay")
                    .accessibilityIdentifierLeaf("CarbsDelayLabel")
                CustomTextField(titleKey: "Delay", text: $draftAbsorptionScheme.delayCarbsAsString, keyboardType: .numberPad)
                    .onChange(of: draftAbsorptionScheme.delayCarbsAsString) {
                        if !UserSettings.set(UserSettings.UserDefaultsType.int(self.draftAbsorptionScheme.delayCarbs, UserSettings.UserDefaultsIntKey.absorptionTimeCarbsDelay), errorMessage: &self.errorMessage) {
                            showingAlert = true
                        } else {
                            UserSettings.shared.absorptionTimeCarbsDelayInMinutes = self.draftAbsorptionScheme.delayCarbs
                        }
                    }
                    .multilineTextAlignment(.trailing)
                    .accessibilityIdentifierLeaf("CarbsDelayValue")
                Text("min")
                    .accessibilityIdentifierLeaf("CarbsDelayUnit")
            }
            
            HStack {
                Text("Duration")
                    .accessibilityIdentifierLeaf("CarbsDurationLabel")
                CustomTextField(titleKey: "Duration", text: $draftAbsorptionScheme.durationCarbsAsString, keyboardType: .numberPad)
                    .onChange(of: draftAbsorptionScheme.durationCarbsAsString) {
                        if !UserSettings.set(UserSettings.UserDefaultsType.double(self.draftAbsorptionScheme.durationCarbs, UserSettings.UserDefaultsDoubleKey.absorptionTimeCarbsDuration), errorMessage: &self.errorMessage) {
                            showingAlert = true
                        } else {
                            UserSettings.shared.absorptionTimeCarbsDurationInHours = self.draftAbsorptionScheme.durationCarbs
                        }
                    }
                    .multilineTextAlignment(.trailing)
                    .accessibilityIdentifierLeaf("CarbsDurationValue")
                Text("h")
                    .accessibilityIdentifierLeaf("CarbsDurationUnit")
            }
            
            HStack {
                Text("Interval")
                    .accessibilityIdentifierLeaf("CarbsIntervalLabel")
                CustomTextField(titleKey: "Interval", text: $draftAbsorptionScheme.intervalCarbsAsString, keyboardType: .numberPad)
                    .onChange(of: draftAbsorptionScheme.intervalCarbsAsString) {
                        if !UserSettings.set(UserSettings.UserDefaultsType.int(self.draftAbsorptionScheme.intervalCarbs, UserSettings.UserDefaultsIntKey.absorptionTimeCarbsInterval), errorMessage: &self.errorMessage) {
                            showingAlert = true
                        } else {
                            UserSettings.shared.absorptionTimeCarbsIntervalInMinutes = self.draftAbsorptionScheme.intervalCarbs
                        }
                    }
                    .multilineTextAlignment(.trailing)
                    .accessibilityIdentifierLeaf("CarbsIntervalValue")
                Text("min")
                    .accessibilityIdentifierLeaf("CarbsIntervalUnit")
            }
            
            // The reset button
            Button("Reset to default") {
                self.resetCarbsToDefaults()
            }
            .accessibilityIdentifierLeaf("CarbsResetButton")
        }
        
        // e-Carbs
        Section(header: Text("Absorption Time Parameters for e-Carbs")) {
            HStack {
                Text("Delay")
                    .accessibilityIdentifierLeaf("ECarbsDelayLabel")
                CustomTextField(titleKey: "Delay", text: $draftAbsorptionScheme.delayECarbsAsString, keyboardType: .numberPad)
                    .onChange(of: draftAbsorptionScheme.delayECarbsAsString) {
                        if !UserSettings.set(UserSettings.UserDefaultsType.int(self.draftAbsorptionScheme.delayECarbs, UserSettings.UserDefaultsIntKey.absorptionTimeECarbsDelay), errorMessage: &self.errorMessage) {
                            showingAlert = true
                        } else {
                            UserSettings.shared.absorptionTimeECarbsDelayInMinutes = self.draftAbsorptionScheme.delayECarbs
                        }
                    }
                    .multilineTextAlignment(.trailing)
                    .accessibilityIdentifierLeaf("ECarbsDelayValue")
                Text("min")
                    .accessibilityIdentifierLeaf("ECarbsDelayUnit")
            }
            
            HStack {
                Text("e-Carbs Factor")
                    .accessibilityIdentifierLeaf("ECarbsFactorLabel")
                CustomTextField(titleKey: "e-Carbs Factor", text: $draftAbsorptionScheme.eCarbsFactorAsString, keyboardType: .numberPad)
                    .onChange(of: draftAbsorptionScheme.eCarbsFactorAsString) {
                        if !UserSettings.set(UserSettings.UserDefaultsType.double(self.draftAbsorptionScheme.eCarbsFactor, UserSettings.UserDefaultsDoubleKey.eCarbsFactor), errorMessage: &self.errorMessage) {
                            showingAlert = true
                        } else {
                            UserSettings.shared.eCarbsFactor = self.draftAbsorptionScheme.eCarbsFactor
                        }
                    }
                    .multilineTextAlignment(.trailing)
                    .accessibilityIdentifierLeaf("ECarbsFactorValue")
                Text("g/FPU")
                    .accessibilityIdentifierLeaf("ECarbsFactorUnit")
            }
            
            HStack {
                Text("Interval")
                    .accessibilityIdentifierLeaf("ECarbsIntervalLabel")
                CustomTextField(titleKey: "Interval", text: $draftAbsorptionScheme.intervalECarbsAsString, keyboardType: .numberPad)
                    .onChange(of: draftAbsorptionScheme.intervalECarbsAsString) {
                        if !UserSettings.set(UserSettings.UserDefaultsType.int(self.draftAbsorptionScheme.intervalECarbs, UserSettings.UserDefaultsIntKey.absorptionTimeECarbsInterval), errorMessage: &self.errorMessage) {
                            showingAlert = true
                        } else {
                            UserSettings.shared.absorptionTimeECarbsIntervalInMinutes = self.draftAbsorptionScheme.intervalECarbs
                        }
                    }
                    .multilineTextAlignment(.trailing)
                    .accessibilityIdentifierLeaf("ECarbsIntervalValue")
                Text("min")
                    .accessibilityIdentifierLeaf("ECarbsIntervalUnit")
            }
            
            // The reset button
            Button("Reset to default") {
                self.resetECarbsToDefaults()
            }
            .accessibilityIdentifierLeaf("ECarbsResetButton")
        }
    }
    
    func resetSugarsToDefaults() {
        // Reset absorption time (for sugars) delay, interval and duration
        draftAbsorptionScheme.delaySugarsAsString = DataHelper.doubleFormatter(numberOfDigits: 5).string(from: NSNumber(value: AbsorptionSchemeViewModel.absorptionTimeSugarsDelayDefault))!
        draftAbsorptionScheme.intervalSugarsAsString = DataHelper.doubleFormatter(numberOfDigits: 5).string(from: NSNumber(value: AbsorptionSchemeViewModel.absorptionTimeSugarsIntervalDefault))!
        draftAbsorptionScheme.durationSugarsAsString = DataHelper.doubleFormatter(numberOfDigits: 5).string(from: NSNumber(value: AbsorptionSchemeViewModel.absoprtionTimeSugarsDurationDefault))!
    }
     
    func resetCarbsToDefaults() {
        // Reset absorption time (for carbs) delay, interval and duration
        draftAbsorptionScheme.delayCarbsAsString = DataHelper.doubleFormatter(numberOfDigits: 5).string(from: NSNumber(value: AbsorptionSchemeViewModel.absorptionTimeCarbsDelayDefault))!
        draftAbsorptionScheme.intervalCarbsAsString = DataHelper.doubleFormatter(numberOfDigits: 5).string(from: NSNumber(value: AbsorptionSchemeViewModel.absorptionTimeCarbsIntervalDefault))!
        draftAbsorptionScheme.durationCarbsAsString = DataHelper.doubleFormatter(numberOfDigits: 5).string(from: NSNumber(value: AbsorptionSchemeViewModel.absoprtionTimeCarbsDurationDefault))!
    }
     
    func resetECarbsToDefaults() {
        // Reset absorption time (for e-carbs) delay and interval
        draftAbsorptionScheme.delayECarbsAsString = DataHelper.doubleFormatter(numberOfDigits: 5).string(from: NSNumber(value: AbsorptionSchemeViewModel.absorptionTimeECarbsDelayDefault))!
        draftAbsorptionScheme.intervalECarbsAsString = DataHelper.doubleFormatter(numberOfDigits: 5).string(from: NSNumber(value: AbsorptionSchemeViewModel.absorptionTimeECarbsIntervalDefault))!
        
        // Reset eCarbs factor
        draftAbsorptionScheme.eCarbsFactorAsString = DataHelper.doubleFormatter(numberOfDigits: 5).string(from: NSNumber(value: AbsorptionSchemeViewModel.eCarbsFactorDefault))!
    }
}
