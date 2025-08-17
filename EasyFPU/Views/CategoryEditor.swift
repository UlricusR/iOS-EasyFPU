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
    enum AlertChoice {
        case simpleAlert(type: SimpleAlertType)
        case addCategory
    }
    
    @Binding var navigationPath: NavigationPath
    @State private var selectedFoodItemCategory: FoodItemCategory = .product
    @State private var showingAlert = false
    @State private var activeAlert: AlertChoice?
    @State private var name = ""
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
                                    withAnimation {
                                        // TODO check for duplicate names
                                        if editedCategory == nil { // New item
                                            _ = FoodCategory.create(id: UUID(), name: trimmedName, category: selectedFoodItemCategory)
                                        } else { // Editing existing item
                                            FoodCategory.update(editedCategory!, newName: trimmedName, newCategory: selectedFoodItemCategory)
                                            editedCategory = nil // Clear the edited category
                                        }
                                        name = "" // Clear the text field after saving
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
                                .foregroundStyle(editedCategory == category ? .gray : .black)
                                .swipeActions(edge: .trailing) {
                                    Button("Delete", systemImage: "trash") {
                                        withAnimation {
                                            FoodCategory.delete(category)
                                        }
                                    }
                                    .tint(.red)
                                    .accessibilityIdentifierLeaf("DeleteButton")
                                }
                                .swipeActions(edge: .leading) {
                                    Button("Edit", systemImage: "pencil") {
                                        withAnimation {
                                            editedCategory = category
                                            name = category.name // Pre-fill the text field with the category name
                                            proxy.scrollTo(0, anchor: .top) // Scroll to the text field
                                        }
                                    }
                                    .tint(.blue)
                                    .accessibilityIdentifierLeaf("EditButton")
                                }
                        }
                    }
                }
            }
        }
        .navigationTitle("Categories")
        .alert(alertTitle, isPresented: $showingAlert, presenting: activeAlert) {
            alertAction(for: $0)
        } message: {
            alertMessage(for: $0)
        }
    }
    
    @ViewBuilder
    private func alertMessage(for alert: AlertChoice) -> some View {
        switch alert {
        case let .simpleAlert(type: type):
            type.message()
        case .addCategory:
            TextField(text: $name) {
                Text("Name")
            }
        }
    }

    @ViewBuilder
    private func alertAction(for alert: AlertChoice) -> some View {
        switch alert {
        case let .simpleAlert(type: type):
            type.button()
        case .addCategory:
            Button("Cancel", role: .cancel) {}
            Button("Save") {
                // TODO check for duplicate names
                _ = FoodCategory.create(id: UUID(), name: name, category: selectedFoodItemCategory)
            }
            .disabled(self.name.isEmpty)
        }
    }
    
    private var alertTitle: LocalizedStringKey {
        switch activeAlert {
        case let .simpleAlert(type: type):
            LocalizedStringKey(type.title())
        case .addCategory:
            LocalizedStringKey("New category")
        case nil:
            ""
        }
    }
}
