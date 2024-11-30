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
    
    var body: some View {
        // Sugars
        Section(header: Text("Absorption Time Parameters for Sugars")) {
            Toggle("Treat sugars separately", isOn: $draftAbsorptionScheme.treatSugarsSeparately)
                .accessibilityIdentifierLeaf("TreatSugarsSeparatelyToggle")
            
            if draftAbsorptionScheme.treatSugarsSeparately {
                HStack {
                    Text("Delay")
                        .accessibilityIdentifierLeaf("SugarsDelayLabel")
                    CustomTextField(titleKey: "Delay", text: $draftAbsorptionScheme.delaySugarsAsString, keyboardType: .numberPad)
                        .multilineTextAlignment(.trailing)
                        .accessibilityIdentifierLeaf("SugarsDelayValue")
                    Text("min")
                        .accessibilityIdentifierLeaf("SugarsDelayUnit")
                }
                
                HStack {
                    Text("Duration")
                        .accessibilityIdentifierLeaf("SugarsDurationLabel")
                    CustomTextField(titleKey: "Duration", text: $draftAbsorptionScheme.durationSugarsAsString, keyboardType: .numberPad)
                        .multilineTextAlignment(.trailing)
                        .accessibilityIdentifierLeaf("SugarsDurationValue")
                    Text("h")
                        .accessibilityIdentifierLeaf("SugarsDurationUnit")
                }
                
                HStack {
                    Text("Interval")
                        .accessibilityIdentifierLeaf("SugarsIntervalLabel")
                    CustomTextField(titleKey: "Interval", text: $draftAbsorptionScheme.intervalSugarsAsString, keyboardType: .numberPad)
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
                    .multilineTextAlignment(.trailing)
                    .accessibilityIdentifierLeaf("CarbsDelayValue")
                Text("min")
                    .accessibilityIdentifierLeaf("CarbsDelayUnit")
            }
            
            HStack {
                Text("Duration")
                    .accessibilityIdentifierLeaf("CarbsDurationLabel")
                CustomTextField(titleKey: "Duration", text: $draftAbsorptionScheme.durationCarbsAsString, keyboardType: .numberPad)
                    .multilineTextAlignment(.trailing)
                    .accessibilityIdentifierLeaf("CarbsDurationValue")
                Text("h")
                    .accessibilityIdentifierLeaf("CarbsDurationUnit")
            }
            
            HStack {
                Text("Interval")
                    .accessibilityIdentifierLeaf("CarbsIntervalLabel")
                CustomTextField(titleKey: "Interval", text: $draftAbsorptionScheme.intervalCarbsAsString, keyboardType: .numberPad)
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
                    .multilineTextAlignment(.trailing)
                    .accessibilityIdentifierLeaf("ECarbsDelayValue")
                Text("min")
                    .accessibilityIdentifierLeaf("ECarbsDelayUnit")
            }
            
            HStack {
                Text("e-Carbs Factor")
                    .accessibilityIdentifierLeaf("ECarbsFactorLabel")
                CustomTextField(titleKey: "e-Carbs Factor", text: $draftAbsorptionScheme.eCarbsFactorAsString, keyboardType: .numberPad)
                    .multilineTextAlignment(.trailing)
                    .accessibilityIdentifierLeaf("ECarbsFactorValue")
                Text("g/FPU")
                    .accessibilityIdentifierLeaf("ECarbsFactorUnit")
            }
            
            HStack {
                Text("Interval")
                    .accessibilityIdentifierLeaf("ECarbsIntervalLabel")
                CustomTextField(titleKey: "Interval", text: $draftAbsorptionScheme.intervalECarbsAsString, keyboardType: .numberPad)
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
