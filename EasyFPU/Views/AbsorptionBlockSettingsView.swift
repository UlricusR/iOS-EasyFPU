//
//  AbsorptionBlockSettingsView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 07/11/2024.
//  Copyright © 2024 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct AbsorptionBlockSettingsView: View {
    private enum Field: Int, Hashable {
        case newBlock, editedBlock
    }
    
    var absorptionScheme: AbsorptionScheme
    @Binding var activeAlert: SimpleAlertType?
    @Binding var showingAlert: Bool
    
    @State private var addNewBlock: Bool = false
    @State private var editedAbsorptionBlockId: UUID?
    @State private var newMaxFpu: Int = 0
    @State private var newAbsorptionTime: Int = 0
    @FocusState private var focusedField: Field?
    
    private var isNewBlock: Bool {
        editedAbsorptionBlockId == nil
    }
    
    @FetchRequest(
        entity: AbsorptionBlock.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \AbsorptionBlock.maxFpu, ascending: true)
        ]
    ) var absorptionBlocks: FetchedResults<AbsorptionBlock>
    
    var body: some View {
        Section(header: Text("Absorption Blocks")) {
            if addNewBlock {
                HStack {
                    HStack {
                        TextField("Max. FPUs", value: $newMaxFpu, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField, equals: .newBlock)
                            .onSubmit {
                                self.addAbsorptionBlock()
                            }
                            .submitLabel(.done)
                            .accessibilityIdentifierLeaf("AddFPUValue")
                        Text("FPU -")
                            .accessibilityIdentifierLeaf("AddFPUUnit")
                        TextField("Absorption time", value: $newAbsorptionTime, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .onSubmit {
                                self.addAbsorptionBlock()
                            }
                            .submitLabel(.done)
                            .accessibilityIdentifierLeaf("AddAbsorptionTimeValue")
                        Text("h")
                            .accessibilityIdentifierLeaf("AddAbsorptionTimeUnit")
                        Button {
                            self.addAbsorptionBlock()
                        } label: {
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .foregroundStyle(.green)
                        }
                        .accessibilityIdentifierLeaf("AddAbsorptionBlockButton")
                    }
                }
            } else {
                HStack {
                    Button("Add", systemImage: "plus.circle") {
                        // Check if currently editing another absorption block
                        if editedAbsorptionBlockId != nil {
                            // Save the editing typical amount first
                            self.addAbsorptionBlock()
                        }
                        
                        withAnimation {
                            // Show the new typical amount fields
                            self.addNewBlock = true
                            self.focusedField = .newBlock
                        }
                    }
                    .accessibilityIdentifierLeaf("AddAbsorptionBlockButton")
                }
            }
            
            // The list of absorption blocks
            List {
                ForEach(absorptionBlocks, id: \.self) { absorptionBlock in
                    if editedAbsorptionBlockId != nil && editedAbsorptionBlockId! == absorptionBlock.id {
                        HStack {
                            // Editing an existing absorption block
                            TextField("Max. FPUs", value: $newMaxFpu, format: .number)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .focused($focusedField, equals: .editedBlock)
                                .onSubmit {
                                    self.addAbsorptionBlock()
                                }
                                .submitLabel(.done)
                                .accessibilityIdentifierLeaf("AddFPUValue")
                            Text("FPU -")
                                .accessibilityIdentifierLeaf("AddFPUUnit")
                            TextField("Absorption time", value: $newAbsorptionTime, format: .number)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .onSubmit {
                                    self.addAbsorptionBlock()
                                }
                                .submitLabel(.done)
                                .accessibilityIdentifierLeaf("AddAbsorptionTimeValue")
                            Text("h")
                                .accessibilityIdentifierLeaf("AddAbsorptionTimeUnit")
                            Button {
                                self.addAbsorptionBlock()
                            } label: {
                                Image(systemName: "checkmark.circle.fill")
                                    .imageScale(.large)
                                    .foregroundStyle(.green)
                            }
                            .accessibilityIdentifierLeaf("AddAbsorptionBlockButton")
                        }
                    } else {
                        // Displaying an existing absorption block
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
                        .swipeActions(edge: .trailing) {
                            // The edit button
                            Button("Edit", systemImage: "pencil") {
                                // Check if currently adding a new absorption block
                                if addNewBlock {
                                    // Save the new absorption block first
                                    self.addAbsorptionBlock()
                                }
                                
                                // Prepare for editing
                                selectAbsorptionBlock(absorptionBlock)
                            }
                            .tint(.blue)
                            .accessibilityIdentifierLeaf("EditButton")
                            
                            // The delete button
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                withAnimation {
                                    // First clear edit fields if filled
                                    if self.addNewBlock {
                                        deselectAbsorptionBlock()
                                    }
                                    
                                    // Then delete typical amount
                                    deleteAbsorptionBlock(absorptionBlock)
                                }
                            }
                            .tint(.red)
                            .accessibilityIdentifierLeaf("DeleteButton")
                        }
                        .accessibilityIdentifierBranch("AbsorptionBlock\(absorptionBlock.absorptionTime)")
                    }
                }
            }
            
            // The reset button
            Button("Reset to default") {
                deselectAbsorptionBlock()
                var errorMessage = ""
                if !absorptionScheme.resetToDefaultAbsorptionBlocks(saveContext: true, errorMessage: &errorMessage) {
                    activeAlert = .fatalError(message: errorMessage)
                    showingAlert = true
                }
            }
            .accessibilityIdentifierLeaf("AbsorptionSchemeResetButton")
        }
    }
    
    private func selectAbsorptionBlock(_ absorptionBlock: AbsorptionBlock) {
        self.newMaxFpu = Int(absorptionBlock.maxFpu)
        self.newAbsorptionTime = Int(absorptionBlock.absorptionTime)
        withAnimation {
            self.editedAbsorptionBlockId = absorptionBlock.id
            self.focusedField = .editedBlock
        }
    }
    
    private func deselectAbsorptionBlock() {
        self.newMaxFpu = 0
        self.newAbsorptionTime = 0
        withAnimation {
            self.editedAbsorptionBlockId = nil
            self.addNewBlock = false
            self.focusedField = nil
        }
    }
    
    private func addAbsorptionBlock() {
        if isNewBlock { // This is a new absorption block
            // Try to add the new absorption block to the scheme
            if let schemeAlert = absorptionScheme.add(
                maxFpu: self.newMaxFpu,
                absorptionTime: self.newAbsorptionTime,
                saveContext: true
            ) {
                // Addition failed, show alert
                activeAlert = schemeAlert
                self.showingAlert = true
            } else {
                // Reset text fields
                deselectAbsorptionBlock()
            }
        } else { // This is an existing absorption block
            if let schemeAlert = absorptionScheme.replace(
                existingAbsorptionBlockID: self.editedAbsorptionBlockId!,
                newMaxFpu: self.newMaxFpu,
                newAbsorptionTime: self.newAbsorptionTime,
                saveContext: true
            ) {
                activeAlert = schemeAlert
                self.showingAlert = true
            } else {
                // Reset text fields
                deselectAbsorptionBlock()
            }
        }
    }
    
    private func deleteAbsorptionBlock(_ absorptionBlock: AbsorptionBlock) {
        if absorptionBlocks.count > 1 {
            AbsorptionBlock.remove(absorptionBlock, saveContext: true)
        } else {
            // We need to have at least one block left
            activeAlert = .notice(message: "At least one absorption block required")
            showingAlert = true
        }
    }
}
