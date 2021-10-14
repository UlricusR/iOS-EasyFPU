//
//  HelpView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 30.08.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

enum HelpScreen: String {
    case productsList = "Product List"
    case ingredientsList = "Ingredients List"
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
                case .productsList:
                    return AnyView(HelpViewProductsList())
                case .ingredientsList:
                    return AnyView(HelpViewIngredientsList())
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
                        Text("Done")
                    }
                }
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
