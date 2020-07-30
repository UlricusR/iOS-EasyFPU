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
    var absorptionBlocks: [AbsorptionBlockViewModel] {
        var absorptionBlocks = [AbsorptionBlockViewModel]()
        for absorptionBlock in self.userData.absorptionScheme.absorptionBlocks {
            absorptionBlocks.append(AbsorptionBlockViewModel(from: absorptionBlock))
        }
        return absorptionBlocks.sorted()
    }
    @State var newMaxFpu: String = ""
    @State var newAbsorptionTime: String = ""
    @State var newAbsorptionBlockId: UUID?
    @State var errorMessage: String = ""
    @State var updateButton: Bool = false
    @State var showingAlert: Bool = false
    @State var absorptionBlocksToBeDeleted = [AbsorptionBlockViewModel]()
    @EnvironmentObject var userData: UserData
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Absorption blocks:")) {
                    HStack {
                        TextField("Max. FPUs", text: $newMaxFpu).keyboardType(.decimalPad)
                        Text("FPU -")
                        TextField("Absorption time", text: $newAbsorptionTime)
                        Button(action: {
                            if self.newAbsorptionBlockId == nil { // This is a new absorption block
                                if let newAbsorptionBlock = AbsorptionBlockViewModel(maxFpuAsString: self.newMaxFpu, absorptionTimeAsString: self.newAbsorptionTime, errorMessage: &self.errorMessage) {
                                    // Add new absorption block to absoprion blocks of absorption scheme
                                    self.draftAbsorptionScheme.absorptionBlocks.append(newAbsorptionBlock)
                                    
                                    // Reset text fields
                                    self.newMaxFpu = ""
                                    self.newAbsorptionTime = ""
                                    self.updateButton = false
                                    
                                    // Broadcast change
                                    self.draftAbsorptionScheme.objectWillChange.send()
                                } else {
                                    self.showingAlert = true
                                }
                            } else { // This is an existing typical amount
                                guard let index = self.draftAbsorptionScheme.absorptionBlocks.firstIndex(where: { $0.id == self.newAbsorptionBlockId }) else {
                                    fatalError("Fatal error: Could not identify absorption block")
                                }
                                self.draftAbsorptionScheme.absorptionBlocks[index].maxFpuAsString = self.newMaxFpu
                                self.draftAbsorptionScheme.absorptionBlocks[index].absorptionTimeAsString = self.newAbsorptionTime
                                
                                // Reset text fields and typical amount id
                                self.newMaxFpu = ""
                                self.newAbsorptionTime = ""
                                self.updateButton = false
                                self.newAbsorptionBlockId = nil
                                
                                // Broadcast change
                                self.draftAbsorptionScheme.objectWillChange.send()
                            }
                        }) {
                            Image(systemName: self.updateButton ? "checkmark.circle" : "plus.circle").foregroundColor(self.updateButton ? .yellow : .green)
                        }
                    }
                }
                List {
                    ForEach(absorptionBlocks, id: \.self) { absorptionBlock in
                        HStack {
                            Text(absorptionBlock.maxFpuAsString)
                            Text("FPU -")
                            Text(absorptionBlock.absorptionTimeAsString)
                            Text("h")
                        }
                    }
                }
                .navigationBarTitle(Text("Edit Absorption Scheme"))
                .navigationBarItems(
                    leading: Button(action: {
                        self.isPresented = false
                    }) {
                        Text("Cancel")
                    },
                    trailing: Button(action: {
                        // Update typical amounts
                        for absorptionBlock in self.draftAbsorptionScheme.absorptionBlocks {
                            // Check if it's an existing core data entry
                            if absorptionBlock.cdAbsorptionBlock == nil { // This is a new absorption block
                                let newCdAbsorptionBlock = AbsorptionBlock(context: self.managedObjectContext)
                                absorptionBlock.cdAbsorptionBlock = newCdAbsorptionBlock
                                let _ = absorptionBlock.updateCdAbsorptionBlock()
                                self.userData.absorptionScheme.addToAbsorptionBlocks(newAbsorptionBlock: newCdAbsorptionBlock)
                            } else { // This is an existing typical amount, so just update values
                                let _ = absorptionBlock.updateCdAbsorptionBlock()
                            }
                        }
                        
                        // Remove deleted typical amounts
                        for absorptionBlockToBeDeleted in self.absorptionBlocksToBeDeleted {
                            if absorptionBlockToBeDeleted.cdAbsorptionBlock != nil {
                                self.userData.absorptionScheme.removeFromAbsorptionBlocks(absorptionBlockToBeDeleted: absorptionBlockToBeDeleted.cdAbsorptionBlock!)
                                self.managedObjectContext.delete(absorptionBlockToBeDeleted.cdAbsorptionBlock!)
                            }
                        }
                        
                        // Reset typical amounts to be deleted
                        self.absorptionBlocksToBeDeleted.removeAll()
                        
                        // Save new food item
                        self.saveContext()
                        
                        // Close sheet
                        self.isPresented = false
                    }) {
                        // Quit edit mode
                        Text("Done")
                    }
                )
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Data alert"),
                message: Text(self.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    func deleteAbsorptionBlock(at offsets: IndexSet) {
        offsets.forEach { index in
            let absorptionBlockToBeDeleted = self.absorptionBlocks[index]
            absorptionBlocksToBeDeleted.append(absorptionBlockToBeDeleted)
            guard let originalIndex = self.draftAbsorptionScheme.absorptionBlocks.firstIndex(where: { $0.id == absorptionBlockToBeDeleted.id }) else {
                self.errorMessage = NSLocalizedString("Cannot find absorption block: ", comment: "") + absorptionBlockToBeDeleted.maxFpuAsString
                return
            }
            self.draftAbsorptionScheme.absorptionBlocks.remove(at: originalIndex)
        }
        self.draftAbsorptionScheme.objectWillChange.send()
    }
    
    func saveContext() {
        if self.managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                print("Error saving managed object context: \(error)")
            }
        }
    }
}
