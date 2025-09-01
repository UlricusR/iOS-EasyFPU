//
//  SwiftUIView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 07/11/2024.
//  Copyright © 2024 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct AbsorptionParameterSettingsView: View {
    @State var draftAbsorptionScheme: AbsorptionScheme
    @Binding var activeAlert: SimpleAlertType?
    @Binding var showingAlert: Bool
    
    var body: some View {
        // Sugars
        Section(header: Text("Absorption Time Parameters for Sugars")) {
            Toggle("Treat sugars separately", isOn: $draftAbsorptionScheme.treatSugarsSeparately)
                .onChange(of: draftAbsorptionScheme.treatSugarsSeparately) {
                    var errorMessage = ""
                    if !UserSettings.set(UserSettings.UserDefaultsType.bool(self.draftAbsorptionScheme.treatSugarsSeparately, UserSettings.UserDefaultsBoolKey.treatSugarsSeparately), errorMessage: &errorMessage) {
                        activeAlert = .fatalError(message: errorMessage)
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
                    TextField("Delay", value: $draftAbsorptionScheme.delaySugars, format: .number)
                        .keyboardType(.numberPad)
                        .onChange(of: draftAbsorptionScheme.delaySugars) {
                            var errorMessage = ""
                            if !UserSettings.set(UserSettings.UserDefaultsType.int(self.draftAbsorptionScheme.delaySugars, UserSettings.UserDefaultsIntKey.absorptionTimeSugarsDelay), errorMessage: &errorMessage) {
                                activeAlert = .fatalError(message: errorMessage)
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
                    TextField("Duration", value: $draftAbsorptionScheme.durationSugars, format: .number)
                        .keyboardType(.decimalPad)
                        .onChange(of: draftAbsorptionScheme.durationSugars) {
                            var errorMessage = ""
                            if !UserSettings.set(UserSettings.UserDefaultsType.double(self.draftAbsorptionScheme.durationSugars, UserSettings.UserDefaultsDoubleKey.absorptionTimeSugarsDuration), errorMessage: &errorMessage) {
                                activeAlert = .fatalError(message: errorMessage)
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
                    TextField("Interval", value: $draftAbsorptionScheme.intervalSugars, format: .number)
                        .keyboardType(.numberPad)
                        .onChange(of: draftAbsorptionScheme.intervalSugars) {
                            var errorMessage = ""
                            if !UserSettings.set(UserSettings.UserDefaultsType.int(self.draftAbsorptionScheme.intervalSugars, UserSettings.UserDefaultsIntKey.absorptionTimeSugarsInterval), errorMessage: &errorMessage) {
                                activeAlert = .fatalError(message: errorMessage)
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
                TextField("Delay", value: $draftAbsorptionScheme.delayCarbs, format: .number)
                    .keyboardType(.numberPad)
                    .onChange(of: draftAbsorptionScheme.delayCarbs) {
                        var errorMessage = ""
                        if !UserSettings.set(UserSettings.UserDefaultsType.int(self.draftAbsorptionScheme.delayCarbs, UserSettings.UserDefaultsIntKey.absorptionTimeCarbsDelay), errorMessage: &errorMessage) {
                            activeAlert = .fatalError(message: errorMessage)
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
                TextField("Duration", value: $draftAbsorptionScheme.durationCarbs, format: .number)
                    .keyboardType(.decimalPad)
                    .onChange(of: draftAbsorptionScheme.durationCarbs) {
                        var errorMessage = ""
                        if !UserSettings.set(UserSettings.UserDefaultsType.double(self.draftAbsorptionScheme.durationCarbs, UserSettings.UserDefaultsDoubleKey.absorptionTimeCarbsDuration), errorMessage: &errorMessage) {
                            activeAlert = .fatalError(message: errorMessage)
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
                TextField("Interval", value: $draftAbsorptionScheme.intervalCarbs, format: .number)
                    .keyboardType(.numberPad)
                    .onChange(of: draftAbsorptionScheme.intervalCarbs) {
                        var errorMessage = ""
                        if !UserSettings.set(UserSettings.UserDefaultsType.int(self.draftAbsorptionScheme.intervalCarbs, UserSettings.UserDefaultsIntKey.absorptionTimeCarbsInterval), errorMessage: &errorMessage) {
                            activeAlert = .fatalError(message: errorMessage)
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
                TextField("Delay", value: $draftAbsorptionScheme.delayECarbs, format: .number)
                    .keyboardType(.numberPad)
                    .onChange(of: draftAbsorptionScheme.delayECarbs) {
                        var errorMessage = ""
                        if !UserSettings.set(UserSettings.UserDefaultsType.int(self.draftAbsorptionScheme.delayECarbs, UserSettings.UserDefaultsIntKey.absorptionTimeECarbsDelay), errorMessage: &errorMessage) {
                            activeAlert = .fatalError(message: errorMessage)
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
                TextField("e-Carbs Factor", value: $draftAbsorptionScheme.eCarbsFactor, format: .number)
                    .keyboardType(.decimalPad)
                    .onChange(of: draftAbsorptionScheme.eCarbsFactor) {
                        var errorMessage = ""
                        if !UserSettings.set(UserSettings.UserDefaultsType.double(self.draftAbsorptionScheme.eCarbsFactor, UserSettings.UserDefaultsDoubleKey.eCarbsFactor), errorMessage: &errorMessage) {
                            activeAlert = .fatalError(message: errorMessage)
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
                TextField("Interval", value: $draftAbsorptionScheme.intervalECarbs, format: .number)
                    .keyboardType(.numberPad)
                    .onChange(of: draftAbsorptionScheme.intervalECarbs) {
                        var errorMessage = ""
                        if !UserSettings.set(UserSettings.UserDefaultsType.int(self.draftAbsorptionScheme.intervalECarbs, UserSettings.UserDefaultsIntKey.absorptionTimeECarbsInterval), errorMessage: &errorMessage) {
                            activeAlert = .fatalError(message: errorMessage)
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
        draftAbsorptionScheme.delaySugars = AbsorptionScheme.absorptionTimeSugarsDelayDefault
        draftAbsorptionScheme.intervalSugars = AbsorptionScheme.absorptionTimeSugarsIntervalDefault
        draftAbsorptionScheme.durationSugars = AbsorptionScheme.absoprtionTimeSugarsDurationDefault
    }
     
    func resetCarbsToDefaults() {
        // Reset absorption time (for carbs) delay, interval and duration
        draftAbsorptionScheme.delayCarbs = AbsorptionScheme.absorptionTimeCarbsDelayDefault
        draftAbsorptionScheme.intervalCarbs = AbsorptionScheme.absorptionTimeCarbsIntervalDefault
        draftAbsorptionScheme.durationCarbs = AbsorptionScheme.absoprtionTimeCarbsDurationDefault
    }
     
    func resetECarbsToDefaults() {
        // Reset absorption time (for e-carbs) delay and interval
        draftAbsorptionScheme.delayECarbs = AbsorptionScheme.absorptionTimeECarbsDelayDefault
        draftAbsorptionScheme.intervalECarbs = AbsorptionScheme.absorptionTimeECarbsIntervalDefault
        
        // Reset eCarbs factor
        draftAbsorptionScheme.eCarbsFactor = AbsorptionScheme.eCarbsFactorDefault
    }
}
