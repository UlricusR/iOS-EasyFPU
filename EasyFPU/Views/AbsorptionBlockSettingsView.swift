//
//  AbsorptionBlockSettingsView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 07/11/2024.
//  Copyright © 2024 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct AbsorptionBlockSettingsView: View {
    @ObservedObject var absorptionScheme: AbsorptionSchemeViewModel
    @Binding var activeAlert: SimpleAlertType?
    @Binding var showingAlert: Bool
    @State private var newMaxFpu: String = ""
    @State private var newAbsorptionTime: String = ""
    @State private var newAbsorptionBlockId: UUID?
    @State private var updateButton: Bool = false
    
    var body: some View {
        Section(header: Text("Absorption Blocks")) {
            // The list of absorption blocks
            List {
                Text("Tap to edit, swipe left to delete")
                    .font(.caption)
                ForEach(absorptionScheme.absorptionBlocks, id: \.self) { absorptionBlock in
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
                var errorMessage = ""
                if !absorptionScheme.resetToDefaultAbsorptionBlocks(errorMessage: &errorMessage) {
                    activeAlert = .fatalError(message: errorMessage)
                    showingAlert = true
                }
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
                        var blockAlert: SimpleAlertType? = nil
                        if let newAbsorptionBlock = AbsorptionBlockViewModel(maxFpuAsString: self.newMaxFpu, absorptionTimeAsString: self.newAbsorptionTime, activeAlert: &blockAlert) {
                            // Check validity of new absorption block
                            if let schemeAlert = self.absorptionScheme.add(newAbsorptionBlock: newAbsorptionBlock) {
                                activeAlert = schemeAlert
                                self.showingAlert = true
                            } else {
                                // Reset text fields
                                self.newMaxFpu = ""
                                self.newAbsorptionTime = ""
                                self.updateButton = false
                            }
                        } else {
                            activeAlert = blockAlert
                            self.showingAlert = true
                        }
                    } else { // This is an existing typical amount
                        if let schemeAlert = absorptionScheme.replace(existingAbsorptionBlockID: self.newAbsorptionBlockId!, newMaxFpuAsString: self.newMaxFpu, newAbsorptionTimeAsString: self.newAbsorptionTime) {
                            activeAlert = schemeAlert
                            self.showingAlert = true
                        } else {
                            // Reset text fields
                            self.newMaxFpu = ""
                            self.newAbsorptionTime = ""
                            self.updateButton = false
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
        if absorptionScheme.absorptionBlocks.count > 1 {
            offsets.forEach { index in
                if !absorptionScheme.removeAbsorptionBlock(at: index) {
                    activeAlert = .fatalError(message: "Absorption block index out of range.")
                    showingAlert = true
                }
            }
        } else {
            // We need to have at least one block left
            activeAlert = .notice(message: "At least one absorption block required")
            showingAlert = true
        }
    }
}
