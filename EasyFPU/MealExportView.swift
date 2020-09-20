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
    @Binding var isPresented: Bool
    var meal: MealViewModel
    var absorptionScheme: AbsorptionScheme
    @ObservedObject var carbsEntries = CarbsRegime.default
    @State var showingSheet = false
    @State var showingAlert = false
    @State var errorMessage = ""
    private let helpScreen = HelpScreen.mealExport
    
    @State var exportTotalMealCalories = UserSettings.getValue(for: UserSettings.UserDefaultsBoolKey.exportTotalMealCalories) ?? false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Please choose the data to export:").padding()
                
                Toggle(isOn: $carbsEntries.includeECarbs) {
                    Text("Extended Carbs")
                }
                .padding([.leading, .trailing, .top])
                
                Toggle(isOn: $carbsEntries.includeTotalMealCarbs) {
                    Text("Total Meal Carbs")
                }
                .padding([.leading, .trailing])
                
                Toggle(isOn: $exportTotalMealCalories) {
                    Text("Total Meal Calories")
                }.padding([.leading, .trailing, .bottom])
                
                Button(action: {
                    self.exportHealthSample()
                }) {
                    Text("Export")
                }.padding()
                
                // The carbs preview
                if !carbsEntries.hkObjects.isEmpty {
                    Text("Preview of exported carbs in g").padding([.top, .leading, .trailing])
                    HealthExportPreview(carbsEntries: self.carbsEntries).padding()
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
                    if
                        !(UserSettings.set(UserSettings.UserDefaultsType.bool(self.carbsEntries.includeECarbs, UserSettings.UserDefaultsBoolKey.exportECarbs), errorMessage: &self.errorMessage) &&
                            UserSettings.set(UserSettings.UserDefaultsType.bool(self.carbsEntries.includeTotalMealCarbs, UserSettings.UserDefaultsBoolKey.exportTotalMealCarbs), errorMessage: &self.errorMessage) &&
                        UserSettings.set(UserSettings.UserDefaultsType.bool(self.exportTotalMealCalories, UserSettings.UserDefaultsBoolKey.exportTotalMealCalories), errorMessage: &self.errorMessage))
                    {
                        // Something went terribly wrong - inform user
                        self.showingAlert = true
                    } else {
                        // Close sheet
                        self.isPresented = false
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
            HelpView(isPresented: self.$showingSheet, helpScreen: self.helpScreen)
        }
    }
    
    private func processHealthSample() {
        guard let absorptionTimeInHours = meal.fpus.getAbsorptionTime(absorptionScheme: absorptionScheme) else {
            errorMessage = NSLocalizedString("Fatal error, cannot export data, please contact the app developer: Absorption Scheme has no Absorption Blocks", comment: "")
            showingAlert = true
            return
        }
        self.carbsEntries.meal = meal
        self.carbsEntries.absorptionTimeInMinutes = Double(absorptionTimeInHours) * 60.0
        self.carbsEntries.recalculate()
    }
    
    private func exportHealthSample() {
        var hkObjects = [HKObject]()
        hkObjects.append(contentsOf: carbsEntries.hkObjects)
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
