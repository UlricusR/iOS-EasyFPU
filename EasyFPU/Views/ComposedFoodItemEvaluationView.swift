//
//  MealDetail.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 23.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct ComposedFoodItemEvaluationView: View {
    enum MealNavigationDestination: Hashable {
        case SelectProduct
        case Details
        case ExportToHealth
    }
    
    enum SheetState: Identifiable {
        case help
        
        var id: SheetState { self }
    }
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var absorptionScheme: AbsorptionSchemeViewModel
    @ObservedObject var composedFoodItemVM: ComposedFoodItemViewModel
    @ObservedObject var userSettings = UserSettings.shared
    private let helpScreen = HelpScreen.mealDetails
    @State private var navigationPath = NavigationPath()
    @State var activeSheet: SheetState?
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
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
                        navigationPath.append(MealNavigationDestination.SelectProduct)
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
                    ZStack {
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
                                    navigationPath.append(MealNavigationDestination.Details)
                                }
                                .accessibilityIdentifierLeaf("MealDetailsButton")
                            }
                        }
                        .safeAreaPadding(EdgeInsets(top: 0, leading: 0, bottom: 70, trailing: 0)) // Required to avoid the content to be hidden by the Edit and Export buttons
                        
                        // The overlaying edit and export buttons
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                
                                // The edit button
                                Button {
                                    navigationPath.append(MealNavigationDestination.SelectProduct)
                                } label: {
                                    HStack {
                                        Image(systemName: "pencil.circle.fill").imageScale(.large).foregroundStyle(.green)
                                        Text("Edit")
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                                            .fill(.yellow)
                                    )
                                }
                                .accessibilityIdentifierLeaf("EditButton")
                                
                                // The export button
                                if HealthDataHelper.healthKitIsAvailable() {
                                    Button {
                                        navigationPath.append(MealNavigationDestination.ExportToHealth)
                                    } label: {
                                        HStack {
                                            Image(systemName: "square.and.arrow.up").imageScale(.large).foregroundStyle(.green)
                                            Text("Export")
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                                .fill(.yellow)
                                        )
                                    }
                                    .accessibilityIdentifierLeaf("ExportButton")
                                }
                                
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(Text("Calculate meal"))
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
            }
            .navigationDestination(for: FoodItemListView.FoodListNavigationDestination.self) { screen in
                switch screen {
                case let .AddFoodItem(category: category):
                    FoodMaintenanceListView.addFoodItem(
                        $navigationPath: $navigationPath,
                        category: category,
                        managedObjectContext: managedObjectContext,
                        navigationBarBackButtonHidden: true
                    )
                case let .EditFoodItem(category: category, foodItemVM: foodItemVM):
                    FoodMaintenanceListView.editFoodItem(
                        $navigationPath: $navigationPath,
                        category: category,
                        managedObjectContext: managedObjectContext,
                        navigationBarBackButtonHidden: true,
                        foodItemVM: foodItemVM
                    )
                case let .SelectFoodItem(category: category, draftFoodItem: foodItemVM, composedFoodItem: composedFoodItemVM):
                    FoodItemSelector(
                        navigationPath: $navigationPath,
                        draftFoodItem: foodItemVM,
                        composedFoodItem: composedFoodItemVM,
                        category: category
                    )
                    .accessibilityIdentifierBranch("SelectFoodItem")
                }
            }
            .navigationDestination(for: MealNavigationDestination.self) { screen in
                switch screen {
                case .SelectProduct:
                    FoodItemListView(
                        category: .product,
                        listType: .selection,
                        foodItemListTitle: NSLocalizedString("My Products", comment: ""),
                        helpSheet: .productSelectionListHelp,
                        navigationPath: $navigationPath,
                        composedFoodItem: composedFoodItemVM
                    )
                    .accessibilityIdentifierBranch("AddProductToMeal")
                    .navigationBarBackButtonHidden()
                case .Details:
                    ComposedFoodItemDetailsView(
                        absorptionScheme: absorptionScheme,
                        composedFoodItem: composedFoodItemVM,
                        userSettings: userSettings
                    )
                    .accessibilityIdentifierBranch("MealDetails")
                case .ExportToHealth:
                    ComposedFoodItemExportView(
                        composedFoodItem: composedFoodItemVM,
                        absorptionScheme: absorptionScheme
                    )
                    .accessibilityIdentifierBranch("ExportMealToHealth")
                }
            }
            .sheet(item: $activeSheet) {
                sheetContent($0)
            }
        }
    }
    
    @ViewBuilder
    private func sheetContent(_ state: SheetState) -> some View {
        switch state {
        case .help:
            HelpView(helpScreen: self.helpScreen)
                .accessibilityIdentifierBranch("HelpCalculateMeal")
        }
    }
}
