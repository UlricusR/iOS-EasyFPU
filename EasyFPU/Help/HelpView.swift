//
//  HelpView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 30.08.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

enum HelpScreen: String {
    case productMaintenanceList = "Product Maintenance List"
    case productSelectionList = "Product Selection List"
    case ingredientMaintenanceList = "Ingredient Maintenance List"
    case ingredientSelectionList = "Ingredient Selection List"
    case recipeList = "Recipe List"
    case foodItemSelector = "Select Food Item"
    case foodItemEditor = "Edit Food Item"
    case mealDetails = "Calculate meal"
    case absorptionSchemeEditor = "Edit Absorption Scheme"
    case mealExport = "Export to Health"
    case foodItemComposer = "Food Item Composer"
}

struct HelpView: View {
    @Environment(\.presentationMode) var presentation
    var helpScreen: HelpScreen
    
    var body: some View {
        NavigationStack {
            ScrollView<AnyView> {
                switch helpScreen {
                case .productMaintenanceList:
                    return AnyView(HelpViewFoodItemMaintenanceList())
                case .productSelectionList:
                    return AnyView(HelpViewProductsList())
                case .ingredientMaintenanceList:
                    return AnyView(HelpViewFoodItemMaintenanceList())
                case .ingredientSelectionList:
                    return AnyView(HelpViewIngredientsList())
                case .recipeList:
                    return AnyView(HelpViewRecipeList())
                case .foodItemSelector:
                    return AnyView(HelpViewFoodItemSelector())
                case .foodItemEditor:
                    return AnyView(HelpViewFoodItemEditor())
                case .mealDetails:
                    return AnyView(HelpViewMealDetails())
                case .absorptionSchemeEditor:
                    return AnyView(HelpViewAbsorptionSchemeEditor())
                case .mealExport:
                    return AnyView(HelpMealExportView())
                case .foodItemComposer:
                    return AnyView(HelpFoodItemComposer())
                }
            }
            .navigationTitle(NSLocalizedString(self.helpScreen.rawValue, comment: ""))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentation.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                    }
                    .accessibilityIdentifierLeaf("CloseButton")
                }
            }
        }
    }
}
