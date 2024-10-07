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
    case mealDetails = "Meal Details"
    case absorptionSchemeEditor = "Edit Absorption Scheme"
    case mealExport = "Export to Health"
    case foodItemComposer = "Food Item Composer"
}

struct HelpView: View {
    @Environment(\.presentationMode) var presentation
    var helpScreen: HelpScreen
    
    var body: some View {
        NavigationView {
            ScrollView<AnyView> {
                switch helpScreen {
                case .productMaintenanceList:
                    return AnyView(HelpViewProductsList())
                case .productSelectionList:
                    return AnyView(HelpViewFoodItemMaintenanceList())
                case .ingredientMaintenanceList:
                    return AnyView(HelpViewIngredientsList())
                case .ingredientSelectionList:
                    return AnyView(HelpViewFoodItemMaintenanceList())
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
            .navigationBarTitle(NSLocalizedString(self.helpScreen.rawValue, comment: ""))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentation.wrappedValue.dismiss()
                    }) {
                        Text("Close")
                    }
                }
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
