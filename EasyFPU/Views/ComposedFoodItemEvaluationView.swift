//
//  MealDetail.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 23.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct ComposedFoodItemEvaluationView: View {
    enum SheetState: Identifiable {
        case help
        case exportToHealth
        case addProduct
        case details
        
        var id: SheetState { self }
    }
    
    @ObservedObject var absorptionScheme: AbsorptionScheme
    @ObservedObject var composedFoodItemVM: ComposedFoodItemViewModel
    @ObservedObject var userSettings = UserSettings.shared
    private let helpScreen = HelpScreen.mealDetails
    @State var activeSheet: SheetState?
    
    var body: some View {
        NavigationStack {
            VStack {
                if composedFoodItemVM.foodItemVMs.isEmpty {
                    // No products selected for the meal, so display empty state info and a call for action button
                    Image("cutlery-color").padding()
                        .accessibilityIdentifierLeaf("EmptyStateImage")
                    Text("This is where you will see the nutritial data of your meal and where you can export it to Loop.")
                        .padding()
                        .accessibilityIdentifierLeaf("EmpyStateText")
                    Button {
                        // Add new product to composed food item
                        activeSheet = .addProduct
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle")
                                .imageScale(.large)
                                .foregroundStyle(.green)
                                .bold()
                            Text("Add products to your meal")
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(.yellow)
                        )
                    }
                    .accessibilityIdentifierLeaf("AddProductsButton")
                } else {
                    Form {
                        // Summarize the meal
                        Section {
                            // The meal delay stepper
                            HStack {
                                Stepper("Delay until meal", value: $userSettings.mealDelayInMinutes, in: 0...30, step: 5)
                                    .accessibilityIdentifierLeaf("MealDelayStepper")
                                Text("\(userSettings.mealDelayInMinutes)")
                                    .accessibilityIdentifierLeaf("MealDelayValue")
                                Text("min")
                                    .accessibilityIdentifierLeaf("MealDelayUnit")
                            }
                        }
                        
                        Section(header: Text("Carbs")) {
                            // The carbs views
                            if userSettings.treatSugarsSeparately {
                                ComposedFoodItemSugarsView(composedFoodItem: self.composedFoodItemVM)
                                    .accessibilityIdentifierBranch("SugarDetails")
                            }
                            ComposedFoodItemCarbsView(composedFoodItem: self.composedFoodItemVM)
                                .accessibilityIdentifierBranch("CarbsDetails")
                            ComposedFoodItemECarbsView(composedFoodItem: self.composedFoodItemVM, absorptionScheme: self.absorptionScheme)
                                .accessibilityIdentifierBranch("ECarbsDetails")
                        }
                        
                        Section(header: Text("Products")) {
                            // Button to add products
                            Button(action: {
                                activeSheet = .addProduct
                            }) {
                                HStack {
                                    Image(systemName: "pencil.circle")
                                        .imageScale(.large)
                                    Text("Edit products")
                                }
                            }
                            .accessibilityIdentifierLeaf("EditProductsButton")
                            
                            // The included products
                            List {
                                ForEach(composedFoodItemVM.foodItemVMs) { foodItem in
                                    HStack {
                                        Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: foodItem.amount))!)
                                            .accessibilityIdentifierLeaf("AmountValue")
                                        Text("g")
                                            .accessibilityIdentifierLeaf("AmountUnit")
                                        Text(foodItem.name)
                                            .accessibilityIdentifierLeaf("Name")
                                    }
                                    .accessibilityIdentifierBranch(String(foodItem.name.prefix(10)))
                                }
                            }
                            .accessibilityIdentifierBranch("IncludedProduct")
                            
                            // The link to the details
                            Button("Meal Details", systemImage: "info.circle.fill") {
                                activeSheet = .details
                            }
                            .accessibilityIdentifierLeaf("MealDetailsButton")
                        }
                    }
                }
            }
            .navigationBarTitle(Text("Calculate meal"))
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(action: {
                        activeSheet = .help
                    }) {
                        Image(systemName: "questionmark.circle")
                            .imageScale(.large)
                    }
                    .accessibilityIdentifierLeaf("HelpButton")
                    
                    if !composedFoodItemVM.foodItemVMs.isEmpty {
                        Button(action: {
                            withAnimation(.default) {
                                composedFoodItemVM.clear()
                                UserSettings.shared.mealDelayInMinutes = 0
                            }
                        }) {
                            Image(systemName: "xmark.circle").foregroundStyle(.red)
                                .imageScale(.large)
                        }
                        .accessibilityIdentifierLeaf("ClearButton")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        activeSheet = .exportToHealth
                    }) {
                        HealthDataHelper.healthKitIsAvailable() ? AnyView(Image(systemName: "square.and.arrow.up").imageScale(.large)) : AnyView(EmptyView())
                    }
                    .disabled(composedFoodItemVM.foodItemVMs.isEmpty)
                    .accessibilityIdentifierLeaf("ExportButton")
                }
            }
        }
        .sheet(item: $activeSheet) {
            sheetContent($0)
        }

    }
    
    @ViewBuilder
    private func sheetContent(_ state: SheetState) -> some View {
        switch state {
        case .help:
            HelpView(helpScreen: self.helpScreen)
                .accessibilityIdentifierBranch("HelpCalculateMeal")
        case .exportToHealth:
            ComposedFoodItemExportView(composedFoodItem: composedFoodItemVM, absorptionScheme: absorptionScheme)
                .accessibilityIdentifierBranch("ExportMealToHealth")
        case .addProduct:
            ProductSelectionListView(composedFoodItemVM: composedFoodItemVM)
                .accessibilityIdentifierBranch("AddProductToMeal")
        case .details:
            ComposedFoodItemDetailsView(absorptionScheme: absorptionScheme, composedFoodItem: composedFoodItemVM, userSettings: userSettings)
                .accessibilityIdentifierBranch("MealDetails")
        }
    }
}
