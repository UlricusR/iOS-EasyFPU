//
//  CategoryEditor.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 13/08/2025.
//  Copyright © 2025 Ulrich Rüth. All rights reserved.
//

import SwiftUI
import CoreData

struct CategoryEditor: View {
    private enum Field: Int, Hashable {
        case newName, editedName
    }
    
    @Binding var navigationPath: NavigationPath
    @State private var selectedFoodItemCategory: FoodItemCategory = .product
    @State private var showingAlert = false
    @State private var activeAlert: SimpleAlertType?
    @State private var name = ""
    @State private var isNew: Bool = true
    @State private var editedCategory: FoodCategory?
    @State private var addNewCategory: Bool = false
    @FocusState private var focusedField: Field?
    
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
                // Add category
                if addNewCategory {
                    HStack {
                        TextField(LocalizedStringKey("New category"), text: $name, prompt: Text("New category"))
                            .focused($focusedField, equals: .newName)
                            .onSubmit {
                                self.addCategory()
                            }
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
                            withAnimation {
                                // Reset editedCategory (could still be active)
                                name = ""
                                editedCategory = nil
                                focusedField = nil // Dismiss the keyboard if active
                                
                                // Show the text field
                                isNew = true
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
                    let textField = TextField(LocalizedStringKey("Edit category"), text: $name, prompt: Text("Edit category"))
                    if editedCategory != nil && category == editedCategory {
                        HStack {
                            textField
                                .focused($focusedField, equals: .editedName)
                                .onSubmit {
                                    addCategory()
                                }
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
                            .foregroundStyle(editedCategory == category ? .secondary : .primary)
                            .swipeActions(edge: .trailing) {
                                // The edit button
                                Button("Edit", systemImage: "pencil") {
                                    withAnimation {
                                        // Reset addNewCategory (could still be active)
                                        addNewCategory = false
                                        
                                        // Prepare for editing
                                        name = category.name
                                        isNew = false
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
                if editedCategory == nil { // New item
                    _ = FoodCategory.create(id: UUID(), name: trimmedName, category: selectedFoodItemCategory, saveContext: true)
                } else { // Editing existing item
                    editedCategory!.update(newName: trimmedName, newCategory: selectedFoodItemCategory, saveContext: true)
                    editedCategory = nil // Clear the edited category
                }
                name = "" // Clear the text field after saving
                addNewCategory = false // Hide the text field
                isNew = true // Reset to new mode
                focusedField = nil // Dismiss the keyboard
            }
        }
    }
}
