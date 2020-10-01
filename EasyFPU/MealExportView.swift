//
//  MealExportView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 08.09.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI
import HealthKit

struct MealExportView: View {
    @Environment(\.presentationMode) var presentation
    var meal: MealViewModel
    var absorptionScheme: AbsorptionScheme
    @ObservedObject var carbsRegimeCalculator = CarbsRegimeCalculator.default
    @State var showingSheet = false
    @State var showingAlert = false
    @State var errorMessage = ""
    private let helpScreen = HelpScreen.mealExport
    
    @State var exportTotalMealCalories = UserSettings.getValue(for: UserSettings.UserDefaultsBoolKey.exportTotalMealCalories) ?? false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Please choose the data to export:").padding()
                
                if UserSettings.shared.treatSugarsSeparately {
                    Toggle(isOn: $carbsRegimeCalculator.includeTotalMealSugars) {
                        Text("Sugars")
                    }
                    .padding([.leading, .trailing])
                }
                
                Toggle(isOn: $carbsRegimeCalculator.includeTotalMealCarbs) {
                    Text("Regular Carbs")
                }
                .padding([.leading, .trailing])
                
                Toggle(isOn: $carbsRegimeCalculator.includeECarbs) {
                    Text("Extended Carbs")
                }
                .padding([.leading, .trailing])
                
                Toggle(isOn: $exportTotalMealCalories) {
                    Text("Total Meal Calories")
                }.padding()
                
                Button(action: {
                    self.exportHealthSample()
                }) {
                    Image(systemName: "square.and.arrow.up")
                    Text("Export").fontWeight(.bold)
                }
                .multilineTextAlignment(.center)
                .padding()
                
                // The carbs preview
                if !carbsRegimeCalculator.hkObjects.isEmpty {
                    Text("Preview of exported carbs in g").padding([.top, .leading, .trailing])
                    HealthExportPreview(carbsRegime: self.carbsRegimeCalculator.carbsRegime)
                }
                
                Spacer()
            }
            .navigationBarTitle("Export to Health", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    self.showingSheet = true
                }) {
                    Image(systemName: "questionmark.circle").imageScale(.large)
                },
                trailing: Button(action: {
                    // Store UserDefaults
                    if !(
                        UserSettings.set(UserSettings.UserDefaultsType.bool(self.carbsRegimeCalculator.includeTotalMealSugars, UserSettings.UserDefaultsBoolKey.exportTotalMealSugars), errorMessage: &self.errorMessage) &&
                        UserSettings.set(UserSettings.UserDefaultsType.bool(self.carbsRegimeCalculator.includeECarbs, UserSettings.UserDefaultsBoolKey.exportECarbs), errorMessage: &self.errorMessage) &&
                        UserSettings.set(UserSettings.UserDefaultsType.bool(self.carbsRegimeCalculator.includeTotalMealCarbs, UserSettings.UserDefaultsBoolKey.exportTotalMealCarbs), errorMessage: &self.errorMessage) &&
                        UserSettings.set(UserSettings.UserDefaultsType.bool(self.exportTotalMealCalories, UserSettings.UserDefaultsBoolKey.exportTotalMealCalories), errorMessage: &self.errorMessage)
                    ){
                        // Something went terribly wrong - inform user
                        self.showingAlert = true
                    } else {
                        // Close sheet
                        presentation.wrappedValue.dismiss()
                    }
                }) {
                    Text("Done")
                }
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear() {
            self.processHealthSample()
        }
        .alert(isPresented: self.$showingAlert) {
            Alert(
                title: Text("Notice"),
                message: Text(self.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .sheet(isPresented: self.$showingSheet) {
            HelpView(helpScreen: self.helpScreen)
        }
    }
    
    private func processHealthSample() {
        guard let absorptionTimeInHours = meal.fpus.getAbsorptionTime(absorptionScheme: absorptionScheme) else {
            errorMessage = NSLocalizedString("Fatal error, cannot export data, please contact the app developer: Absorption Scheme has no Absorption Blocks", comment: "")
            showingAlert = true
            return
        }
        self.carbsRegimeCalculator.meal = meal
        self.carbsRegimeCalculator.absorptionTimeInMinutes = absorptionTimeInHours * 60
        self.carbsRegimeCalculator.recalculate()
    }
    
    private func exportHealthSample() {
        var hkObjects = [HKObject]()
        hkObjects.append(contentsOf: carbsRegimeCalculator.hkObjects)
        if exportTotalMealCalories {
            let caloriesObject = HealthDataHelper.processQuantitySample(value: meal.calories, unit: HealthDataHelper.unitCalories, start: Date(), end: Date(), sampleType: HealthDataHelper.objectTypeCalories)
            hkObjects.append(caloriesObject)
        }
        
        HealthDataHelper.requestHealthDataAccessIfNeeded() { completion in
            if completion {
                HealthDataHelper.saveHealthData(hkObjects) { (success, error) in
                    if !success {
                        self.errorMessage = NSLocalizedString("Cannot save data to Health: ", comment: "")
                        self.errorMessage += error != nil ? error!.localizedDescription : NSLocalizedString("Unspecified error", comment: "")
                        self.showingAlert = true
                    } else {
                        self.errorMessage = NSLocalizedString("Successfully exported data to Health", comment: "")
                        self.showingAlert = true
                    }
                }
            } else {
                if let errorMessage = HealthDataHelper.errorMessage {
                    self.errorMessage = errorMessage
                } else {
                    self.errorMessage = NSLocalizedString("Cannot save data to Health: Please authorize EasyFPU to write to Health in your Settings.", comment: "")
                }
                self.showingAlert = true
            }
        }
    }
}
