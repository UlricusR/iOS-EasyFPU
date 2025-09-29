//
//  ComposedProductDetail.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 29.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI
import Combine
import CoreData

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
    @ObservedObject var composedFoodItem: ComposedFoodItem
    private var tempContext: NSManagedObjectContext?
    @Binding var navigationPath: NavigationPath
    private let helpScreen = HelpScreen.foodItemComposer
    @State private var activeSheet: SheetState?
    @State private var showingAlert: Bool = false
    @State private var activeAlert: AlertChoice?
    @State private var showingActionSheet: Bool = false
    @State private var actionSheetMessage: String?
    @State private var existingFoodItem: FoodItem?
    @State private var isConfirming = false
    
    private var isNewRecipe: Bool {
        tempContext != nil
    }
    
    var body: some View {
        VStack {
            if composedFoodItem.ingredients.allObjects.isEmpty {
                // No ingredients selected for the recipe, so display info and a call for action button
                Image("eggs-color").padding()
                Text("Your yummy recipe will appear here once you add some ingredients.").padding()
                Button {
                    // Add new product to composed food item
                    navigationPath.append(RecipeListView.RecipeNavigationDestination.AddIngredients(recipe: composedFoodItem, tempContext: tempContext))
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
                                    TextField("Name", text: self.$composedFoodItem.name)
                                        .accessibilityIdentifierLeaf("NameValue")
                                }
                                
                                // Food Category
                                Picker("Category", selection: self.$composedFoodItem.foodCategory) {
                                    Text("Uncategorized").tag(nil as FoodCategory?)
                                    ForEach(FoodCategory.fetchAll(category: .product), id: \.id) { foodCategory in
                                        Text(foodCategory.name).tag(foodCategory)
                                    }
                                }
                                .accessibilityIdentifierLeaf("CategoryPicker")
                                
                                HStack {
                                    Text("Weight")
                                        .accessibilityIdentifierLeaf("WeightLabel")
                                    TextField("Test", value: self.$composedFoodItem.amount, format: .number)
                                        .keyboardType(.numberPad)
                                        .multilineTextAlignment(.trailing)
                                        .accessibilityIdentifierLeaf("WeightValue")
                                    Text("g")
                                        .accessibilityIdentifierLeaf("WeightUnit")
                                }
                                
                                // Buttons to ease input
                                AmountEntryButtons(variableAmountItem: composedFoodItem, geometry: geometry)
                                
                                // Favorite
                                Toggle("Favorite", isOn: $composedFoodItem.favorite)
                                    .accessibilityIdentifierLeaf("FavoriteToggle")
                            }
                            
                            
                            Section(header: Text("Generate Typical Amounts")) {
                                // Number of portions
                                HStack {
                                    Stepper("Number of portions", value: $composedFoodItem.numberOfPortions, in: 0...100)
                                        .accessibilityIdentifierLeaf("NumberOfPortionsStepper")
                                    Text("\(composedFoodItem.numberOfPortions)")
                                        .accessibilityIdentifierLeaf("NumberOfPortionsValue")
                                }
                                
                                Text("If the number of portions is set to 0, no typical amounts will be created.").font(.caption)
                                
                                if composedFoodItem.numberOfPortions > 0 {
                                    Text("\(Int(composedFoodItem.amount) / Int(composedFoodItem.numberOfPortions))g " + NSLocalizedString("per portion", comment: ""))
                                        .accessibilityIdentifierLeaf("AmountPerPortionLabel")
                                }
                            }
                            
                            Section(header: Text("Ingredients"), footer: Text("Swipe to remove")) {
                                List {
                                    ForEach(composedFoodItem.ingredients.allObjects as! [Ingredient]) { ingredient in
                                        HStack {
                                            Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: ingredient.amount))!)
                                                .accessibilityIdentifierLeaf("IngredientAmountValue")
                                            Text("g")
                                                .accessibilityIdentifierLeaf("IngredientAmountUnit")
                                            Text(ingredient.name)
                                                .accessibilityIdentifierLeaf("IngredientName")
                                        }
                                        .accessibilityIdentifierBranch(String(ingredient.name.prefix(10)))
                                    }
                                    .onDelete(perform: removeIngredients)
                                }
                            }
                            
                            // Delete recipe (only when editing an existing one)
                            if !isNewRecipe {
                                Section {
                                    Button("Delete recipe", role: .destructive) {
                                        // Check for associated product
                                        if composedFoodItem.foodItem != nil {
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
                    
                    // The overlaying buttons
                    if composedFoodItem.ingredients.allObjects.count > 0 {
                        VStack {
                            Spacer()
                            
                            HStack {
                                // The Add More button
                                Button {
                                    navigationPath.append(RecipeListView.RecipeNavigationDestination.AddIngredients(recipe: composedFoodItem, tempContext: tempContext))
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
                                    composedFoodItem.name = composedFoodItem.name.trimmingCharacters(in: .whitespacesAndNewlines)
                                    
                                    // Check if this is a new recipe and, if yes, the name already exists
                                    if composedFoodItem.nameExists(isNew: isNewRecipe) {
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
            ToolbarItemGroup(placement: .navigationBarLeading) {
                // The back button, which at the same time is a cancel button
                Button(action: {
                    // Cancel and exit
                    cancelAndExit()
                }) {
                    Image(systemName: "chevron.left")
                        .imageScale(.large)
                }
                
                // The help button
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
    
    init(navigationPath: Binding<NavigationPath>, composedFoodItem: ComposedFoodItem? = nil) {
        self._navigationPath = navigationPath
        if let composedFoodItem = composedFoodItem {
            // Editing an existing recipe
            self.tempContext = nil
            self.composedFoodItem = composedFoodItem
        } else {
            // Creating a new recipe
            self.tempContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            self.tempContext!.name = "Temporary Recipe Context"
            self.tempContext!.parent = CoreDataStack.viewContext
            self.composedFoodItem = ComposedFoodItem.new(name: RecipeListView.recipeDefaultName, context: self.tempContext!)
        }
    }
    
    private func weightCheck(isLess: Bool) -> Bool {
        var ingredientsWeight = 0
        for ingredient in composedFoodItem.ingredients.allObjects as! [Ingredient] {
            ingredientsWeight += Int(ingredient.amount)
        }
        
        return isLess ? (composedFoodItem.amount < ingredientsWeight ? true : false) : (composedFoodItem.amount > ingredientsWeight ? true : false)
    }
    
    private func saveComposedFoodItem() {
        if isNewRecipe { // tempContext != nil
            // If this is a new recipe, we need to save the temporary context
            do {
                // First save the temporary context, which will push the ComposedFoodItem to the main context
                try tempContext!.save()
                
                // Get the ID of the ComposedFoodItem
                let composedFoodItemID = self.composedFoodItem.objectID
                
                // Retrieve the ComposedFoodItem in the main context
                let mainContextComposedFoodItem = CoreDataStack.viewContext.object(with: composedFoodItemID) as! ComposedFoodItem
                
                // For each ingredient, retrieve the related FoodItem in the main context (if existing) and link it to the ingredient
                for ingredient in mainContextComposedFoodItem.ingredients.allObjects as! [Ingredient] {
                    if let relatedFoodItemObjectID = ingredient.relatedFoodItemObjectID {
                        if let moID = CoreDataStack.viewContext.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: relatedFoodItemObjectID) {
                            let relatedFoodItem = CoreDataStack.viewContext.object(with: moID) as! FoodItem
                            ingredient.foodItem = relatedFoodItem
                        }
                    }
                }
                
                // Now create the related FoodItem for the ComposedFoodItem
                mainContextComposedFoodItem.createOrUpdateRelatedFoodItem()
            } catch {
                let nsError = error as NSError
                activeAlert = .simpleAlert(type: .fatalError(message: "Unresolved error \(nsError), \(nsError.userInfo)"))
                showingAlert = true
                return
            }
        } else {
            // Existing recipe, so we only need to update the related FoodItem
            composedFoodItem.createOrUpdateRelatedFoodItem()
        }
        
        // Save and exit
        saveAndExit()
    }
    
    private func saveAndExit() {
        // Save the main context
        CoreDataStack.shared.save()
        
        // Exit the view
        navigationPath.removeLast()
    }
    
    /// Cancels the edit, rolls back all changes and exits the edit mode
    private func cancelAndExit() {
        // Rollback changes
        CoreDataStack.viewContext.rollback()
        
        // Exit the view
        navigationPath.removeLast()
    }
    
    func removeIngredients(at offsets: IndexSet) {
        let ingredients = composedFoodItem.ingredients.allObjects as! [Ingredient]
        if ingredients.count == 1 {
            // We need to have at least one ingredient left
            activeAlert = .simpleAlert(type: .notice(message: "At least one ingredient required"))
            showingAlert = true
            return
        }
        
        withAnimation {
            var ingredientsToRemove = [Ingredient]()
            for offset in offsets {
                ingredientsToRemove.append(ingredients[offset])
            }
            
            for ingredient in ingredientsToRemove {
                composedFoodItem.remove(ingredient)
            }
        }
    }
    
    private func deleteRecipeOnly() {
        withAnimation(.default) {
            ComposedFoodItem.delete(composedFoodItem, includeAssociatedFoodItem: false, saveContext: false)
            
            // Save and exit
            saveAndExit()
        }
    }
    
    private func deleteRecipeAndFoodItem() {
        withAnimation(.default) {
            ComposedFoodItem.delete(composedFoodItem, includeAssociatedFoodItem: true, saveContext: false)
            
            // Save and exit
            saveAndExit()
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
