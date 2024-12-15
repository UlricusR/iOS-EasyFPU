//
//  MealExportView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 08.09.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI
import HealthKit
import LocalAuthentication

struct ComposedFoodItemExportView: View {
    var composedFoodItem: ComposedFoodItemViewModel
    var absorptionScheme: AbsorptionSchemeViewModel
    @ObservedObject var userSettings = UserSettings.shared
    @ObservedObject var carbsRegimeCalculator = CarbsRegimeCalculator.default
    @State var showingSheet = false
    @State var showingAlert = false
    @State var activeAlert: SimpleAlertType?
    @State var showingExportWarning = false
    @State var alertMessages = [String]()
    private let helpScreen = HelpScreen.mealExport
    
    @State var exportTotalMealCalories = UserSettings.getValue(for: UserSettings.UserDefaultsBoolKey.exportTotalMealCalories) ?? false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Please choose the data to export:")
                .padding()
                .font(.headline)
            
            if userSettings.treatSugarsSeparately {
                Toggle(isOn: $carbsRegimeCalculator.includeTotalMealSugars) {
                    Text("Sugars")
                }
                .padding([.leading, .trailing])
                .onChange(of: carbsRegimeCalculator.includeTotalMealSugars) {
                    var errorMessage = ""
                    if !UserSettings.set(UserSettings.UserDefaultsType.bool(self.carbsRegimeCalculator.includeTotalMealSugars, UserSettings.UserDefaultsBoolKey.exportTotalMealSugars), errorMessage: &errorMessage) {
                        activeAlert = .fatalError(message: errorMessage)
                        showingAlert = true
                    }
                }
                .accessibilityIdentifierLeaf("ExportSugarsToggle")
            }
            
            Toggle(isOn: $carbsRegimeCalculator.includeTotalMealCarbs) {
                Text("Regular Carbs")
            }
            .padding([.leading, .trailing])
            .onChange(of: carbsRegimeCalculator.includeTotalMealCarbs) {
                var errorMessage = ""
                if !UserSettings.set(UserSettings.UserDefaultsType.bool(self.carbsRegimeCalculator.includeTotalMealCarbs, UserSettings.UserDefaultsBoolKey.exportTotalMealCarbs), errorMessage: &errorMessage) {
                    activeAlert = .fatalError(message: errorMessage)
                    showingAlert = true
                }
            }
            .accessibilityIdentifierLeaf("ExportCarbsToggle")
            
            Toggle(isOn: $carbsRegimeCalculator.includeECarbs) {
                Text("Extended Carbs")
            }
            .padding([.leading, .trailing])
            .onChange(of: carbsRegimeCalculator.includeECarbs) {
                var errorMessage = ""
                if !UserSettings.set(UserSettings.UserDefaultsType.bool(self.carbsRegimeCalculator.includeECarbs, UserSettings.UserDefaultsBoolKey.exportECarbs), errorMessage: &errorMessage) {
                    activeAlert = .fatalError(message: errorMessage)
                    showingAlert = true
                }
            }
            .accessibilityIdentifierLeaf("ExportECarbsToggle")
            
            Toggle(isOn: $exportTotalMealCalories) {
                Text("Total Meal Calories")
            }
            .padding([.leading, .trailing, .top])
            .onChange(of: exportTotalMealCalories) {
                var errorMessage = ""
                if !UserSettings.set(UserSettings.UserDefaultsType.bool(self.exportTotalMealCalories, UserSettings.UserDefaultsBoolKey.exportTotalMealCalories), errorMessage: &errorMessage) {
                    activeAlert = .fatalError(message: errorMessage)
                    showingAlert = true
                }
            }
            .accessibilityIdentifierLeaf("ExportCaloriesToggle")
            
            HStack {
                Stepper("Delay until meal", onIncrement: {
                    userSettings.mealDelayInMinutes = min(30, userSettings.mealDelayInMinutes + 5)
                    carbsRegimeCalculator.recalculate()
                }, onDecrement: {
                    userSettings.mealDelayInMinutes = max(0, userSettings.mealDelayInMinutes - 5)
                    carbsRegimeCalculator.recalculate()
                })
                .accessibilityIdentifierLeaf("MealDelayStepper")
                
                Text("\(userSettings.mealDelayInMinutes)")
                    .accessibilityIdentifierLeaf("MealDelayValue")
                Text("min")
                    .accessibilityIdentifierLeaf("MealDelayUnit")
            }.padding()
            
            // The carbs preview
            if !carbsRegimeCalculator.hkObjects.isEmpty {
                Text("Preview of exported carbs in g").padding([.top, .leading, .trailing])
                HealthExportCarbsPreviewChart(carbsRegime: self.carbsRegimeCalculator.carbsRegime)
            }
        }
        
        VStack(alignment: .center) {
            Button("Export", systemImage: "square.and.arrow.up") {
                self.prepareHealthSampleExport()
            }
            .padding()
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifierLeaf("ExportToHealthButton")
            .confirmationDialog(
                "Notice",
                isPresented: $showingExportWarning
            ) {
                Button("Export anyway") {
                    alertMessages.removeAll()
                    authenticate()
                }
                Button("Cancel", role: .cancel) {
                    alertMessages.removeAll()
                }
            } message: {
                Text(getExportWarningText())
            }
        }
        .navigationTitle("Export to Health").navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    self.showingSheet = true
                }) {
                    Image(systemName: "questionmark.circle")
                        .imageScale(.large)
                }
                .accessibilityIdentifierLeaf("HelpButton")
            }
        }
        .onAppear() {
            self.processHealthSample()
        }
        .alert(
            activeAlert?.title() ?? "Notice",
            isPresented: $showingAlert,
            presenting: activeAlert
        ) { activeAlert in
            activeAlert.button()
        } message: { activeAlert in
            activeAlert.message()
        }
        .sheet(isPresented: self.$showingSheet) {
            HelpView(helpScreen: self.helpScreen)
        }
    }
    
    private func processHealthSample() {
        guard let absorptionTimeInHours = composedFoodItem.fpus.getAbsorptionTime(absorptionScheme: absorptionScheme) else {
            activeAlert = .fatalError(message: "Absorption Scheme has no Absorption Blocks")
            showingAlert = true
            return
        }
        self.carbsRegimeCalculator.eCarbsAbsorptionTimeInMinutes = absorptionTimeInHours * 60
        self.carbsRegimeCalculator.recalculate()
    }
    
    private func prepareHealthSampleExport() {
        // Check for recent exports
        if carbsRegimeCalculator.includeTotalMealSugars { checkForRecentExports(of: UserSettings.UserDefaultsDateKey.lastSugarsExport) }
        if carbsRegimeCalculator.includeTotalMealCarbs { checkForRecentExports(of: UserSettings.UserDefaultsDateKey.lastCarbsExport) }
        if carbsRegimeCalculator.includeECarbs { checkForRecentExports(of: UserSettings.UserDefaultsDateKey.lastECarbsExport) }
        if exportTotalMealCalories { checkForRecentExports(of: UserSettings.UserDefaultsDateKey.lastCaloriesExport) }
        if alertMessages.count > 0 {
            showingExportWarning = true
        } else {
            authenticate()
        }
    }
    
    private func exportHealthSample() {
        // Last update of times
        carbsRegimeCalculator.recalculate()
        
        // Export
        var hkObjects = [HKObject]()
        hkObjects.append(contentsOf: carbsRegimeCalculator.hkObjects)
        if exportTotalMealCalories {
            let caloriesObject = HealthDataHelper.processQuantitySample(value: composedFoodItem.calories, unit: HealthDataHelper.unitCalories, start: Date(), end: Date(), sampleType: HealthDataHelper.objectTypeCalories)
            hkObjects.append(caloriesObject)
        }
        
        HealthDataHelper.requestHealthDataAccessIfNeeded() { completion in
            if completion {
                HealthDataHelper.saveHealthData(hkObjects) { (success, error) in
                    if !success {
                        var errorMessage = NSLocalizedString("Cannot save data to Health: ", comment: "")
                        errorMessage += error != nil ? error!.localizedDescription : NSLocalizedString("Unspecified error", comment: "")
                        activeAlert = .error(message: errorMessage)
                        showingAlert = true
                    } else {
                        self.setLatestExportDates()
                        activeAlert = .success(message: "Successfully exported data to Health")
                        showingAlert = true
                    }
                }
            } else {
                var errMessage = ""
                if let errorMessage = HealthDataHelper.errorMessage {
                    errMessage = errorMessage
                } else {
                    errMessage = NSLocalizedString("Cannot save data to Health: Please authorize EasyFPU to write to Health in your Settings.", comment: "")
                }
                activeAlert = .error(message: errMessage)
                self.showingAlert = true
            }
        }
    }
    
    private func checkForRecentExports(of settingsKey: UserSettings.UserDefaultsDateKey) {
        guard let lastDataExport = UserSettings.getValue(for: settingsKey) else { return }
        if carbsRegimeCalculator.now.timeIntervalSinceReferenceDate - lastDataExport.timeIntervalSinceReferenceDate <= TimeInterval(userSettings.alertPeriodAfterExportInMinutes * 60) {
            alertMessages.append(NSLocalizedString(settingsKey.rawValue, comment: ""))
        }
    }
    
    private func getExportWarningText() -> String {
        NSLocalizedString("You have exported the following data less than ", comment: "") + "\(userSettings.alertPeriodAfterExportInMinutes)" + NSLocalizedString(" minutes ago: ", comment: "") + alertMessages.joined(separator: ", ")
    }
    
    private func setLatestExportDates() {
        var errorMessage = ""
        if exportTotalMealCalories {
            if !UserSettings.set(UserSettings.UserDefaultsType.date(carbsRegimeCalculator.now, UserSettings.UserDefaultsDateKey.lastCaloriesExport), errorMessage: &errorMessage) {
                activeAlert = .fatalError(message: errorMessage)
                showingAlert = true
            }
        }
        if carbsRegimeCalculator.includeTotalMealSugars {
            if !UserSettings.set(UserSettings.UserDefaultsType.date(carbsRegimeCalculator.now, UserSettings.UserDefaultsDateKey.lastSugarsExport), errorMessage: &errorMessage) {
                activeAlert = .fatalError(message: errorMessage)
                showingAlert = true
            }
        }
        if carbsRegimeCalculator.includeTotalMealCarbs {
            if !UserSettings.set(UserSettings.UserDefaultsType.date(carbsRegimeCalculator.now, UserSettings.UserDefaultsDateKey.lastCarbsExport), errorMessage: &errorMessage) {
                activeAlert = .fatalError(message: errorMessage)
                showingAlert = true
            }
        }
        if carbsRegimeCalculator.includeECarbs {
            if !UserSettings.set(UserSettings.UserDefaultsType.date(carbsRegimeCalculator.now, UserSettings.UserDefaultsDateKey.lastECarbsExport), errorMessage: &errorMessage) {
                activeAlert = .fatalError(message: errorMessage)
                showingAlert = true
            }
        }
    }
    
    private func authenticate() {
        let context = LAContext()
        var error: NSError?
        var errorMessage = ""
        
        // Check whether biometric authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            // It's possible, so go ahead and use it
            let reason = NSLocalizedString("NSFaceIDUsageDescription", comment: "")
            
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                // Authentication has now completed
                DispatchQueue.main.async {
                    if success {
                        // Authentication successful
                        self.exportHealthSample()
                    } else {
                        // There was a problem
                        if authenticationError != nil {
                            errorMessage = authenticationError!.localizedDescription
                        } else {
                            errorMessage = NSLocalizedString("Authentication error, nothing was exported", comment: "")
                        }
                        activeAlert = .error(message: errorMessage)
                        showingAlert = true
                    }
                }
            }
        } else {
            // No authentication possible
            activeAlert = .error(message: "Authentication error, nothing was exported")
            showingAlert = true
        }
    }
}
