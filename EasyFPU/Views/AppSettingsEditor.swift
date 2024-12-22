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
    @Binding var navigationPath: NavigationPath
    @State private var alertPeriodAfterExportInMinutes: Int = UserSettings.shared.alertPeriodAfterExportInMinutes
    @State private var selectedFoodDatabaseType: FoodDatabaseType = UserSettings.getFoodDatabaseType()
    @State private var searchWorldwide: Bool = UserSettings.shared.searchWorldwide
    @State private var selectedCountry: Country = Country(countryCode: UserSettings.getCountryCode() ?? "DE")
    @State private var errorMessage: String = ""
    @State private var showingAlert: Bool = false
    
    var body: some View {
        Form {
            // Other settings
            Section(header: Text("Export to Health")) {
                HStack {
                    Stepper("Alert duration between exports", value: $alertPeriodAfterExportInMinutes, in: 0...60, step: 5)
                        .onChange(of: alertPeriodAfterExportInMinutes) {
                            if !UserSettings.set(UserSettings.UserDefaultsType.int(self.alertPeriodAfterExportInMinutes, UserSettings.UserDefaultsIntKey.alertPeriodAfterExportInMinutes), errorMessage: &self.errorMessage) {
                                self.showingAlert = true
                            } else {
                                UserSettings.shared.alertPeriodAfterExportInMinutes = self.alertPeriodAfterExportInMinutes
                            }
                        }
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
                .onChange(of: selectedFoodDatabaseType) {
                    if !UserSettings.set(UserSettings.UserDefaultsType.string(self.selectedFoodDatabaseType.rawValue, UserSettings.UserDefaultsStringKey.foodDatabase), errorMessage: &self.errorMessage) {
                        self.showingAlert = true
                    } else {
                        UserSettings.shared.foodDatabase = FoodDatabaseType.getFoodDatabase(type: self.selectedFoodDatabaseType)
                    }
                }
                .accessibilityIdentifierBranch("FoodDatabasePicker")
                
                // For OpenFoodFacts: The country code
                if selectedFoodDatabaseType == .openFoodFacts {
                    Toggle("Search worldwide", isOn: self.$searchWorldwide)
                        .onChange(of: searchWorldwide) {
                            if !UserSettings.set(UserSettings.UserDefaultsType.bool(self.searchWorldwide, UserSettings.UserDefaultsBoolKey.searchWorldwide), errorMessage: &self.errorMessage) {
                                self.showingAlert = true
                            } else {
                                UserSettings.shared.searchWorldwide = self.searchWorldwide
                            }
                        }
                        .accessibilityIdentifierLeaf("OpenFoodFactsWorldwideSearchToggle")
                    if !searchWorldwide {
                        HStack {
                            NavigationLink("Country", destination: CountryPickerView(selectedCountry: self.$selectedCountry))
                                .onChange(of: selectedCountry) {
                                    if !UserSettings.set(UserSettings.UserDefaultsType.string(self.selectedCountry.countryCode, UserSettings.UserDefaultsStringKey.countryCode), errorMessage: &errorMessage) {
                                        self.showingAlert = true
                                    } else {
                                        UserSettings.shared.countryCode = self.selectedCountry.countryCode
                                    }
                                }
                                .accessibilityIdentifierBranch("CountryPicker")
                            Text(self.selectedCountry.countryCode)
                                .accessibilityIdentifierLeaf("CountryCodeValue")
                        }
                    }
                }
            }
        }
        .navigationTitle(Text("App Settings"))
        .alert("Data alert", isPresented: self.$showingAlert, actions: {}, message: { Text(self.errorMessage) })
    }
}
