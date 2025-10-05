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
    @Binding var navigationPath: NavigationPath
    @State private var selectedFoodItemCategory: FoodItemCategory = .product
    @State private var showingAlert = false
    @State private var activeAlert: SimpleAlertType?
    @State private var name = ""
    @State private var isNew: Bool = true
    @State private var editedCategory: FoodCategory?
    
    var body: some View {
        VStack {
            Picker("Food Item Category", selection: $selectedFoodItemCategory) {
                ForEach(FoodItemCategory.allCases, id: \.self) { category in
                    Text(NSLocalizedString(category.rawValue, comment: "")).tag(category)
                }
            }
            .pickerStyle(.segmented)
            .padding()
                
            ScrollViewReader { proxy in
                Form {
                    Section(header: Text("Add/Edit Category"), footer: Text("Hit return to save")) {
                        // Add new category text field
                        TextField(LocalizedStringKey("New category"), text: $name, prompt: Text("New category"))
                            .id(0)
                            .onSubmit {
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
                                        isNew = true // Reset to new mode
                                    }
                                }
                            }
                    }
                    
                    Section(header: Text("Existing Categories")) {
                        // List of existing categories
                        try? DynamicList(
                            filterKey: "category",
                            filterValue: selectedFoodItemCategory.rawValue,
                            sortKey: "name",
                            sortAscending: true,
                            emptyStateMessage: NSLocalizedString("Oops! You have not added any categories yet.", comment: ""),
                        ) { (category: FoodCategory) in
                            Text(category.name)
                                .foregroundStyle(editedCategory == category ? .secondary : .primary)
                                .swipeActions(edge: .trailing) {
                                    // The edit button
                                    Button("Edit", systemImage: "pencil") {
                                        withAnimation {
                                            editedCategory = category
                                            name = category.name // Pre-fill the text field with the category name
                                            isNew = false
                                            proxy.scrollTo(0, anchor: .top) // Scroll to the text field
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
}
