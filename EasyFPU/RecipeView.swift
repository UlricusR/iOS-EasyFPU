//
//  RecipeView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 30/09/2024.
//  Copyright © 2024 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct RecipeView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var composedFoodItemVM: ComposedFoodItemViewModel
    @Binding var notificationState: RecipeListView.NotificationState?
    @State private var activeSheet: RecipeViewSheets.State?
    @State private var actionSheetIsPresented: Bool = false
    @State private var alertIsPresented: Bool = false
    
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
                    activeSheet = .editRecipe
                } else {
                    // No associated cdComposedFoodItem - this should not happen!
                    notificationState = .errorMessage(NSLocalizedString("No associated cdComposedFoodItem", comment: ""))
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
            Button("Delete", systemImage: "trash", role: .destructive) {
                if composedFoodItemVM.hasAssociatedComposedFoodItem() {
                    // Check for associated product
                    if composedFoodItemVM.hasAssociatedFoodItem() {
                        actionSheetIsPresented.toggle()
                    } else {
                        alertIsPresented.toggle()
                    }
                }
            }
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
        .alert(isPresented: $alertIsPresented) {
            Alert(
                title: Text("Delete recipe"),
                message: Text("Do you really want to delete this recipe? This cannot be undone!"),
                primaryButton: .default(
                    Text("Do not delete")
                ),
                secondaryButton: .destructive(
                    Text("Delete"),
                    action: deleteRecipeOnly
                )
            )
        }
        .actionSheet(isPresented: $actionSheetIsPresented) {
            ActionSheet(title: Text("Warning"), message: Text("There's an associated product, do you want to delete it as well?"), buttons: [
                .default(Text("Delete both")) {
                    deleteRecipeAndFoodItem()
                },
                .default(Text("Keep product")) {
                    deleteRecipeOnly()
                },
                .cancel()
            ])
        }
    }
    
    @ViewBuilder
    private func sheetContent(_ state: RecipeViewSheets.State) -> some View {
        switch state {
        case .editRecipe:
            if self.composedFoodItemVM.cdComposedFoodItem != nil {
                FoodItemComposerView(
                    composedFoodItemVM: self.composedFoodItemVM,
                    notificationState: $notificationState
                ).environment(\.managedObjectContext, managedObjectContext)
            } else {
                Text(NSLocalizedString("Fatal error: Couldn't find CoreData FoodItem, please inform the app developer", comment: ""))
            }
        case .exportRecipe:
            if let path = composedFoodItemVM.exportToURL() {
                ActivityView(activityItems: [path], applicationActivities: nil)
            } else {
                Text(NSLocalizedString("Could not generate data export", comment: ""))
            }
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
