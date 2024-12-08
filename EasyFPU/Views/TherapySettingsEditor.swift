//
//  AbsorptionSchemeEditor.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 30.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI
import CountryPicker

struct TherapySettingsEditor: View {
    @ObservedObject var draftAbsorptionScheme: AbsorptionSchemeViewModel
    @ObservedObject var userSettings = UserSettings.shared
    @State private var absorptionBlocksToBeDeleted = [AbsorptionBlockViewModel]()
    @State private var errorMessage: String = ""
    @State private var showingAlert: Bool = false
    @State private var showingScreen = false
    private let helpScreen = HelpScreen.absorptionSchemeEditor
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        NavigationStack {
            Form {
                AbsorptionParameterSettingsView(draftAbsorptionScheme: draftAbsorptionScheme)
                AbsorptionBlockSettingsView(
                    draftAbsorptionScheme: draftAbsorptionScheme,
                    absorptionBlocksToBeDeleted: $absorptionBlocksToBeDeleted,
                    errorMessage: $errorMessage,
                    showingAlert: $showingAlert
                )
                
            }
            // Navigation bar
            .navigationTitle(Text("Therapy Settings"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        self.showingScreen = true
                    }) {
                        Image(systemName: "questionmark.circle")
                            .imageScale(.large)
                    }
                    .accessibilityIdentifierLeaf("HelpButton")
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentation.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle")
                            .imageScale(.large)
                    }
                    .accessibilityIdentifierLeaf("CancelButton")
                    
                    Button(action: {
                        // Update absorption block
                        for absorptionBlock in self.draftAbsorptionScheme.absorptionBlocks {
                            // Check if it's an existing core data entry
                            if !absorptionBlock.hasAssociatedAbsorptionBlock() { // This is a new absorption block
                                absorptionBlock.save(to: self.draftAbsorptionScheme)
                            } else { // This is an existing absorption block, so just update values
                                let _ = absorptionBlock.updateCdAbsorptionBlock()
                            }
                        }
                        
                        // Remove deleted absorption blocks
                        for absorptionBlockToBeDeleted in self.absorptionBlocksToBeDeleted {
                            _ = absorptionBlockToBeDeleted.remove(from: draftAbsorptionScheme)
                        }
                        
                        // Reset typical amounts to be deleted
                        self.absorptionBlocksToBeDeleted.removeAll()
                        
                        // Save new user settings
                        if !(
                            UserSettings.set(UserSettings.UserDefaultsType.int(self.draftAbsorptionScheme.delaySugars, UserSettings.UserDefaultsIntKey.absorptionTimeSugarsDelay), errorMessage: &self.errorMessage) &&
                            UserSettings.set(UserSettings.UserDefaultsType.int(self.draftAbsorptionScheme.intervalSugars, UserSettings.UserDefaultsIntKey.absorptionTimeSugarsInterval), errorMessage: &self.errorMessage) &&
                            UserSettings.set(UserSettings.UserDefaultsType.double(self.draftAbsorptionScheme.durationSugars, UserSettings.UserDefaultsDoubleKey.absorptionTimeSugarsDuration), errorMessage: &self.errorMessage) &&
                            UserSettings.set(UserSettings.UserDefaultsType.int(self.draftAbsorptionScheme.delayCarbs, UserSettings.UserDefaultsIntKey.absorptionTimeCarbsDelay), errorMessage: &self.errorMessage) &&
                            UserSettings.set(UserSettings.UserDefaultsType.int(self.draftAbsorptionScheme.intervalCarbs, UserSettings.UserDefaultsIntKey.absorptionTimeCarbsInterval), errorMessage: &self.errorMessage) &&
                            UserSettings.set(UserSettings.UserDefaultsType.double(self.draftAbsorptionScheme.durationCarbs, UserSettings.UserDefaultsDoubleKey.absorptionTimeCarbsDuration), errorMessage: &self.errorMessage) &&
                            UserSettings.set(UserSettings.UserDefaultsType.int(self.draftAbsorptionScheme.delayECarbs, UserSettings.UserDefaultsIntKey.absorptionTimeECarbsDelay), errorMessage: &self.errorMessage) &&
                            UserSettings.set(UserSettings.UserDefaultsType.int(self.draftAbsorptionScheme.intervalECarbs, UserSettings.UserDefaultsIntKey.absorptionTimeECarbsInterval), errorMessage: &self.errorMessage) &&
                            UserSettings.set(UserSettings.UserDefaultsType.double(self.draftAbsorptionScheme.eCarbsFactor, UserSettings.UserDefaultsDoubleKey.eCarbsFactor), errorMessage: &self.errorMessage) &&
                            UserSettings.set(UserSettings.UserDefaultsType.bool(self.draftAbsorptionScheme.treatSugarsSeparately, UserSettings.UserDefaultsBoolKey.treatSugarsSeparately), errorMessage: &self.errorMessage)
                        ) {
                            self.showingAlert = true
                        } else {
                            // Set the dynamic user parameters and broadcast change
                            UserSettings.shared.absorptionTimeSugarsDelayInMinutes = self.draftAbsorptionScheme.delaySugars
                            UserSettings.shared.absorptionTimeSugarsIntervalInMinutes = self.draftAbsorptionScheme.intervalSugars
                            UserSettings.shared.absorptionTimeSugarsDurationInHours = self.draftAbsorptionScheme.durationSugars
                            UserSettings.shared.absorptionTimeCarbsDelayInMinutes = self.draftAbsorptionScheme.delayCarbs
                            UserSettings.shared.absorptionTimeCarbsIntervalInMinutes = self.draftAbsorptionScheme.intervalCarbs
                            UserSettings.shared.absorptionTimeCarbsDurationInHours = self.draftAbsorptionScheme.durationCarbs
                            UserSettings.shared.absorptionTimeECarbsDelayInMinutes = self.draftAbsorptionScheme.delayECarbs
                            UserSettings.shared.absorptionTimeECarbsIntervalInMinutes = self.draftAbsorptionScheme.intervalECarbs
                            UserSettings.shared.eCarbsFactor = self.draftAbsorptionScheme.eCarbsFactor
                            UserSettings.shared.treatSugarsSeparately = self.draftAbsorptionScheme.treatSugarsSeparately
                            
                            // Close sheet
                            presentation.wrappedValue.dismiss()
                        }
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .imageScale(.large)
                    }
                    .accessibilityIdentifierLeaf("SaveButton")
                }
            }
        }
        .alert("Data alert", isPresented: self.$showingAlert, actions: {}, message: { Text(self.errorMessage) })
        .sheet(isPresented: self.$showingScreen) {
            HelpView(helpScreen: self.helpScreen)
                .accessibilityIdentifierBranch("HelpSettingsEditor")
        }
    }
}
