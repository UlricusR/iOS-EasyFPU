//
//  ComposedProductDetail.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 29.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct FoodItemComposerView: View {
    enum SheetState: Identifiable {
        case help
        
        var id: SheetState { self }
    }
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var composedFoodItemVM: ComposedFoodItemViewModel
    @Binding var navigationPath: NavigationPath
    private let helpScreen = HelpScreen.foodItemComposer
    @State private var activeSheet: SheetState?
    @State private var showingAlert: Bool = false
    @State private var activeAlert: SimpleAlertType?
    @State private var showingActionSheet: Bool = false
    @State private var actionSheetMessage: String?
    @State private var existingFoodItem: FoodItem?
    
    var body: some View {
        VStack {
            if composedFoodItemVM.foodItemVMs.isEmpty {
                // No ingredients selected for the recipe, so display info and a call for action button
                Image("eggs-color").padding()
                Text("Your yummy recipe will appear here once you add some ingredients.").padding()
                Button {
                    // Add new product to composed food item
                    navigationPath.append(RecipeListView.RecipeNavigationDestination.AddIngredients(recipe: composedFoodItemVM))
                } label: {
                    HStack {
                        Image(systemName: "plus.circle")
                            .imageScale(.large)
                            .foregroundStyle(.green)
                            .bold()
                        Text("Add ingredients")
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(.yellow)
                    )
                }
                .accessibilityIdentifierLeaf("AddIngredientsButton")
            } else {
                GeometryReader { geometry in
                    Form {
                        Section(header: Text("Final product")) {
                            HStack {
                                Text("Name")
                                    .accessibilityIdentifierLeaf("NameLabel")
                                TextField("Name", text: self.$composedFoodItemVM.name)
                                    .accessibilityIdentifierLeaf("NameValue")
                            }
                            
                            HStack {
                                Text("Weight")
                                    .accessibilityIdentifierLeaf("WeightLabel")
                                CustomTextField(titleKey: "Weight", text: self.$composedFoodItemVM.amountAsString, keyboardType: .numberPad)
                                    .multilineTextAlignment(.trailing)
                                    .accessibilityIdentifierLeaf("WeightValue")
                                Text("g")
                                    .accessibilityIdentifierLeaf("WeightUnit")
                            }
                            
                            // Buttons to ease input
                            HStack {
                                Spacer()
                                NumberButton(number: 100, variableAmountItem: self.composedFoodItemVM, width: geometry.size.width / 7)
                                    .accessibilityIdentifierLeaf("Add100Button")
                                NumberButton(number: 50, variableAmountItem: self.composedFoodItemVM, width: geometry.size.width / 7)
                                    .accessibilityIdentifierLeaf("Add50Button")
                                NumberButton(number: 10, variableAmountItem: self.composedFoodItemVM, width: geometry.size.width / 7)
                                    .accessibilityIdentifierLeaf("Add10Button")
                                NumberButton(number: 5, variableAmountItem: self.composedFoodItemVM, width: geometry.size.width / 7)
                                    .accessibilityIdentifierLeaf("Add5Button")
                                NumberButton(number: 1, variableAmountItem: self.composedFoodItemVM, width: geometry.size.width / 7)
                                    .accessibilityIdentifierLeaf("Add1Button")
                                Spacer()
                            }
                            
                            // Favorite
                            Toggle("Favorite", isOn: $composedFoodItemVM.favorite)
                                .accessibilityIdentifierLeaf("FavoriteToggle")
                        }
                        
                        
                        Section(header: Text("Generate Typical Amounts")) {
                            // Number of portions
                            HStack {
                                Stepper("Number of portions", value: $composedFoodItemVM.numberOfPortions, in: 0...100)
                                    .accessibilityIdentifierLeaf("NumberOfPortionsStepper")
                                Text("\(composedFoodItemVM.numberOfPortions)")
                                    .accessibilityIdentifierLeaf("NumberOfPortionsValue")
                            }
                            
                            Text("If the number of portions is set to 0, no typical amounts will be created.").font(.caption)
                            
                            if composedFoodItemVM.numberOfPortions > 0 {
                                Text("\(composedFoodItemVM.amount / composedFoodItemVM.numberOfPortions)g " + NSLocalizedString("per portion", comment: ""))
                                    .accessibilityIdentifierLeaf("AmountPerPortionLabel")
                            }
                        }
                        
                        Section(header: Text("Ingredients")) {
                            Button(action: {
                                navigationPath.append(RecipeListView.RecipeNavigationDestination.AddIngredients(recipe: composedFoodItemVM))
                            }) {
                                HStack {
                                    Image(systemName: "pencil.circle")
                                        .imageScale(.large)
                                    Text("Edit ingredients")
                                }
                            }
                            .accessibilityIdentifierLeaf("EditIngredientsButton")
                            List {
                                ForEach(composedFoodItemVM.foodItemVMs) { foodItem in
                                    HStack {
                                        Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: foodItem.amount))!)
                                            .accessibilityIdentifierLeaf("IngredientAmountValue")
                                        Text("g")
                                            .accessibilityIdentifierLeaf("IngredientAmountUnit")
                                        Text(foodItem.name)
                                            .accessibilityIdentifierLeaf("IngredientName")
                                    }
                                    .accessibilityIdentifierBranch(String(foodItem.name.prefix(10)))
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(Text("Final product"))
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    activeSheet = .help
                }) {
                    Image(systemName: "questionmark.circle")
                        .imageScale(.large)
                }
                .accessibilityIdentifierLeaf("HelpButton")
            }
            
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    navigationPath.removeLast()
                }) {
                    Image(systemName: "xmark.circle")
                        .imageScale(.large)
                }
                .accessibilityIdentifierLeaf("ClearButton")
                
                Button(action: {
                    // Trim white spaces from name
                    composedFoodItemVM.name = composedFoodItemVM.name.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // Check if this is a new ComposedFoodItem (no Core Data object attached yet) and, if yes, the name already exists
                    if !composedFoodItemVM.hasAssociatedComposedFoodItem() && composedFoodItemVM.nameExists() {
                        activeAlert = .notice(message: "A food item with this name already exists")
                        showingAlert = true
                    } else {
                        if weightCheck(isLess: true) {
                            actionSheetMessage = NSLocalizedString("The weight of the composed product is less than the sum of its ingredients", comment: "")
                            showingActionSheet = true
                        } else if weightCheck(isLess: false) {
                            actionSheetMessage = NSLocalizedString("The weight of the composed product is more than the sum of its ingredients", comment: "")
                            showingActionSheet = true
                        } else {
                            saveComposedFoodItem()
                        }
                    }
                }) {
                    Image(systemName: "checkmark.circle.fill")
                        .imageScale(.large)
                }
                .disabled(composedFoodItemVM.foodItemVMs.count == 0)
                .confirmationDialog(
                    "Notice",
                    isPresented: $showingActionSheet,
                    presenting: actionSheetMessage
                ) { message in
                    Button("Save anyway") {
                        saveComposedFoodItem()
                        actionSheetMessage = nil
                        navigationPath.removeLast()
                    }
                    Button("Cancel", role: .cancel) {
                        actionSheetMessage = nil
                    }
                } message: { message in
                    Text(message)
                }
                .accessibilityIdentifierLeaf("SaveButton")
            }
        }
        .sheet(item: $activeSheet) {
            sheetContent($0)
        }
        .alert(
            activeAlert?.title() ?? "Notice",
            isPresented: $showingAlert,
            presenting: activeAlert
        ) { activeAlert in
            activeAlert.button()
        } message: { activeAlert in
            activeAlert.message()
        }
    }
    
    private func weightCheck(isLess: Bool) -> Bool {
        var ingredientsWeight = 0
        for ingredient in composedFoodItemVM.foodItemVMs {
            ingredientsWeight += ingredient.amount
        }
        
        return isLess ? (composedFoodItemVM.amount < ingredientsWeight ? true : false) : (composedFoodItemVM.amount > ingredientsWeight ? true : false)
    }
    
    private func saveComposedFoodItem() {
        // Check if this was an existing ComposedFoodItem
        if !composedFoodItemVM.hasAssociatedComposedFoodItem() { // This is a new ComposedFoodItem
            // Store new ComposedFoodItem in CoreData
            if !composedFoodItemVM.save() {
                // We're missing ingredients, the composedFoodItem could not be saved - this should not happen!
                activeAlert = .fatalError(message: "Could not create the composed food item")
                showingAlert = true
            }
        } else { // We edit an existing ComposedFoodItem
            // Update Core Data ComposedFoodItem
            if !composedFoodItemVM.update() {
                // No Core Data ComposedFoodItem found - this should never happen!
                activeAlert = .fatalError(message: "Could not update the composed food item")
                showingAlert = true
            }
        }
        
        // Clear the ComposedFoodItemViewModel
        composedFoodItemVM.clear()
        navigationPath.removeLast()
    }
    
    @ViewBuilder
    private func sheetContent(_ state: SheetState) -> some View {
        switch state {
        case .help:
            HelpView(helpScreen: self.helpScreen)
                .accessibilityIdentifierBranch("HelpComposeMeal")
        }
    }
}
