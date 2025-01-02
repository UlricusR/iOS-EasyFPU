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
    
    enum AlertChoice {
        case simpleAlert(type: SimpleAlertType)
        case confirmDelete
    }
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var composedFoodItemVM: ComposedFoodItemViewModel
    @Binding var navigationPath: NavigationPath
    private let helpScreen = HelpScreen.foodItemComposer
    @State private var activeSheet: SheetState?
    @State private var showingAlert: Bool = false
    @State private var activeAlert: AlertChoice?
    @State private var showingActionSheet: Bool = false
    @State private var actionSheetMessage: String?
    @State private var existingFoodItem: FoodItem?
    @State private var isConfirming = false
    
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
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(ActionButton())
                .padding()
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
                            
                            Section(header: Text("Ingredients"), footer: Text("Swipe to remove")) {
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
                                    .onDelete(perform: removeFoodItems)
                                }
                            }
                            
                            // Delete recipe (only when editing an existing one)
                            if composedFoodItemVM.hasAssociatedComposedFoodItem() {
                                Section {
                                    Button("Delete recipe", role: .destructive) {
                                        // Check for associated product
                                        if composedFoodItemVM.hasAssociatedFoodItem() {
                                            isConfirming.toggle()
                                        } else {
                                            activeAlert = .confirmDelete
                                            showingAlert = true
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .accessibilityIdentifierLeaf("DeleteButton")
                                }
                            }
                        }
                    }
                    .safeAreaPadding(EdgeInsets(top: 0, leading: 0, bottom: ActionButton.safeButtonSpace, trailing: 0)) // Required to avoid the content to be hidden by the Edit and Save buttons
                    
                    // The overlaying Save button
                    if composedFoodItemVM.foodItemVMs.count > 0 {
                        VStack {
                            Spacer()
                            HStack {
                                // The Edit button
                                Button {
                                    navigationPath.append(RecipeListView.RecipeNavigationDestination.AddIngredients(recipe: composedFoodItemVM))
                                } label: {
                                    HStack {
                                        Image(systemName: "plus.circle").imageScale(.large).foregroundStyle(.green)
                                        Text("Add more")
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                }
                                .buttonStyle(ActionButton())
                                .accessibilityIdentifierLeaf("EditButton")
                                
                                // The Save button
                                Button {
                                    // Trim white spaces from name
                                    composedFoodItemVM.name = composedFoodItemVM.name.trimmingCharacters(in: .whitespacesAndNewlines)
                                    
                                    // Check if this is a new ComposedFoodItem (no Core Data object attached yet) and, if yes, the name already exists
                                    if !composedFoodItemVM.hasAssociatedComposedFoodItem() && composedFoodItemVM.nameExists() {
                                        activeAlert = .simpleAlert(type: .notice(message: "A food item with this name already exists"))
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
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                }
                                .buttonStyle(ActionButton())
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
                            }
                            .padding()
                            .fixedSize(horizontal: false, vertical: true)
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
        .alert(alertTitle, isPresented: $showingAlert, presenting: activeAlert) {
            alertAction(for: $0)
        } message: {
            alertMessage(for: $0)
        }
        .confirmationDialog(
            "Warning",
            isPresented: $isConfirming
        ) {
            Button("Delete both") {
                deleteRecipeAndFoodItem()
            }
            Button("Keep product") {
                deleteRecipeOnly()
            }
            Button("Cancel", role: .cancel) {
                isConfirming.toggle()
            }
        } message: {
            Text("There's an associated product, do you want to delete it as well?")
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
                activeAlert = .simpleAlert(type: .fatalError(message: "Could not create the composed food item"))
                showingAlert = true
            }
        } else { // We edit an existing ComposedFoodItem
            // Update Core Data ComposedFoodItem
            if !composedFoodItemVM.update() {
                // No Core Data ComposedFoodItem found - this should never happen!
                activeAlert = .simpleAlert(type: .fatalError(message: "Could not update the composed food item"))
                showingAlert = true
            }
        }
        
        // Clear the ComposedFoodItemViewModel
        composedFoodItemVM.clear()
        navigationPath.removeLast()
    }
    
    func removeFoodItems(at offsets: IndexSet) {
        if composedFoodItemVM.foodItemVMs.count == 1 {
            // We need to have at least one ingredient left
            activeAlert = .simpleAlert(type: .notice(message: "At least one ingredient required"))
            showingAlert = true
            return
        }
        
        withAnimation {
            var foodItemsToRemove = [FoodItemViewModel]()
            for offset in offsets {
                foodItemsToRemove.append(composedFoodItemVM.foodItemVMs[offset])
            }
            
            for foodItem in foodItemsToRemove {
                composedFoodItemVM.remove(foodItem: foodItem)
            }
        }
    }
    
    private func deleteRecipeOnly() {
        withAnimation(.default) {
            composedFoodItemVM.delete(includeAssociatedFoodItem: false)
            navigationPath.removeLast()
        }
    }
    
    private func deleteRecipeAndFoodItem() {
        withAnimation(.default) {
            composedFoodItemVM.delete(includeAssociatedFoodItem: true)
            navigationPath.removeLast()
        }
    }
    
    @ViewBuilder
    private func alertMessage(for alert: AlertChoice) -> some View {
        switch alert {
        case let .simpleAlert(type: type):
            type.message()
        case .confirmDelete:
            Text("Do you really want to delete this recipe? This cannot be undone!")
        }
    }

    @ViewBuilder
    private func alertAction(for alert: AlertChoice) -> some View {
        switch alert {
        case let .simpleAlert(type: type):
            type.button()
        case .confirmDelete:
            Button("Do not delete", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteRecipeOnly()
            }
        }
    }
    
    private var alertTitle: LocalizedStringKey {
        switch activeAlert {
        case let .simpleAlert(type: type):
            LocalizedStringKey(type.title())
        case .confirmDelete:
            LocalizedStringKey("Delete recipe")
        case nil:
            ""
        }
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

struct FoodItemComposerView_Previews: PreviewProvider {
    @State private static var navigationPath = NavigationPath()
    static var previews: some View {
        FoodItemComposerView(
            composedFoodItemVM: ComposedFoodItemViewModel.sampleData(),
            navigationPath: $navigationPath
        )
    }
}
