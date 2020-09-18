//
//  AbsorptionSchemeEditor.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 30.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct AbsorptionSchemeEditor: View {
    @Binding var isPresented: Bool
    @ObservedObject var draftAbsorptionScheme: AbsorptionSchemeViewModel
    var editedAbsorptionScheme: AbsorptionScheme
    @State private var newMaxFpu: String = ""
    @State private var newAbsorptionTime: String = ""
    @State private var newAbsorptionBlockId: UUID?
    @State private var errorMessage: String = ""
    @State private var updateButton: Bool = false
    @State private var showingAlert: Bool = false
    @State private var absorptionBlocksToBeDeleted = [AbsorptionBlockViewModel]()
    @State private var showingScreen = false
    private let helpScreen = HelpScreen.absorptionSchemeEditor
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @ObservedObject private var keyboardGuardian = KeyboardGuardian()
    
    var body: some View {
        NavigationView {
            Form {
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
                }
                
                // The absorption block add/edit form
                Section(header: self.updateButton ? Text("Edit absorption block:") : Text("New absorption block:")) {
                    HStack {
                        TextField("Max. FPUs", text: $newMaxFpu).keyboardType(.decimalPad)
                        Text("FPU -")
                        TextField("Absorption time", text: $newAbsorptionTime).keyboardType(.decimalPad)
                        Button(action: {
                            if self.newAbsorptionBlockId == nil { // This is a new absorption block
                                if let newAbsorptionBlock = AbsorptionBlockViewModel(maxFpuAsString: self.newMaxFpu, absorptionTimeAsString: self.newAbsorptionTime, errorMessage: &self.errorMessage) {
                                    // Check validity of new absorption block
                                    if self.draftAbsorptionScheme.add(newAbsorptionBlock: newAbsorptionBlock, errorMessage: &self.errorMessage) {
                                        // Reset text fields
                                        self.newMaxFpu = ""
                                        self.newAbsorptionTime = ""
                                        self.updateButton = false
                                        
                                        // Broadcast change
                                        self.draftAbsorptionScheme.objectWillChange.send()
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
                                        
                                        // Broadcast change
                                        self.draftAbsorptionScheme.objectWillChange.send()
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
                
                Section(header: Text("e-Carbs Factor")) {
                    HStack {
                        Text("e-Carbs Factor")
                        TextField("e-Carbs Factor", text: $draftAbsorptionScheme.eCarbsFactorAsString).keyboardType(.numberPad).multilineTextAlignment(.trailing)
                        Text("g/FPU")
                    }
                }
                
                Section(header: Text("Absorption Time Parameters for e-Carbs")) {
                    HStack {
                        Text("Delay")
                        TextField("Delay", text: $draftAbsorptionScheme.delayLongAsString).keyboardType(.numberPad).multilineTextAlignment(.trailing)
                        Text("min")
                    }
                    
                    HStack {
                        Text("Interval")
                        TextField("Interval", text: $draftAbsorptionScheme.intervalLongAsString).keyboardType(.numberPad).multilineTextAlignment(.trailing)
                        Text("min")
                    }
                }
                    
                Section(header: Text("Absorption Time Parameters for Carbs")) {
                    HStack {
                        Text("Delay")
                        TextField("Delay", text: $draftAbsorptionScheme.delayMediumAsString).keyboardType(.numberPad).multilineTextAlignment(.trailing)
                        Text("min")
                    }
                    
                    HStack {
                        Text("Interval")
                        TextField("Interval", text: $draftAbsorptionScheme.intervalMediumAsString).keyboardType(.numberPad).multilineTextAlignment(.trailing)
                        Text("min")
                    }
                    
                    HStack {
                        Text("Duration")
                        TextField("Duration", text: $draftAbsorptionScheme.durationMediumAsString).keyboardType(.numberPad).multilineTextAlignment(.trailing)
                        Text("h")
                    }
                }
                
                // The reset button
                Button(action: {
                    self.resetToDefaults()
                }) {
                    Text("Reset to default")
                }
                    
                // Navigation bar
                .navigationBarTitle(Text("Absorption scheme"))
                .navigationBarItems(
                    leading: HStack {
                        Button(action: {
                            self.isPresented = false
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
                                let newCdAbsorptionBlock = AbsorptionBlock(context: self.managedObjectContext)
                                absorptionBlock.cdAbsorptionBlock = newCdAbsorptionBlock
                                let _ = absorptionBlock.updateCdAbsorptionBlock()
                                self.editedAbsorptionScheme.addToAbsorptionBlocks(newAbsorptionBlock: newCdAbsorptionBlock)
                            } else { // This is an existing absorption block, so just update values
                                let _ = absorptionBlock.updateCdAbsorptionBlock()
                            }
                        }
                        
                        // Remove deleted absorption blocks
                        for absorptionBlockToBeDeleted in self.absorptionBlocksToBeDeleted {
                            if absorptionBlockToBeDeleted.cdAbsorptionBlock != nil {
                                self.editedAbsorptionScheme.removeFromAbsorptionBlocks(absorptionBlockToBeDeleted: absorptionBlockToBeDeleted.cdAbsorptionBlock!)
                                self.managedObjectContext.delete(absorptionBlockToBeDeleted.cdAbsorptionBlock!)
                            }
                        }
                        
                        // Reset typical amounts to be deleted
                        self.absorptionBlocksToBeDeleted.removeAll()
                        
                        // Save new absorption blocks
                        try? AppDelegate.viewContext.save()
                        
                        // Save new user settings
                        if !(
                            UserSettings.set(UserSettings.UserDefaultsType.double(self.draftAbsorptionScheme.delayLong, UserSettings.UserDefaultsDoubleKey.absorptionTimeLongDelay), errorMessage: &self.errorMessage) &&
                            UserSettings.set(UserSettings.UserDefaultsType.double(self.draftAbsorptionScheme.intervalLong, UserSettings.UserDefaultsDoubleKey.absorptionTimeLongInterval), errorMessage: &self.errorMessage) &&
                            UserSettings.set(UserSettings.UserDefaultsType.double(self.draftAbsorptionScheme.delayMedium, UserSettings.UserDefaultsDoubleKey.absorptionTimeMediumDelay), errorMessage: &self.errorMessage) &&
                            UserSettings.set(UserSettings.UserDefaultsType.double(self.draftAbsorptionScheme.intervalMedium, UserSettings.UserDefaultsDoubleKey.absorptionTimeMediumInterval), errorMessage: &self.errorMessage) &&
                            UserSettings.set(UserSettings.UserDefaultsType.double(self.draftAbsorptionScheme.durationMedium, UserSettings.UserDefaultsDoubleKey.absorptionTimeMediumDuration), errorMessage: &self.errorMessage) &&
                            UserSettings.set(UserSettings.UserDefaultsType.double(self.draftAbsorptionScheme.eCarbsFactor, UserSettings.UserDefaultsDoubleKey.eCarbsFactor), errorMessage: &self.errorMessage)
                        ) {
                            self.showingAlert = true
                        } else {
                            // Set the dynamic user parameters and broadcast change
                            UserSettings.shared.absorptionTimeLongDelay = self.draftAbsorptionScheme.delayLong
                            UserSettings.shared.absorptionTimeLongInterval = self.draftAbsorptionScheme.intervalLong
                            UserSettings.shared.absorptionTimeMediumDelay = self.draftAbsorptionScheme.delayMedium
                            UserSettings.shared.absorptionTimeMediumInterval = self.draftAbsorptionScheme.intervalMedium
                            UserSettings.shared.absorptionTimeMediumDuration = self.draftAbsorptionScheme.durationMedium
                            UserSettings.shared.eCarbsFactor = self.draftAbsorptionScheme.eCarbsFactor
                            UserSettings.shared.objectWillChange.send()
                            
                            // Close sheet
                            self.isPresented = false
                        }
                    }) {
                        // Quit edit mode
                        Text("Done")
                    }
                )
            }
            .padding(.bottom, keyboardGuardian.currentHeight)
            .animation(.easeInOut(duration: 0.16))
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
            HelpView(isPresented: self.$showingScreen, helpScreen: self.helpScreen)
        }
    }
    
    func deleteAbsorptionBlock(at offsets: IndexSet) {
        if draftAbsorptionScheme.absorptionBlocks.count > 1 {
            offsets.forEach { index in
                let absorptionBlockToBeDeleted = self.draftAbsorptionScheme.absorptionBlocks[index]
                absorptionBlocksToBeDeleted.append(absorptionBlockToBeDeleted)
                self.draftAbsorptionScheme.absorptionBlocks.remove(at: index)
            }
            self.draftAbsorptionScheme.objectWillChange.send()
        } else {
            // We need to have at least one block left
            errorMessage = NSLocalizedString("At least one absorption block required", comment: "")
            showingAlert = true
        }
    }
    
    func resetToDefaults() {
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
        
        // Reset absorption time (for e-carbs) delay and interval
        draftAbsorptionScheme.delayLongAsString = DataHelper.doubleFormatter(numberOfDigits: 5).string(from: NSNumber(value: AbsorptionSchemeViewModel.absorptionTimeLongDelayDefault))!
        draftAbsorptionScheme.intervalLongAsString = DataHelper.doubleFormatter(numberOfDigits: 5).string(from: NSNumber(value: AbsorptionSchemeViewModel.absorptionTimeLongIntervalDefault))!
        
        // Reset absorption time (for carbs) delay and interval
        draftAbsorptionScheme.delayMediumAsString = DataHelper.doubleFormatter(numberOfDigits: 5).string(from: NSNumber(value: AbsorptionSchemeViewModel.absorptionTimeMediumDelayDefault))!
        draftAbsorptionScheme.intervalMediumAsString = DataHelper.doubleFormatter(numberOfDigits: 5).string(from: NSNumber(value: AbsorptionSchemeViewModel.absorptionTimeMediumIntervalDefault))!
        draftAbsorptionScheme.durationMediumAsString = DataHelper.doubleFormatter(numberOfDigits: 5).string(from: NSNumber(value: AbsorptionSchemeViewModel.absoprtionTimeMediumDurationDefault))!
        
        // Reset eCarbs factor
        draftAbsorptionScheme.eCarbsFactorAsString = DataHelper.doubleFormatter(numberOfDigits: 5).string(from: NSNumber(value: AbsorptionSchemeViewModel.eCarbsFactorDefault))!
        
        // Notify change
        draftAbsorptionScheme.objectWillChange.send()
    }
}
