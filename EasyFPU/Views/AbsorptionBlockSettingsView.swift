//
//  AbsorptionBlockSettingsView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 07/11/2024.
//  Copyright © 2024 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct AbsorptionBlockSettingsView: View {
    @ObservedObject var draftAbsorptionScheme: AbsorptionSchemeViewModel
    @Binding var absorptionBlocksToBeDeleted: [AbsorptionBlockViewModel]
    @State private var newMaxFpu: String = ""
    @State private var newAbsorptionTime: String = ""
    @State private var newAbsorptionBlockId: UUID?
    @State private var updateButton: Bool = false
    @Binding var errorMessage: String
    @Binding var showingAlert: Bool
    
    var body: some View {
        Section(header: Text("Absorption Blocks")) {
            // The list of absorption blocks
            List {
                Text("Tap to edit, swipe left to delete")
                    .font(.caption)
                ForEach(draftAbsorptionScheme.absorptionBlocks, id: \.self) { absorptionBlock in
                    HStack {
                        Text(absorptionBlock.maxFpuAsString)
                            .accessibilityIdentifierLeaf("MaxFpuValue")
                        Text("FPU -")
                            .accessibilityIdentifierLeaf("MaxFpuUnit")
                        Text(absorptionBlock.absorptionTimeAsString)
                            .accessibilityIdentifierLeaf("AbsorptionTimeValue")
                        Text("h")
                            .accessibilityIdentifierLeaf("AbsorptionTimeUnit")
                    }
                    .onTapGesture {
                        self.newMaxFpu = absorptionBlock.maxFpuAsString
                        self.newAbsorptionTime = absorptionBlock.absorptionTimeAsString
                        self.newAbsorptionBlockId = absorptionBlock.id
                        self.updateButton = true
                    }
                    .accessibilityIdentifierBranch("AbsorptionBlock" + absorptionBlock.absorptionTimeAsString)
                }
                .onDelete(perform: deleteAbsorptionBlock)
            }
            
            // The reset button
            Button("Reset to default") {
                self.resetAbsorptionSchemeToDefaults()
            }
            .accessibilityIdentifierLeaf("AbsorptionSchemeResetButton")
        }
        
        // The absorption block add/edit form
        Section(header: self.updateButton ? Text("Edit absorption block:") : Text("New absorption block:")) {
            HStack {
                CustomTextField(titleKey: "Max. FPUs", text: $newMaxFpu, keyboardType: .decimalPad)
                    .accessibilityIdentifierLeaf("AddFPUValue")
                Text("FPU -")
                    .accessibilityIdentifierLeaf("AddFPUUnit")
                CustomTextField(titleKey: "Absorption time", text: $newAbsorptionTime, keyboardType: .decimalPad)
                    .accessibilityIdentifierLeaf("AddAbsorptionTimeValue")
                Text("h")
                    .accessibilityIdentifierLeaf("AddAbsorptionTimeUnit")
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
                    Image(systemName: self.updateButton ? "checkmark.circle" : "plus.circle").foregroundStyle(self.updateButton ? .yellow : .green)
                }
                .accessibilityIdentifierLeaf("AddAbsorptionBlockButton")
            }
        }
    }
    
    private func deleteAbsorptionBlock(at offsets: IndexSet) {
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
    
    private func resetAbsorptionSchemeToDefaults() {
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
}
