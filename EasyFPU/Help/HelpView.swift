//
//  HelpView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 30.08.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

enum HelpScreen: String {
    case foodList = "Food List"
    case foodItemSelector = "Select Food Item"
    case foodItemEditor = "Edit Food Item"
    case mealDetails = "Meal Details"
    case absorptionSchemeEditor = "Edit Absorption Scheme"
    case mealExport = "Export to Health"
    case ingredients = "Ingredients"
}

struct HelpView: View {
    @Environment(\.presentationMode) var presentation
    var helpScreen: HelpScreen
    
    var body: some View {
        NavigationView {
            ScrollView<AnyView> {
                switch helpScreen {
                case .foodList:
                    return AnyView(HelpViewFoodList())
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
                case .ingredients:
                    return AnyView(HelpViewIngredientsList())
                }
            }
            .navigationBarTitle(NSLocalizedString(self.helpScreen.rawValue, comment: ""))
            .navigationBarItems(trailing: Button(action: {
                presentation.wrappedValue.dismiss()
            }) {
                Text("Done")
            })
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
