//
//  AbsorptionSchemeEditor.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 30.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI
import CountryPicker

struct AppSettingsEditor: View {
    @State private var alertPeriodAfterExportInMinutes: Int = UserSettings.shared.alertPeriodAfterExportInMinutes
    @State private var selectedFoodDatabaseType: FoodDatabaseType = UserSettings.getFoodDatabaseType()
    @State private var searchWorldwide: Bool = UserSettings.shared.searchWorldwide
    @State private var selectedCountry: Country = Country(countryCode: UserSettings.getCountryCode() ?? "DE")
    @State private var errorMessage: String = ""
    @State private var showingAlert: Bool = false
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        NavigationStack {
            Form {
                // Other settings
                Section(header: Text("Export to Health")) {
                    HStack {
                        Stepper("Alert duration between exports", value: $alertPeriodAfterExportInMinutes, in: 0...60, step: 5)
                            .accessibilityIdentifierLeaf("AlertDurationBetweenExportsStepper")
                        Text(String(alertPeriodAfterExportInMinutes))
                            .accessibilityIdentifierLeaf("AlertDurationBetweenExportsValue")
                        Text("min")
                            .accessibilityIdentifierLeaf("AlertDurationBetweenExportsUnit")
                    }
                }
                
                // Food database
                Section(header: Text("Food Database")) {
                    // The food database
                    Picker("Database", selection: $selectedFoodDatabaseType) {
                        ForEach(FoodDatabaseType.allCases) { foodDatabaseType in
                            Text(foodDatabaseType.rawValue).tag(foodDatabaseType)
                                .accessibilityIdentifierLeaf(foodDatabaseType.rawValue)
                        }
                    }
                    .accessibilityIdentifierBranch("FoodDatabasePicker")
                    
                    // For OpenFoodFacts: The country code
                    if selectedFoodDatabaseType == .openFoodFacts {
                        Toggle("Search worldwide", isOn: self.$searchWorldwide)
                            .accessibilityIdentifierLeaf("OpenFoodFactsWorldwideSearchToggle")
                        if !searchWorldwide {
                            HStack {
                                NavigationLink("Country", destination: CountryPickerView(selectedCountry: self.$selectedCountry))
                                    .accessibilityIdentifierBranch("CountryPicker")
                                Text(self.selectedCountry.countryCode)
                                    .accessibilityIdentifierLeaf("CountryCodeValue")
                            }
                        }
                    }
                }
            }
            
            // Navigation bar
            .navigationBarTitle(Text("App Settings"))
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentation.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle")
                            .imageScale(.large)
                    }
                    .accessibilityIdentifierLeaf("CancelButton")
                    
                    Button(action: {
                        // Save new user settings
                        if !(
                            UserSettings.set(UserSettings.UserDefaultsType.int(self.alertPeriodAfterExportInMinutes, UserSettings.UserDefaultsIntKey.alertPeriodAfterExportInMinutes), errorMessage: &self.errorMessage) &&
                            UserSettings.set(UserSettings.UserDefaultsType.string(self.selectedFoodDatabaseType.rawValue, UserSettings.UserDefaultsStringKey.foodDatabase), errorMessage: &self.errorMessage) &&
                            UserSettings.set(UserSettings.UserDefaultsType.bool(self.searchWorldwide, UserSettings.UserDefaultsBoolKey.searchWorldwide), errorMessage: &self.errorMessage) &&
                            UserSettings.set(UserSettings.UserDefaultsType.string(self.selectedCountry.countryCode, UserSettings.UserDefaultsStringKey.countryCode), errorMessage: &errorMessage)
                        ) {
                            self.showingAlert = true
                        } else {
                            // Set the dynamic user parameters and broadcast change
                            UserSettings.shared.alertPeriodAfterExportInMinutes = self.alertPeriodAfterExportInMinutes
                            UserSettings.shared.foodDatabase = FoodDatabaseType.getFoodDatabase(type: self.selectedFoodDatabaseType)
                            UserSettings.shared.searchWorldwide = self.searchWorldwide
                            UserSettings.shared.countryCode = self.selectedCountry.countryCode
                            
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
            
        // Alert
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Data alert"),
                message: Text(self.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
