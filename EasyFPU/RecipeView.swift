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
    @Binding var selectedTab: Int
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
                // Prepare the composed product by filling it with the selected ComposedFoodItem
                UserSettings.shared.composedProduct = composedFoodItemVM
                
                // Switch to Ingredients tab
                selectedTab = MainView.Tab.ingredients.rawValue
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
        case .exportRecipe:
            if let path = composedFoodItemVM.exportToURL() {
                ActivityView(activityItems: [path], applicationActivities: nil)
            } else {
                Text(NSLocalizedString("Could not generate data export", comment: ""))
            }
        }
    }
}
