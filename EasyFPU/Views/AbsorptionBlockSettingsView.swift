//
//  AbsorptionBlockSettingsView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 07/11/2024.
//  Copyright © 2024 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct AbsorptionBlockSettingsView: View {
    @State var absorptionScheme: AbsorptionScheme
    @Binding var activeAlert: SimpleAlertType?
    @Binding var showingAlert: Bool
    @State private var newMaxFpu: Int = 0
    @State private var newAbsorptionTime: Int = 0
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
                        Text("\(absorptionBlock.maxFpu)")
                            .accessibilityIdentifierLeaf("MaxFpuValue")
                        Text("FPU -")
                            .accessibilityIdentifierLeaf("MaxFpuUnit")
                        Text("\(absorptionBlock.absorptionTime)")
                            .accessibilityIdentifierLeaf("AbsorptionTimeValue")
                        Text("h")
                            .accessibilityIdentifierLeaf("AbsorptionTimeUnit")
                    }
                    .onTapGesture {
                        self.newMaxFpu = Int(absorptionBlock.maxFpu)
                        self.newAbsorptionTime = Int(absorptionBlock.absorptionTime)
                        self.newAbsorptionBlockId = absorptionBlock.id
                        self.updateButton = true
                    }
                    .accessibilityIdentifierBranch("AbsorptionBlock\(absorptionBlock.absorptionTime)")
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
                TextField("Max. FPUs", value: $newMaxFpu, format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .accessibilityIdentifierLeaf("AddFPUValue")
                Text("FPU -")
                    .accessibilityIdentifierLeaf("AddFPUUnit")
                TextField("Absorption time", value: $newAbsorptionTime, format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .accessibilityIdentifierLeaf("AddAbsorptionTimeValue")
                Text("h")
                    .accessibilityIdentifierLeaf("AddAbsorptionTimeUnit")
                Button(action: {
                    if self.newAbsorptionBlockId == nil { // This is a new absorption block
                        if let schemeAlert = absorptionScheme.add(maxFPU: self.newMaxFpu, absorptionTime: self.newAbsorptionTime) {
                            activeAlert = schemeAlert
                            self.showingAlert = true
                        } else {
                            // Reset text fields
                            self.newMaxFpu = 0
                            self.newAbsorptionTime = 0
                            self.updateButton = false
                        }
                    } else { // This is an existing typical amount
                        if let schemeAlert = absorptionScheme.replace(existingAbsorptionBlockID: self.newAbsorptionBlockId!, newMaxFpu: self.newMaxFpu, newAbsorptionTime: self.newAbsorptionTime) {
                            activeAlert = schemeAlert
                            self.showingAlert = true
                        } else {
                            // Reset text fields
                            self.newMaxFpu = 0
                            self.newAbsorptionTime = 0
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
