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
    @State var newMaxFpu: String = ""
    @State var newAbsorptionTime: String = ""
    @State var newAbsorptionBlockId: UUID?
    @State var errorMessage: String = ""
    @State var updateButton: Bool = false
    @State var showingAlert: Bool = false
    @State var absorptionBlocksToBeDeleted = [AbsorptionBlockViewModel]()
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var body: some View {
        NavigationView {
            VStack {
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
                
                // The absorption block add/edit form
                Form {
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
                                        fatalError("Fatal error: Could not identify absorption block")
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
                }
                
                // The reset button
                Button(action: {
                    self.resetToDefaults()
                }) {
                    Text("Reset to default")
                }
                    
                // Navigation bar
                .navigationBarTitle(Text("Edit Absorption Scheme"))
                .navigationBarItems(
                    leading: Button(action: {
                        self.isPresented = false
                    }) {
                        Text("Cancel")
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
                            } else { // This is an existing typical amount, so just update values
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
                        
                        // Save new food item
                        try? AppDelegate.viewContext.save()
                        
                        // Close sheet
                        self.isPresented = false
                    }) {
                        // Quit edit mode
                        Text("Done")
                    }
                )
            }
        }
            
        // Alert
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Data alert"),
                message: Text(self.errorMessage),
                dismissButton: .default(Text("OK"))
            )
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
        let defaultAbsorptionBlocks = DataHelper.loadDefaultAbsorptionBlocks()
        absorptionBlocksToBeDeleted = draftAbsorptionScheme.absorptionBlocks
        draftAbsorptionScheme.absorptionBlocks.removeAll()
        
        for absorptionBlock in defaultAbsorptionBlocks {
            let _ = draftAbsorptionScheme.add(newAbsorptionBlock: AbsorptionBlockViewModel(from: absorptionBlock), errorMessage: &errorMessage)
        }
        
        draftAbsorptionScheme.objectWillChange.send()
    }
}
