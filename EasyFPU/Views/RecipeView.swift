//
//  RecipeView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 30/09/2024.
//  Copyright © 2024 Ulrich Rüth. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers

struct RecipeView: View {
    enum AlertChoice {
        case simpleAlert(type: SimpleAlertType)
        case confirmDelete
    }
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @Binding var navigationPath: NavigationPath
    @ObservedObject var composedFoodItem: ComposedFoodItem
    @State private var showingAlert = false
    @State private var activeAlert: AlertChoice?
    @State private var isConfirming = false
    
    var body: some View {
        // Name, favorite
        HStack {
            Text(composedFoodItem.name).font(.headline)
            if composedFoodItem.favorite { Image(systemName: "star.fill").foregroundStyle(.yellow).imageScale(.small) }
            Spacer()
        }
        .accessibilityIdentifierLeaf("RecipeName")
        .swipeActions(edge: .trailing) {
            // Editing the recipe
            Button("Edit", systemImage: "pencil") {
                // Switch to Ingredients tab
                navigationPath.append(RecipeListView.RecipeNavigationDestination.EditRecipe(recipe: composedFoodItem))
            }
            .tint(.blue)
            .accessibilityIdentifierLeaf("EditButton")
            
            // Duplicating the recipe
            Button("Duplicate", systemImage: "document.on.document") {
                _ = composedFoodItem.duplicate(saveContext: true)
            }
            .tint(.indigo)
            .accessibilityIdentifierLeaf("DuplicateButton")
            
            // Delete the recipe
            Button("Delete", systemImage: "trash") {
                // Check for associated product
                if composedFoodItem.foodItem != nil {
                    isConfirming.toggle()
                } else {
                    activeAlert = .confirmDelete
                    showingAlert = true
                }
            }
            .tint(.red)
            .accessibilityIdentifierLeaf("DeleteButton")
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            // Sharing the recipe
            ShareLink(
                item: DataWrapper(
                    dataModelVersion: .version2,
                    foodItems: [],
                    composedFoodItems: [composedFoodItem]
                ),
                preview: .init("Share")
            )
            .tint(.green)
            .accessibilityIdentifierLeaf("ShareButton")
        }
        .alert(alertTitle, isPresented: $showingAlert, presenting: activeAlert) {
            alertAction(for: $0)
        } message: {
            alertMessage(for: $0)
        }
        .confirmationDialog(
            "Warning",
            isPresented: $isConfirming
        ) {
            Button("Delete both") {
                deleteRecipeAndFoodItem()
            }
            Button("Keep product") {
                deleteRecipeOnly()
            }
            Button("Cancel", role: .cancel) {
                isConfirming.toggle()
            }
        } message: {
            Text("There's an associated product, do you want to delete it as well?")
        }
    }
    
    @ViewBuilder
    private func alertMessage(for alert: AlertChoice) -> some View {
        switch alert {
        case let .simpleAlert(type: type):
            type.message()
        case .confirmDelete:
            Text("Do you really want to delete this recipe? This cannot be undone!")
        }
    }

    @ViewBuilder
    private func alertAction(for alert: AlertChoice) -> some View {
        switch alert {
        case let .simpleAlert(type: type):
            type.button()
        case .confirmDelete:
            Button("Do not delete", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteRecipeOnly()
            }
        }
    }
    
    private var alertTitle: LocalizedStringKey {
        switch activeAlert {
        case let .simpleAlert(type: type):
            LocalizedStringKey(type.title())
        case .confirmDelete:
            LocalizedStringKey("Delete recipe")
        case nil:
            ""
        }
    }
    
    private func deleteRecipeOnly() {
        withAnimation(.default) {
            ComposedFoodItem.delete(composedFoodItem, includeAssociatedFoodItem: false)
        }
    }
    
    private func deleteRecipeAndFoodItem() {
        withAnimation(.default) {
            ComposedFoodItem.delete(composedFoodItem, includeAssociatedFoodItem: true)
        }
    }
}
