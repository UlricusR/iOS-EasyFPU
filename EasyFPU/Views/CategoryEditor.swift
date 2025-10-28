//
//  CategoryEditor.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 13/08/2025.
//  Copyright © 2025 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct CategoryEditor: View {
    private enum Field: Int, Hashable {
        case newName, editedName
    }
    
    @State private var selectedFoodItemCategory: FoodItemCategory = .product
    @State private var showingAlert = false
    @State private var activeAlert: SimpleAlertType?
    @State private var name = ""
    @State private var editedCategory: FoodCategory?
    @State private var addNewCategory: Bool = false
    @FocusState private var focusedField: Field?
    
    private var isNew: Bool {
        editedCategory == nil
    }
    
    var body: some View {
        VStack {
            Picker("Food Item Category", selection: $selectedFoodItemCategory) {
                ForEach(FoodItemCategory.allCases, id: \.self) { category in
                    Text(NSLocalizedString(category.rawValue, comment: "")).tag(category)
                }
            }
            .pickerStyle(.segmented)
            .padding()
                
            Form {
                // Add new category
                if addNewCategory {
                    HStack {
                        TextField(LocalizedStringKey("New category"), text: $name, prompt: Text("New category"))
                            .focused($focusedField, equals: .newName)
                            .onSubmit {
                                self.addCategory()
                            }
                            .submitLabel(.done)
                            .accessibilityIdentifierLeaf("NewCategoryTextField")
                        Button {
                            self.addCategory()
                        } label: {
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .foregroundStyle(.green)
                        }
                        .accessibilityIdentifierLeaf("EditCategoryButton")
                    }
                } else {
                    HStack {
                        Button("Add", systemImage: "plus.circle") {
                            // Check if currently editing an existing category
                            if editedCategory != nil {
                                // Save the edited category first
                                addCategory()
                            }
                            
                            withAnimation {
                                // Show the text field
                                addNewCategory = true
                                focusedField = .newName
                            }
                        }
                        .accessibilityIdentifierLeaf("AddCategoryButton")
                    }
                }
                
                // List of existing categories
                try? DynamicList(
                    filterKey: "category",
                    filterValue: selectedFoodItemCategory.rawValue,
                    sortKey: "name",
                    sortAscending: true,
                    emptyStateMessage: NSLocalizedString("Oops! You have not added any categories yet.", comment: ""),
                ) { (category: FoodCategory) in
                    if editedCategory != nil && category == editedCategory {
                        HStack {
                            TextField(LocalizedStringKey("Edit category"), text: $name, prompt: Text("Edit category"))
                                .focused($focusedField, equals: .editedName)
                                .onSubmit {
                                    addCategory()
                                }
                                .submitLabel(.done)
                                .accessibilityIdentifierLeaf("EditCategoryTextField")
                            Button {
                                addCategory()
                            } label: {
                                Image(systemName: "checkmark.circle.fill")
                                    .imageScale(.large)
                                    .foregroundStyle(.green)
                            }
                            .accessibilityIdentifierLeaf("EditCategoryButton")
                        }
                    } else {
                        Text(category.name)
                            .swipeActions(edge: .trailing) {
                                // The edit button
                                Button("Edit", systemImage: "pencil") {
                                    // Check if currently adding new category
                                    if addNewCategory {
                                        // Add the new category first
                                        self.addCategory()
                                    }
                                    
                                    withAnimation {
                                        // Prepare for editing
                                        name = category.name
                                        editedCategory = category
                                        focusedField = .editedName
                                    }
                                }
                                .tint(.blue)
                                .accessibilityIdentifierLeaf("EditButton")
                                
                                // The delete button
                                Button("Delete", systemImage: "trash") {
                                    if category.hasRelatedItems() {
                                        activeAlert = .warning(message: NSLocalizedString("Cannot delete category which is in use!", comment: ""))
                                        showingAlert = true
                                        return
                                    }
                                    withAnimation {
                                        FoodCategory.delete(category, saveContext: true)
                                    }
                                }
                                .tint(.red)
                                .accessibilityIdentifierLeaf("DeleteButton")
                            }
                    }
                }
            }
        }
        .navigationTitle("Categories")
        .alert(
            activeAlert?.title() ?? "Notice",
            isPresented: $showingAlert,
            presenting: activeAlert
        ) { activeAlert in
            activeAlert.button()
        } message: { activeAlert in
            activeAlert.message()
        }
    }
    
    private func addCategory() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedName.isEmpty {
            if FoodCategory.exists(name: trimmedName, category: selectedFoodItemCategory, isNew: isNew) {
                activeAlert = .warning(message: NSLocalizedString("Category already exists!", comment: ""))
                showingAlert = true
                return
            }
            
            // Save the new or edited category
            withAnimation {
                if isNew {
                    _ = FoodCategory.create(id: UUID(), name: trimmedName, category: selectedFoodItemCategory, saveContext: true)
                } else if let editedCategory = editedCategory { // Editing existing item
                    editedCategory.update(newName: trimmedName, newCategory: selectedFoodItemCategory, saveContext: true)
                }
            }
        }
        
        resetUI()
    }
    
    private func resetUI() {
        name = "" // Clear the text field after saving
        addNewCategory = false // Hide the text field
        editedCategory = nil // Clear the edited category
        
        withAnimation {
            focusedField = nil // Dismiss the keyboard
        }
    }
}
