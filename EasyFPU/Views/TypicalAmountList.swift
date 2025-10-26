//
//  TypicalAmountList.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 16/10/2025.
//  Copyright © 2025 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct TypicalAmountList: View {
    private enum Field: Int, Hashable {
        case newTypicalAmount, editedTypicalAmount
    }
    
    @ObservedObject var editedCDFoodItem: FoodItem
    @Binding var addNewTypicalAmount: Bool
    @Binding var editedTypicalAmountID: UUID?
    @Binding var showingAlert: Bool
    @Binding var activeAlert: FoodItemEditor.AlertChoice?
    
    @State private var newTypicalAmount = ""
    @State private var newTypicalAmountComment = ""
    @FocusState private var focusedField: Field?
    
    private var isNewTypicalAmount: Bool {
        editedTypicalAmountID == nil
    }
    
    var body: some View {
        // Add new typical amount
        if addNewTypicalAmount {
            HStack {
                TextField("Amount", text: $newTypicalAmount)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .focused($focusedField, equals: .newTypicalAmount)
                    .onSubmit {
                        self.addTypicalAmount()
                    }
                    .submitLabel(.done)
                    .accessibilityIdentifierLeaf("EditTypicalAmountValue")
                Text("g")
                    .accessibilityIdentifierLeaf("AmountUnit")
                TextField("Comment", text: $newTypicalAmountComment)
                    .onSubmit {
                        self.addTypicalAmount()
                    }
                    .submitLabel(.done)
                    .accessibilityIdentifierLeaf("EditTypicalAmountComment")
                Button {
                    self.addTypicalAmount()
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .imageScale(.large)
                        .foregroundStyle(.green)
                }
                .accessibilityIdentifierLeaf("EditTypicalAmountButton")
            }
        } else {
            HStack {
                Button("Add", systemImage: "plus.circle") {
                    // Check if currently editing another typical amount
                    if editedTypicalAmountID != nil {
                        // Save the editing typical amount first
                        self.addTypicalAmount()
                    }
                    
                    withAnimation {
                        // Show the new typical amount fields
                        self.addNewTypicalAmount = true
                        self.focusedField = .newTypicalAmount
                    }
                }
                .accessibilityIdentifierLeaf("AddTypicalAmountButton")
            }
        }
        
        // The existing typical amounts list
        try? DynamicList(
            filterKey: "foodItem",
            filterValue: editedCDFoodItem,
            sortKey: "amount",
            sortAscending: true,
            emptyStateMessage: NSLocalizedString("You have not added any typical amounts yet.", comment: ""),
        ) { (typicalAmount: TypicalAmount) in
            HStack {
                if editedTypicalAmountID != nil && editedTypicalAmountID! == typicalAmount.id {
                    // Editing an existing typical amount
                    HStack {
                        TextField(LocalizedStringKey("Edit typical amount"), text: $newTypicalAmount, prompt: Text("Edit typical amount"))
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField, equals: .editedTypicalAmount)
                            .onSubmit {
                                self.addTypicalAmount()
                            }
                            .submitLabel(.done)
                            .accessibilityIdentifierLeaf("EditTypicalAmountValue")
                        Text("g")
                            .accessibilityIdentifierLeaf("AmountUnit")
                        TextField("Comment", text: $newTypicalAmountComment)
                            .onSubmit {
                                self.addTypicalAmount()
                            }
                            .submitLabel(.done)
                            .accessibilityIdentifierLeaf("EditTypicalAmountComment")
                        Button {
                            self.addTypicalAmount()
                        } label: {
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .foregroundStyle(.green)
                        }
                        .accessibilityIdentifierLeaf("EditTypicalAmountButton")
                    }
                } else {
                    // Displaying an existing typical amount
                    HStack {
                        Text(typicalAmount.amount, format: .number)
                            .accessibilityIdentifierLeaf("TypicalAmountValue")
                        Text("g")
                            .accessibilityIdentifierLeaf("TypicalAmountUnit")
                        Text(typicalAmount.comment ?? "")
                            .accessibilityIdentifierLeaf("TypicalAmountComment")
                    }
                    .swipeActions(edge: .trailing) {
                        // The edit button
                        Button("Edit", systemImage: "pencil") {
                            // Check if currently adding a new typical amount
                            if addNewTypicalAmount {
                                // Save the new typical amount first
                                self.addTypicalAmount()
                            }
                            
                            // Prepare for editing
                            selectTypicalAmount(typicalAmount)
                        }
                        .tint(.blue)
                        .accessibilityIdentifierLeaf("EditButton")
                        
                        // The delete button
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            withAnimation {
                                // First clear edit fields if filled
                                if self.addNewTypicalAmount {
                                    deselectTypicalAmount()
                                }
                                
                                // Then delete typical amount
                                TypicalAmount.delete(typicalAmount)
                            }
                        }
                        .tint(.red)
                        .accessibilityIdentifierLeaf("DeleteButton")
                    }
                }
            }
            .accessibilityIdentifierBranch("TAmount\(typicalAmount.amount)")
        }
    }
    
    private func selectTypicalAmount(_ typicalAmount: TypicalAmount) {
        self.newTypicalAmount = String(typicalAmount.amount)
        self.newTypicalAmountComment = typicalAmount.comment ?? ""
        withAnimation {
            self.editedTypicalAmountID = typicalAmount.id
            self.focusedField = .editedTypicalAmount
        }
    }
    
    private func deselectTypicalAmount() {
        self.newTypicalAmount = ""
        self.newTypicalAmountComment = ""
        withAnimation {
            self.editedTypicalAmountID = nil
            self.addNewTypicalAmount = false
            self.focusedField = nil
        }
    }
    
    private func addTypicalAmount() {
        // If no amount is entered at all, we just leave the edit mode
        if self.newTypicalAmount.isEmpty {
            deselectTypicalAmount()
            return
        }
        
        // Check for valid amount
        var errorMessage = ""
        var newTAAmount: Int = 0
        let result = DataHelper.checkForPositiveInt(valueAsString: self.newTypicalAmount, allowZero: false)
        switch result {
        case .success(let amount):
            newTAAmount = amount
        case .failure(let err):
            errorMessage = err.evaluate()
            activeAlert = .simpleAlert(type: .error(message: errorMessage))
            showingAlert = true
            return
        }
        
        // Check if amount already exists
        if let existingTAs = editedCDFoodItem.typicalAmounts?.allObjects as? [TypicalAmount] {
            if let existingTA = existingTAs.first(where: { $0.amount == newTAAmount }) {
                // If we are editing an existing typical amount, we allow to keep the same amount
                if isNewTypicalAmount || existingTA.id != editedTypicalAmountID {
                    errorMessage = NSLocalizedString("A typical amount with this value already exists.", comment: "")
                    activeAlert = .simpleAlert(type: .error(message: errorMessage))
                    showingAlert = true
                    return
                }
            }
        }
        
        // Remove blank spaces from comment
        self.newTypicalAmountComment = self.newTypicalAmountComment.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Save or update
        if isNewTypicalAmount { // This is a new typical amount
            if let moc = editedCDFoodItem.managedObjectContext {
                let newTA = TypicalAmount.create(amount: Int64(newTAAmount), comment: self.newTypicalAmountComment, context: moc)
                editedCDFoodItem.addToTypicalAmounts(newTA)
            }
        } else { // This is an existing typical amount
            guard let cdTypicalAmount = TypicalAmount.getTypicalAmountByID(id: editedTypicalAmountID!) else {
                activeAlert = .simpleAlert(type: .fatalError(message: "Could not identify typical amount."))
                showingAlert = true
                return
            }
            cdTypicalAmount.amount = Int64(newTAAmount)
            cdTypicalAmount.comment = self.newTypicalAmountComment
        }
        
        // Clear UI
        deselectTypicalAmount()
    }
}
