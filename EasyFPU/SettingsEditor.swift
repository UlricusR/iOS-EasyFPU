//
//  AbsorptionSchemeEditor.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 30.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct SettingsEditor: View {
    @ObservedObject var draftAbsorptionScheme: AbsorptionSchemeViewModel
    var editedAbsorptionScheme: AbsorptionScheme
    @ObservedObject var userSettings = UserSettings.shared
    @State private var newMaxFpu: String = ""
    @State private var newAbsorptionTime: String = ""
    @State private var newAbsorptionBlockId: UUID?
    @State private var errorMessage: String = ""
    @State private var updateButton: Bool = false
    @State private var showingAlert: Bool = false
    @State private var absorptionBlocksToBeDeleted = [AbsorptionBlockViewModel]()
    @State private var selectedFoodDatabaseType: FoodDatabaseType = UserSettings.getFoodDatabaseType()
    @State private var searchWorldwide: Bool = UserSettings.shared.searchWorldwide
    @State private var selectedCountry: String = UserSettings.getCountryCode() ?? ""
    @State private var showingScreen = false
    private let helpScreen = HelpScreen.absorptionSchemeEditor
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        NavigationView {
            Form {
                // Sugars
                Section(header: Text("Absorption Time Parameters for Sugars")) {
                    Toggle("Treat sugars separately", isOn: $draftAbsorptionScheme.treatSugarsSeparately)
                    
                    if draftAbsorptionScheme.treatSugarsSeparately {
                        HStack {
                            Text("Delay")
                            CustomTextField(titleKey: "Delay", text: $draftAbsorptionScheme.delaySugarsAsString, keyboardType: .numberPad).multilineTextAlignment(.trailing)
                            Text("min")
                        }
                        
                        HStack {
                            Text("Duration")
                            CustomTextField(titleKey: "Duration", text: $draftAbsorptionScheme.durationSugarsAsString, keyboardType: .numberPad).multilineTextAlignment(.trailing)
                            Text("h")
                        }
                        
                        HStack {
                            Text("Interval")
                            CustomTextField(titleKey: "Interval", text: $draftAbsorptionScheme.intervalSugarsAsString, keyboardType: .numberPad).multilineTextAlignment(.trailing)
                            Text("min")
                        }
                        
                        // The reset button
                        Button(action: {
                            self.resetSugarsToDefaults()
                        }) {
                            Text("Reset to default")
                        }
                    }
                }
                
                // Carbs
                Section(header: Text("Absorption Time Parameters for Carbs")) {
                    HStack {
                        Text("Delay")
                        CustomTextField(titleKey: "Delay", text: $draftAbsorptionScheme.delayCarbsAsString, keyboardType: .numberPad).multilineTextAlignment(.trailing)
                        Text("min")
                    }
                    
                    HStack {
                        Text("Duration")
                        CustomTextField(titleKey: "Duration", text: $draftAbsorptionScheme.durationCarbsAsString, keyboardType: .numberPad).multilineTextAlignment(.trailing)
                        Text("h")
                    }
                    
                    HStack {
                        Text("Interval")
                        CustomTextField(titleKey: "Interval", text: $draftAbsorptionScheme.intervalCarbsAsString, keyboardType: .numberPad).multilineTextAlignment(.trailing)
                        Text("min")
                    }
                    
                    // The reset button
                    Button(action: {
                        self.resetCarbsToDefaults()
                    }) {
                        Text("Reset to default")
                    }
                }
                
                // e-Carbs
                Section(header: Text("Absorption Time Parameters for e-Carbs")) {
                    HStack {
                        Text("Delay")
                        CustomTextField(titleKey: "Delay", text: $draftAbsorptionScheme.delayECarbsAsString, keyboardType: .numberPad).multilineTextAlignment(.trailing)
                        Text("min")
                    }
                    
                    HStack {
                        Text("e-Carbs Factor")
                        CustomTextField(titleKey: "e-Carbs Factor", text: $draftAbsorptionScheme.eCarbsFactorAsString, keyboardType: .numberPad).multilineTextAlignment(.trailing)
                        Text("g/FPU")
                    }
                    
                    HStack {
                        Text("Interval")
                        CustomTextField(titleKey: "Interval", text: $draftAbsorptionScheme.intervalECarbsAsString, keyboardType: .numberPad).multilineTextAlignment(.trailing)
                        Text("min")
                    }
                    
                    // The reset button
                    Button(action: {
                        self.resetECarbsToDefaults()
                    }) {
                        Text("Reset to default")
                    }
                }
                
                Section(header: Text("Absorption Blocks")) {
                    // The list of absorption blocks
                    List {
                        Text("Tap to edit, swipe left to delete").font(.caption)
                        ForEach(draftAbsorptionScheme.absorptionBlocks, id: \.self) { absorptionBlock in
                            HStack {
                                Text(absorptionBlock.maxFpuAsString)
                                Text("FPU -")
                                Text(absorptionBlock.absorptionTimeAsString)
                                Text("h")
                            }
                            .onTapGesture {
                                self.newMaxFpu = absorptionBlock.maxFpuAsString
                                self.newAbsorptionTime = absorptionBlock.absorptionTimeAsString
                                self.newAbsorptionBlockId = absorptionBlock.id
                                self.updateButton = true
                            }
                        }
                        .onDelete(perform: deleteAbsorptionBlock)
                    }
                    
                    // The reset button
                    Button(action: {
                        self.resetAbsorptionSchemeToDefaults()
                    }) {
                        Text("Reset to default")
                    }
                }
                
                // The absorption block add/edit form
                Section(header: self.updateButton ? Text("Edit absorption block:") : Text("New absorption block:")) {
                    HStack {
                        CustomTextField(titleKey: "Max. FPUs", text: $newMaxFpu, keyboardType: .decimalPad)
                        Text("FPU -")
                        CustomTextField(titleKey: "Absorption time", text: $newAbsorptionTime, keyboardType: .decimalPad)
                        Text("h")
                        Button(action: {
                            if self.newAbsorptionBlockId == nil { // This is a new absorption block
                                if let newAbsorptionBlock = AbsorptionBlockViewModel(maxFpuAsString: self.newMaxFpu, absorptionTimeAsString: self.newAbsorptionTime, errorMessage: &self.errorMessage) {
                                    // Check validity of new absorption block
                                    if self.draftAbsorptionScheme.add(newAbsorptionBlock: newAbsorptionBlock, errorMessage: &self.errorMessage) {
                                        // Reset text fields
                                        self.newMaxFpu = ""
                                        self.newAbsorptionTime = ""
                                        self.updateButton = false
                                    } else {
                                        self.showingAlert = true
                                    }
                                } else {
                                    self.showingAlert = true
                                }
                            } else { // This is an existing typical amount
                                guard let index = self.draftAbsorptionScheme.absorptionBlocks.firstIndex(where: { $0.id == self.newAbsorptionBlockId }) else {
                                    self.errorMessage = NSLocalizedString("Fatal error: Could not identify absorption block", comment: "")
                                    self.showingAlert = true
                                    return
                                }
                                let existingAbsorptionBlock = self.draftAbsorptionScheme.absorptionBlocks[index]
                                self.draftAbsorptionScheme.absorptionBlocks.remove(at: index)
                                if let updatedAbsorptionBlock = AbsorptionBlockViewModel(maxFpuAsString: self.newMaxFpu, absorptionTimeAsString: self.newAbsorptionTime, errorMessage: &self.errorMessage) {
                                    if self.draftAbsorptionScheme.add(newAbsorptionBlock: updatedAbsorptionBlock, errorMessage: &self.errorMessage) {
                                        // Add old absorption block to the list of blocks to be deleted
                                        self.absorptionBlocksToBeDeleted.append(existingAbsorptionBlock)
                                        
                                        // Reset text fields
                                        self.newMaxFpu = ""
                                        self.newAbsorptionTime = ""
                                        self.updateButton = false
                                    } else {
                                        // Undo deletion of block and show alert
                                        self.draftAbsorptionScheme.absorptionBlocks.insert(existingAbsorptionBlock, at: index)
                                        self.showingAlert = true
                                    }
                                }
                            }
                        }) {
                            Image(systemName: self.updateButton ? "checkmark.circle" : "plus.circle").foregroundColor(self.updateButton ? .yellow : .green)
                        }
                    }
                }
                
                // Other settings
                Section(header: Text("Other Parameters")) {
                    HStack {
                        Stepper("Alert duration between exports", value: $userSettings.alertPeriodAfterExportInMinutes, in: 0...60, step: 5)
                        Text(String(UserSettings.shared.alertPeriodAfterExportInMinutes))
                        Text("min")
                    }
                }
                
                // Food database
                Section(header: Text("Food Database")) {
                    // The food database
                    Picker("Database", selection: $selectedFoodDatabaseType) {
                        ForEach(FoodDatabaseType.allCases) { foodDatabaseType in
                            Text(foodDatabaseType.rawValue).tag(foodDatabaseType)
                        }
                    }
                    
                    // For OpenFoodFacts: The country code
                    if selectedFoodDatabaseType == .openFoodFacts {
                        Toggle("Search worldwide", isOn: self.$searchWorldwide)
                        if !searchWorldwide {
                            HStack {
                                NavigationLink("Country", destination: CountryPicker(code: self.$selectedCountry))
                                Text(self.selectedCountry)
                            }
                        }
                    }
                }
            }
            .animation(.easeInOut(duration: 0.16))
            
            // Navigation bar
            .navigationBarTitle(Text("Settings"))
            .navigationBarItems(
                leading: HStack {
                    Button(action: {
                        presentation.wrappedValue.dismiss()
                    }) {
                        Text("Cancel")
                    }
                    
                    Button(action: {
                        self.showingScreen = true
                    }) {
                        Image(systemName: "questionmark.circle").imageScale(.large)
                    }.padding()
                },
                
                trailing: Button(action: {
                    // Update absorption block
                    for absorptionBlock in self.draftAbsorptionScheme.absorptionBlocks {
                        // Check if it's an existing core data entry
                        if absorptionBlock.cdAbsorptionBlock == nil { // This is a new absorption block
                            let newCdAbsorptionBlock = AbsorptionBlock.create(from: absorptionBlock)
                            self.editedAbsorptionScheme.addToAbsorptionBlocks(newAbsorptionBlock: newCdAbsorptionBlock)
                        } else { // This is an existing absorption block, so just update values
                            let _ = absorptionBlock.updateCdAbsorptionBlock()
                        }
                    }
                    
                    // Remove deleted absorption blocks
                    for absorptionBlockToBeDeleted in self.absorptionBlocksToBeDeleted {
                        if absorptionBlockToBeDeleted.cdAbsorptionBlock != nil {
                            AbsorptionBlock.remove(absorptionBlockToBeDeleted.cdAbsorptionBlock!, from: editedAbsorptionScheme)
                        }
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
                        UserSettings.set(UserSettings.UserDefaultsType.bool(self.draftAbsorptionScheme.treatSugarsSeparately, UserSettings.UserDefaultsBoolKey.treatSugarsSeparately), errorMessage: &self.errorMessage) &&
                        UserSettings.set(UserSettings.UserDefaultsType.string(self.selectedFoodDatabaseType.rawValue, UserSettings.UserDefaultsStringKey.foodDatabase), errorMessage: &self.errorMessage) &&
                        UserSettings.set(UserSettings.UserDefaultsType.bool(self.searchWorldwide, UserSettings.UserDefaultsBoolKey.searchWorldwide), errorMessage: &self.errorMessage) &&
                        UserSettings.set(UserSettings.UserDefaultsType.string(self.selectedCountry, UserSettings.UserDefaultsStringKey.countryCode), errorMessage: &errorMessage)
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
                        UserSettings.shared.foodDatabase = FoodDatabaseType.getFoodDatabase(type: self.selectedFoodDatabaseType)
                        UserSettings.shared.searchWorldwide = self.searchWorldwide
                        UserSettings.shared.countryCode = self.selectedCountry
                        
                        // Close sheet
                        presentation.wrappedValue.dismiss()
                    }
                }) {
                    // Quit edit mode
                    Text("Done")
                }
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
            
        // Alert
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Data alert"),
                message: Text(self.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .sheet(isPresented: self.$showingScreen) {
            HelpView(helpScreen: self.helpScreen)
        }
    }
    
    func deleteAbsorptionBlock(at offsets: IndexSet) {
        if draftAbsorptionScheme.absorptionBlocks.count > 1 {
            offsets.forEach { index in
                let absorptionBlockToBeDeleted = self.draftAbsorptionScheme.absorptionBlocks[index]
                absorptionBlocksToBeDeleted.append(absorptionBlockToBeDeleted)
                self.draftAbsorptionScheme.absorptionBlocks.remove(at: index)
            }
        } else {
            // We need to have at least one block left
            errorMessage = NSLocalizedString("At least one absorption block required", comment: "")
            showingAlert = true
        }
    }
    
    func resetAbsorptionSchemeToDefaults() {
        // Reset absorption blocks
        guard let defaultAbsorptionBlocks = DataHelper.loadDefaultAbsorptionBlocks(errorMessage: &errorMessage) else {
            self.showingAlert = true
            return
        }
        absorptionBlocksToBeDeleted = draftAbsorptionScheme.absorptionBlocks
        draftAbsorptionScheme.absorptionBlocks.removeAll()
        
        for absorptionBlock in defaultAbsorptionBlocks {
            let _ = draftAbsorptionScheme.add(newAbsorptionBlock: AbsorptionBlockViewModel(from: absorptionBlock), errorMessage: &errorMessage)
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
