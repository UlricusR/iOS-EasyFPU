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
    @State var showingSheet = false
    @State var showingAlert = false
    @State var errorMessage = ""
    private let helpScreen = HelpScreen.mealExport
    
    @State var exportECarbs = true
    @State var exportTotalMealCarbs = false
    @State var exportTotalMealCalories = false
    
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
                    self.processHealthSample(delayInMinutes: 90, intervalInMinutes: 10)
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
                    self.isPresented = false
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
        let absorptionTimeInMinutes = Double(meal.fpus.getAbsorptionTime(absorptionScheme: absorptionScheme)) * 60.0
        let now = Date()
        let start = now.addingTimeInterval(delayInMinutes * 60.0)
        let end = start.addingTimeInterval(absorptionTimeInMinutes * 60.0)
        let numberOfECarbEntries = absorptionTimeInMinutes / intervalInMinutes
        let eCarbsAmount = meal.fpus.getExtendedCarbs() / numberOfECarbEntries
        let unit = HKUnit.gram()
        let objectType = HKObjectType.quantityType(forIdentifier: .dietaryCarbohydrates)!
        
        var time = start
        var hkObjects = [HKObject]()
        repeat {
            hkObjects.append(processQuantitySample(value: eCarbsAmount, unit: unit, start: time, end: time, sampleType: objectType))
            time = time.addingTimeInterval(intervalInMinutes * 60)
        } while time < end
        
        HealthDataHelper.requestHealthDataAccessIfNeeded(toShare: Set([objectType]), read: nil) { completion in
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
    
    private func processQuantitySample(value: Double, unit: HKUnit, start: Date, end: Date, sampleType: HKObjectType) -> HKObject {
        let quantity = HKQuantity(unit: unit, doubleValue: value)
        let hkQuantitySample = HKQuantitySample(type: sampleType as! HKQuantityType, quantity: quantity, start: start, end: end)
        return hkQuantitySample
    }
}
