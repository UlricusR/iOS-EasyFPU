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
    @ObservedObject var absorptionScheme: AbsorptionScheme
    @ObservedObject var composedFoodItem: ComposedFoodItem
    @ObservedObject var userSettings = UserSettings.shared
    private let helpScreen = HelpScreen.mealDetails
    @State private var navigationPath = NavigationPath()
    @State var activeSheet: SheetState?
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack {
                if composedFoodItem.ingredients.allObjects.isEmpty {
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
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(ActionButton())
                    .padding()
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
                                    ComposedFoodItemSugarsView(composedFoodItem: self.composedFoodItem)
                                        .accessibilityIdentifierBranch("SugarDetails")
                                }
                                ComposedFoodItemCarbsView(composedFoodItem: self.composedFoodItem)
                                    .accessibilityIdentifierBranch("CarbsDetails")
                                ComposedFoodItemECarbsView(composedFoodItem: self.composedFoodItem, absorptionScheme: self.absorptionScheme)
                                    .accessibilityIdentifierBranch("ECarbsDetails")
                            }
                            
                            Section(header: Text("Products"), footer: Text("Swipe to remove")) {
                                // The included products
                                List {
                                    ForEach(composedFoodItem.ingredients.allObjects as! [Ingredient]) { ingredient in
                                        HStack {
                                            Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: Int(ingredient.amount)))!)
                                                .accessibilityIdentifierLeaf("AmountValue")
                                            Text("g")
                                                .accessibilityIdentifierLeaf("AmountUnit")
                                            Text(ingredient.name)
                                                .accessibilityIdentifierLeaf("Name")
                                        }
                                        .accessibilityIdentifierBranch(String(ingredient.name.prefix(10)))
                                    }
                                    .onDelete(perform: removeIngredients)
                                }
                                .accessibilityIdentifierBranch("IncludedProduct")
                                
                                // The link to the details
                                Button("Meal Details", systemImage: "info.circle.fill") {
                                    navigationPath.append(MealNavigationDestination.Details)
                                }
                                .accessibilityIdentifierLeaf("MealDetailsButton")
                            }
                        }
                        .safeAreaPadding(EdgeInsets(top: 0, leading: 0, bottom: ActionButton.safeButtonSpace, trailing: 0)) // Required to avoid the content to be hidden by the Edit and Export buttons
                        
                        // The overlaying edit and export buttons
                        VStack {
                            Spacer()
                            HStack {
                                // The edit button
                                Button {
                                    navigationPath.append(MealNavigationDestination.SelectProduct)
                                } label: {
                                    HStack {
                                        Image(systemName: "plus.circle").imageScale(.large).foregroundStyle(.green)
                                        Text("Add more")
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                }
                                .buttonStyle(ActionButton())
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
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    }
                                    .buttonStyle(ActionButton())
                                    .accessibilityIdentifierLeaf("ExportButton")
                                }
                            }
                            .padding()
                            .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .navigationTitle(Text("Calculate meal"))
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    // Help button
                    Button(action: {
                        activeSheet = .help
                    }) {
                        Image(systemName: "questionmark.circle")
                            .imageScale(.large)
                    }
                    .accessibilityIdentifierLeaf("HelpButton")
                    
                    // Clear button
                    if !composedFoodItem.ingredients.allObjects.isEmpty {
                        Button(action: {
                            withAnimation(.default) {
                                // Clear the composed food item
                                composedFoodItem.clear(name: NSLocalizedString("Composed product", comment: ""))
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
                case let .EditFoodItem(category: category, foodItem: foodItem):
                    FoodMaintenanceListView.editFoodItem(
                        $navigationPath: $navigationPath,
                        category: category,
                        managedObjectContext: managedObjectContext,
                        navigationBarBackButtonHidden: true,
                        foodItem: foodItem
                    )
                case let .SelectFoodItem(category: category, ingredient: ingredient, composedFoodItem: composedFoodItem):
                    FoodItemSelector(
                        navigationPath: $navigationPath,
                        ingredient: ingredient,
                        composedFoodItem: composedFoodItem,
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
                        composedFoodItem: composedFoodItem
                    )
                    .accessibilityIdentifierBranch("AddProductToMeal")
                    .navigationBarBackButtonHidden()
                case .Details:
                    ComposedFoodItemDetailsView(
                        absorptionScheme: absorptionScheme,
                        composedFoodItem: composedFoodItem,
                        userSettings: userSettings
                    )
                    .accessibilityIdentifierBranch("MealDetails")
                case .ExportToHealth:
                    ComposedFoodItemExportView(
                        composedFoodItem: composedFoodItem,
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
    
    func removeIngredients(at offsets: IndexSet) {
        withAnimation {
            var ingredientsToRemove = [Ingredient]()
            for offset in offsets {
                ingredientsToRemove.append(composedFoodItem.ingredients.allObjects[offset] as! Ingredient)
            }
            
            for ingredient in ingredientsToRemove {
                composedFoodItem.remove(ingredient: ingredient)
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

struct ComposedFoodItemEvaluationView_Previews: PreviewProvider {
    static var previews: some View {
        ComposedFoodItemEvaluationView(
            absorptionScheme: AbsorptionScheme.sampleData(),
            composedFoodItem: ComposedFoodItem.new(name: "Sample Meal")
        )
    }
}
