//
//  MealDetail.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 23.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI
import HealthKit

struct MealDetail: View {
    var absorptionScheme: AbsorptionScheme
    var meal: MealViewModel
    @State private var showingSheet = false
    private let helpScreen = HelpScreen.mealDetails
    @State private var errorMessage = ""
    @State private var showingAlert = false
    @State private var showActionSheet = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(NSLocalizedString(self.meal.name, comment: "")).font(.headline).multilineTextAlignment(.center)
                
                Button(action: {
                    self.showingSheet = true
                }) {
                    Image(systemName: "questionmark.circle").imageScale(.large)
                }
                Button(action: {
                    self.showActionSheet = true
                }) {
                    Image(systemName: "square.and.arrow.up").imageScale(.large)
                }.padding(.leading)
            }.padding([.leading, .trailing, .bottom])
            
            VStack(alignment: .leading) {
                Text("Total nutritional values").font(.headline)
            
                HStack {
                    Text(NumberFormatter().string(from: NSNumber(value: self.meal.amount))!)
                    Text("g")
                    Text("Amount consumed")
                }
                
                HStack {
                    Text(FoodItemViewModel.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: self.meal.calories))!)
                    Text("kcal")
                }
                
                HStack {
                    Text(FoodItemViewModel.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: self.meal.carbs))!)
                    Text("g Carbs")
                }
                
                HStack {
                    Text(FoodItemViewModel.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: self.meal.fpus.fpu))!)
                    Text("FPU")
                }
                
                HStack {
                    Text(FoodItemViewModel.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: self.meal.fpus.getExtendedCarbs()))!)
                    Text("g Extended Carbs")
                }
                
                HStack {
                    Text(NumberFormatter().string(from: NSNumber(value: self.meal.fpus.getAbsorptionTime(absorptionScheme: self.absorptionScheme)))!)
                    Text("h Absorption Time")
                }
                
                HStack {
                    Text("Recommended delay of extended carbs:")
                    Text("1.5h")
                }.padding(.top)
            }.padding().foregroundColor(.red)
            
            List {
                Text("Included food items:").font(.headline)
                ForEach(meal.foodItems, id: \.self) { foodItem in
                    MealItemView(foodItem: foodItem, absorptionScheme: self.absorptionScheme, fontSizeDetails: .caption, foregroundColorName: Color.blue)
                }
            }
            
            Spacer()
        }
        .sheet(isPresented: self.$showingSheet) {
            HelpView(isPresented: self.$showingSheet, helpScreen: self.helpScreen)
        }
        .alert(isPresented: self.$showingAlert) {
            Alert(
                title: Text("Notice"),
                message: Text(self.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .actionSheet(isPresented: self.$showActionSheet) {
            ActionSheet(title: Text("Export to Health"), message: Text("Do you really want to export the extended carbs to Health?"), buttons: [
                .default(Text("Export"), action: {
                    self.processHealthSample(delayInMinutes: 90, intervalInMinutes: 10)
                }),
                .cancel()
            ])
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
                        self.errorMessage = NSLocalizedString("Successfully exported extended carbs to Health", comment: "")
                        self.showingAlert = true
                    }
                }
            } else {
                self.errorMessage = NSLocalizedString("Cannot save data to Health: Please authorize EasyFPU to write to Health in your Settings.", comment: "")
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
