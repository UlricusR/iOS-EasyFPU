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
    @State var activeSheet: RecipeViewSheets.State?

    var body: some View {
        // Name, favorite
        HStack {
            Text(composedFoodItemVM.name).font(.headline)
            if composedFoodItemVM.favorite { Image(systemName: "star.fill").foregroundColor(.yellow).imageScale(.small) }
            Spacer()
        }
        .contextMenu(menuItems: {
            // Editing the recipe
            Button(action: {
                if composedFoodItemVM.cdComposedFoodItem != nil {
                    // Prepare the composed product by filling it with the selected ComposedFoodItem
                    UserSettings.shared.composedProduct = ComposedFoodItemViewModel(from: composedFoodItemVM.cdComposedFoodItem!)
                    
                    // Switch to Ingredients tab
                    activeSheet = .editRecipe
                } else {
                    // No associated cdComposedFoodItem - this should not happen!
                    notificationState = .errorMessage(NSLocalizedString("No associated cdComposedFoodItem", comment: ""))
                }
            }) {
                Text("Edit")
            }
            
            // Duplicating the recipe
            Button(action: {
                composedFoodItemVM.duplicate()
            }) {
                Text("Duplicate")
            }
            
            // Sharing the recipe
            Button(action: {
                activeSheet = .exportRecipe
            }) {
                Text("Share")
            }
            
            // Delete the recipe
            Button(action: {
                if let composedFoodItemToBeDeleted = composedFoodItemVM.cdComposedFoodItem {
                    ComposedFoodItem.delete(composedFoodItemToBeDeleted)
                }
            }) {
                Text("Delete")
            }
        })
        .sheet(item: $activeSheet) {
            sheetContent($0)
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
}
