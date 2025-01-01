//
//  ComposedProductDetail.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 29.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI
import Combine

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
                ZStack {
                    // The form with the recipe details
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
                                    TextField("Weight", text: self.$composedFoodItemVM.amountAsString)
                                        .keyboardType(.numberPad)
                                        .onReceive(Just(composedFoodItemVM.amountAsString)) { newValue in
                                            let filtered = newValue.filter { "0123456789".contains($0) }
                                            if filtered != newValue {
                                                self.composedFoodItemVM.amountAsString = filtered
                                            }
                                        }
                                        .multilineTextAlignment(.trailing)
                                        .accessibilityIdentifierLeaf("WeightValue")
                                    Text("g")
                                        .accessibilityIdentifierLeaf("WeightUnit")
                                }
                                
                                // Buttons to ease input
                                AmountEntryButtons(variableAmountItem: composedFoodItemVM, geometry: geometry)
                                
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
                    .safeAreaPadding(EdgeInsets(top: 0, leading: 0, bottom: 70, trailing: 0)) // Required to avoid the content to be hidden by the Save button
                    
                    // The overlaying Save button
                    if composedFoodItemVM.foodItemVMs.count > 0 {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                
                                Button {
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
                                } label: {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill").imageScale(.large).foregroundStyle(.green)
                                        Text("Save")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                                            .fill(.yellow)
                                    )
                                }
                                .accessibilityIdentifierLeaf("SaveButton")
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
                                
                                Spacer()
                            }
                            .padding()
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
