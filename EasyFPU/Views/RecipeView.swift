//
//  RecipeView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 30/09/2024.
//  Copyright © 2024 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct RecipeView: View {
    enum SheetState: Identifiable {
        case exportRecipe
        
        var id: SheetState { self }
    }
    
    enum AlertChoice {
        case simpleAlert(type: SimpleAlertType)
        case confirmDelete
    }
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @Binding var navigationPath: NavigationPath
    @ObservedObject var composedFoodItemVM: ComposedFoodItemViewModel
    @State private var activeSheet: SheetState?
    @State private var showingAlert = false
    @State private var activeAlert: AlertChoice?
    @State private var isConfirming = false
    
    var body: some View {
        // Name, favorite
        HStack {
            Text(composedFoodItemVM.name).font(.headline)
            if composedFoodItemVM.favorite { Image(systemName: "star.fill").foregroundStyle(.yellow).imageScale(.small) }
            Spacer()
        }
        .accessibilityIdentifierLeaf("RecipeName")
        .swipeActions(edge: .trailing) {
            // Editing the recipe
            Button("Edit", systemImage: "pencil") {
                if composedFoodItemVM.cdComposedFoodItem != nil {
                    // Prepare the composed product by filling it with the selected ComposedFoodItem
                    UserSettings.shared.composedProduct = ComposedFoodItemViewModel(from: composedFoodItemVM.cdComposedFoodItem!)
                    
                    // Switch to Ingredients tab
                    navigationPath.append(RecipeListView.RecipeNavigationDestination.EditRecipe(recipe: composedFoodItemVM))
                } else {
                    // No associated cdComposedFoodItem - this should not happen!
                    activeAlert = .simpleAlert(type: .fatalError(message: "No associated cdComposedFoodItem"))
                    showingAlert = true
                }
            }
            .tint(.blue)
            .accessibilityIdentifierLeaf("EditButton")
            
            // Duplicating the recipe
            Button("Duplicate", systemImage: "document.on.document") {
                composedFoodItemVM.duplicate()
            }
            .tint(.indigo)
            .accessibilityIdentifierLeaf("DuplicateButton")
            
            // Delete the recipe
            Button("Delete", systemImage: "trash") {
                if composedFoodItemVM.hasAssociatedComposedFoodItem() {
                    // Check for associated product
                    if composedFoodItemVM.hasAssociatedFoodItem() {
                        isConfirming.toggle()
                    } else {
                        activeAlert = .confirmDelete
                        showingAlert = true
                    }
                }
            }
            .tint(.red)
            .accessibilityIdentifierLeaf("DeleteButton")
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            // Sharing the recipe
            Button("Share", systemImage: "square.and.arrow.up") {
                activeSheet = .exportRecipe
            }
            .tint(.green)
            .accessibilityIdentifierLeaf("ShareButton")
        }
        .sheet(item: $activeSheet) {
            sheetContent($0)
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
    private func sheetContent(_ state: SheetState) -> some View {
        switch state {
        case .exportRecipe:
            if let path = composedFoodItemVM.exportToURL() {
                ActivityView(activityItems: [path], applicationActivities: nil)
            } else {
                Text(NSLocalizedString("Could not generate data export", comment: ""))
            }
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
            composedFoodItemVM.delete(includeAssociatedFoodItem: false)
        }
    }
    
    private func deleteRecipeAndFoodItem() {
        withAnimation(.default) {
            composedFoodItemVM.delete(includeAssociatedFoodItem: true)
        }
    }
}
