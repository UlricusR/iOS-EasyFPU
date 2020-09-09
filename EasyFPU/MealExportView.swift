//
//  MealExportView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 08.09.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct MealExportView: View {
    @Binding var isPresented: Bool
    var meal: MealViewModel
    @ObservedObject var absorptionScheme: AbsorptionScheme
    @State var showingSheet = false
    @State var showingAlert = false
    @State var errorMessage = ""
    private let helpScreen = HelpScreen.mealExport
    
    @State var exportECarbs = UserSettings.getValue(for: UserSettings.UserDefaultsBoolKey.exportECarbs) ?? true
    @State var exportTotalMealCarbs = UserSettings.getValue(for: UserSettings.UserDefaultsBoolKey.exportTotalMealCarbs) ?? false
    @State var exportTotalMealCalories = UserSettings.getValue(for: UserSettings.UserDefaultsBoolKey.exportTotalMealCalories) ?? false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Do you really want to export the extended carbs to Health?").padding()
                
                Text("Please choose the data to export:").padding()
                Text("If you're using the Loop app for your diabetes pump therapy, the recommendation is to only export extended carbs.").font(.caption).padding([.leading, .trailing, .bottom])
                
                Toggle(isOn: $exportECarbs) {
                    Text("Extended Carbs")
                }.padding([.leading, .trailing, .top])
                Toggle(isOn: $exportTotalMealCarbs) {
                    Text("Total Meal Carbs")
                }.padding([.leading, .trailing])
                Toggle(isOn: $exportTotalMealCalories) {
                    Text("Total Meal Calories")
                }.padding([.leading, .trailing, .bottom])
                
                Button(action: {
                    let delay = UserSettings.getValue(for: UserSettings.UserDefaultsDoubleKey.absorptionTimeLongDelay) ?? AbsorptionSchemeViewModel.absorptionTimeLongDelayDefault
                    let interval = UserSettings.getValue(for: UserSettings.UserDefaultsDoubleKey.absorptionTimeLongInterval) ?? AbsorptionSchemeViewModel.absorptionTimeLongIntervalDefault
                    self.processHealthSample(delayInMinutes: delay, intervalInMinutes: interval)
                }) {
                    Text("Export")
                }.padding()
                
                Spacer()
            }
            .navigationBarTitle("Export to Health")
            .navigationBarItems(
                leading: Button(action: {
                    self.showingSheet = true
                }) {
                    Image(systemName: "questionmark.circle").imageScale(.large)
                },
                trailing: Button(action: {
                    // Store UserDefaults
                    if
                        !(UserSettings.set(UserSettings.UserDefaultsType.bool(self.exportECarbs, UserSettings.UserDefaultsBoolKey.exportECarbs), errorMessage: &self.errorMessage) &&
                        UserSettings.set(UserSettings.UserDefaultsType.bool(self.exportTotalMealCarbs, UserSettings.UserDefaultsBoolKey.exportTotalMealCarbs), errorMessage: &self.errorMessage) &&
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
    
    private func processHealthSample(delayInMinutes: Double, intervalInMinutes: Double) {
        if !exportECarbs && !exportTotalMealCalories && !exportTotalMealCarbs {
            errorMessage = NSLocalizedString("Please select at least one entry to export", comment: "")
            showingAlert = true
            return
        }
        
        guard let hkObjects = HealthDataHelper.processHealthSample(for: meal, with: absorptionScheme, exportECarbs: exportECarbs, exportTotalMealCarbs: exportTotalMealCarbs, exportTotalMealCalories: exportTotalMealCalories, delayInMinutes: delayInMinutes, intervalInMinutes: intervalInMinutes, errorMessage: &errorMessage) else {
            showingAlert = true
            return
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
