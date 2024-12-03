//
//  FoodItemEditor.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 13.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI
import Combine
import CodeScanner

struct FoodItemEditor: View {
    enum SheetState: Identifiable {
        case help
        case search
        case scan
        case foodPreview
        
        var id: SheetState { self }
    }
    
    enum NotificationState {
        case void, searching, noSearchResults
    }
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var presentation
    var navigationBarTitle: String
    @ObservedObject var draftFoodItemVM: FoodItemViewModel
    var category: FoodItemCategory
    @ObservedObject var foodDatabaseResults = FoodDatabaseResults()
    @State private var scanResult: FoodDatabaseEntry?
    @State private var notificationState = NotificationState.void
    @State private var activeSheet: SheetState?
    @State private var foodSelected = false // We don't need this variable here
    
    // Specific alerts
    @State private var showingScanAlert = false
    @State private var showingSearchAlert = false
    @State private var showingUpdateIngredientsAlert = false
    
    // The general alert
    @State private var showingAlert = false
    @State private var errorMessage: String = ""
    
    @FetchRequest(
        entity: FoodItem.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \FoodItem.name, ascending: true)
        ]
    ) var foodItems: FetchedResults<FoodItem>
    
    private var typicalAmounts: [TypicalAmountViewModel] { draftFoodItemVM.typicalAmounts.sorted() }
    private var sourceDB: FoodDatabase {
        (draftFoodItemVM.sourceDB != nil) ? FoodDatabaseType.getFoodDatabase(type: draftFoodItemVM.sourceDB!) : UserSettings.shared.foodDatabase
    }
    
    @State private var oldName = ""
    @State private var oldCaloriesPer100gAsString = ""
    @State private var oldCarbsPer100gAsString = ""
    @State private var oldSugarsPer100gAsString = ""
    @State private var oldAmountAsString = ""
    
    @State private var newTypicalAmount = ""
    @State private var newTypicalAmountComment = ""
    @State private var newTypicalAmountId: UUID?
    @State private var typicalAmountsToBeDeleted = [TypicalAmountViewModel]()
    @State private var updateButton = false
    @State private var notificationStatus = FoodItemEditor.NotificationState.void
    @State private var associatedRecipes: [String] = []
    @State private var updatedFoodItemVM: FoodItemViewModel?
    
    private let helpScreen = HelpScreen.foodItemEditor
    
    var body: some View {
        ZStack(alignment: .top) {
            NavigationStack {
                VStack {
                    Form {
                        Section {
                            HStack {
                                // Name
                                CustomTextField(titleKey: "Name", text: $draftFoodItemVM.name, keyboardType: .default)
                                    .accessibilityIdentifierLeaf("NameValue")
                                
                                // Search and Scan buttons
                                Button(action: {
                                    if draftFoodItemVM.name.isEmpty {
                                        self.errorMessage = NSLocalizedString("Search term must not be empty", comment: "")
                                        self.showingAlert = true
                                    } else {
                                        if UserSettings.shared.foodDatabaseUseAtOwnRiskAccepted {
                                            performSearch()
                                        } else {
                                            self.showingSearchAlert = true
                                        }
                                    }
                                }) {
                                    Image(systemName: "magnifyingglass")
                                        .imageScale(.large)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                .accessibilityIdentifierLeaf("SearchButton")
                                .alert(
                                    "Disclaimer",
                                    isPresented: $showingSearchAlert
                                ) {
                                    Button("Accept and continue") {
                                        var settingsError = ""
                                        if !UserSettings.set(UserSettings.UserDefaultsType.bool(true, UserSettings.UserDefaultsBoolKey.foodDatabaseUseAtOwnRiskAccepted), errorMessage: &settingsError) {
                                            errorMessage = settingsError
                                            self.showingAlert = true
                                        }

                                        // Set dynamic variable
                                        UserSettings.shared.foodDatabaseUseAtOwnRiskAccepted = true
                                        
                                        // Perform search
                                        self.performSearch()
                                    }
                                    Button("Decline and cancel", role: .cancel) {}
                                } message: {
                                    Text("The nutritional values from the database may not be correct, please cross-check! Use at your own risk.")
                                }
                                
                                Button(action: {
                                    if UserSettings.shared.foodDatabaseUseAtOwnRiskAccepted {
                                        self.activeSheet = .scan
                                    } else {
                                        self.showingScanAlert = true
                                    }
                                }) {
                                    Image(systemName: "barcode.viewfinder")
                                        .imageScale(.large)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                .accessibilityIdentifierLeaf("ScanButton")
                                .alert(
                                    "Disclaimer",
                                    isPresented: $showingScanAlert
                                ) {
                                    Button("Accept and continue") {
                                        var settingsError = ""
                                        if !UserSettings.set(UserSettings.UserDefaultsType.bool(true, UserSettings.UserDefaultsBoolKey.foodDatabaseUseAtOwnRiskAccepted), errorMessage: &settingsError) {
                                            errorMessage = settingsError
                                            self.showingAlert = true
                                        }

                                        // Set dynamic variable
                                        UserSettings.shared.foodDatabaseUseAtOwnRiskAccepted = true
                                        
                                        // Perform scan
                                        self.activeSheet = .scan
                                    }
                                    Button("Decline and cancel", role: .cancel) {}
                                } message: {
                                    Text("The nutritional values from the database may not be correct, please cross-check! Use at your own risk.")
                                }
                            }
                            
                            // Category
                            Picker("Category", selection: $draftFoodItemVM.category) {
                                Text("Product").tag(FoodItemCategory.product)
                                Text("Ingredient").tag(FoodItemCategory.ingredient)
                            }
                            .accessibilityIdentifierLeaf("CategoryPicker")
                            
                            // Favorite
                            Toggle("Favorite", isOn: $draftFoodItemVM.favorite)
                                .accessibilityIdentifierLeaf("FavoriteToggle")
                        }
                        
                        Section(header: Text("Nutritional values per 100g:")) {
                            // Calories
                            HStack {
                                CustomTextField(titleKey: "Calories per 100g", text: $draftFoodItemVM.caloriesPer100gAsString, keyboardType: .decimalPad)
                                    .accessibilityIdentifierLeaf("CaloriesValue")
                                Text("kcal")
                                    .accessibilityIdentifierLeaf("CaloriesUnit")
                            }
                            
                            // Carbs
                            HStack {
                                CustomTextField(titleKey: "Carbs per 100g", text: $draftFoodItemVM.carbsPer100gAsString, keyboardType: .decimalPad)
                                    .accessibilityIdentifierLeaf("CarbsValue")
                                Text("g Carbs")
                                    .accessibilityIdentifierLeaf("CarbsUnit")
                            }
                            
                            // Sugars
                            HStack {
                                CustomTextField(titleKey: "Thereof Sugars per 100g", text: $draftFoodItemVM.sugarsPer100gAsString, keyboardType: .decimalPad)
                                    .accessibilityIdentifierLeaf("SugarsValue")
                                Text("g Sugars")
                                    .accessibilityIdentifierLeaf("SugarsUnit")
                            }
                        }
                        
                        Section(header: Text("Typical amounts:")) {
                            HStack {
                                CustomTextField(titleKey: "Amount", text: $newTypicalAmount, keyboardType: .decimalPad)
                                    .accessibilityIdentifierLeaf("EditTypicalAmountValue")
                                Text("g")
                                    .accessibilityIdentifierLeaf("AmountUnit")
                                CustomTextField(titleKey: "Comment", text: $newTypicalAmountComment, keyboardType: .default)
                                    .accessibilityIdentifierLeaf("EditTypicalAmountComment")
                                Button(action: {
                                    self.addTypicalAmount()
                                }) {
                                    Image(systemName: self.updateButton ? "checkmark.circle.fill" : "plus.circle").foregroundStyle(self.updateButton ? .blue : .green)
                                }
                                .accessibilityIdentifierLeaf("AddTypicalAmountButton")
                            }
                        }
                        
                        if self.typicalAmounts.count > 0 {
                            Section(footer: Text("Tap to edit")) {
                                ForEach(self.typicalAmounts) { typicalAmount in
                                    HStack {
                                        HStack {
                                            Text(typicalAmount.amountAsString)
                                                .accessibilityIdentifierLeaf("TypicalAmountValue")
                                            Text("g")
                                                .accessibilityIdentifierLeaf("TypicalAmountUnit")
                                            Text(typicalAmount.comment)
                                                .accessibilityIdentifierLeaf("TypicalAmountComment")
                                        }
                                        
                                        
                                        Spacer()
                                        
                                    }
                                    .onTapGesture {
                                        self.newTypicalAmount = typicalAmount.amountAsString
                                        self.newTypicalAmountComment = typicalAmount.comment
                                        self.newTypicalAmountId = typicalAmount.id
                                        self.updateButton = true
                                    }
                                    .swipeActions(allowsFullSwipe: true) {
                                        Button("Delete", systemImage: "trash", role: .destructive) {
                                            // First clear edit fields if filled
                                            if self.updateButton {
                                                self.newTypicalAmount = ""
                                                self.newTypicalAmountComment = ""
                                                self.newTypicalAmountId = nil
                                                self.updateButton.toggle()
                                            }
                                            
                                            // Then delete typical amount
                                            self.deleteTypicalAmount(typicalAmount)
                                        }
                                    }
                                    .accessibilityIdentifierBranch("TAmount" + typicalAmount.amountAsString)
                                }
                            }
                        }
                        
                        // Link to Food Database Entry (if sourceID is available)
                        if let sourceID = draftFoodItemVM.sourceID {
                            Section(header: Text("Initial source")) {
                                Text(NSLocalizedString("Link to entry in ", comment: "") + sourceDB.databaseType.rawValue)
                                    .frame(maxWidth: .infinity)
                                    .foregroundStyle(.blue)
                                    .onTapGesture {
                                        try? UIApplication.shared.open(sourceDB.getLink(for: sourceID))
                                    }
                                    .accessibilityIdentifierLeaf("LinkToFoodDatabaseEntry")
                            }
                        }
                        
                        // Delete food item (only when editing an existing food item)
                        if draftFoodItemVM.hasAssociatedFoodItem() {
                            Section {
                                Button("Delete food item", role: .destructive) {
                                    // Close the sheet
                                    presentation.wrappedValue.dismiss()
                                    
                                    // Delete food item
                                    self.draftFoodItemVM.delete(includeAssociatedRecipe: false)
                                }
                                .frame(maxWidth: .infinity)
                                .accessibilityIdentifierLeaf("DeleteButton")
                            }
                        }
                    }
                }
                .navigationBarTitle(navigationBarTitle)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            activeSheet = .help
                        }) {
                            Image(systemName: "questionmark.circle").imageScale(.large)
                        }
                        .accessibilityIdentifierLeaf("HelpButton")
                    }
                    
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button(action: {
                            // First quit edit mode
                            presentation.wrappedValue.dismiss()
                            
                            // Then undo the changes made to typical amounts
                            for typicalAmountToBeDeleted in self.typicalAmountsToBeDeleted {
                                self.draftFoodItemVM.typicalAmounts.append(typicalAmountToBeDeleted)
                            }
                            self.typicalAmountsToBeDeleted.removeAll()
                        }) {
                            Image(systemName: "xmark.circle")
                                .imageScale(.large)
                        }
                        .accessibilityIdentifierLeaf("ClearButton")
                        
                        Button(action: {
                            // Trim white spaces from name
                            draftFoodItemVM.name = draftFoodItemVM.name.trimmingCharacters(in: .whitespacesAndNewlines)
                            
                            // Check if we have duplicate names (if this is a new food item)
                            if !draftFoodItemVM.hasAssociatedFoodItem() && draftFoodItemVM.nameExists() {
                                errorMessage = NSLocalizedString("A food item with this name already exists", comment: "")
                                self.showingAlert = true
                            } else {
                                saveFoodItem()
                            }
                        }) {
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                        }
                        .accessibilityIdentifierLeaf("SaveButton")
                        .alert(
                            "Associated Ingredients",
                            isPresented: self.$showingUpdateIngredientsAlert
                        ) {
                            Button("Update recipes") {
                                // Update FoodItem
                                if let updatedFoodItemVM {
                                    updatedFoodItemVM.update(typicalAmountsToBeDeleted)
                                    
                                    // Reset typical amounts to be deleted
                                    self.typicalAmountsToBeDeleted.removeAll()
                                }
                                
                                // Quit edit mode
                                presentation.wrappedValue.dismiss()
                            }
                            Button("Cancel", role: .cancel) {
                                // Reset to original values
                                draftFoodItemVM.reset()
                                
                                // Quit edit mode
                                presentation.wrappedValue.dismiss()
                            }
                        } message: {
                            Text(
                                NSLocalizedString("This food item is used as ingredient in the following recipes:", comment: "") +
                                "\n\n\(self.associatedRecipes.joined(separator: "\n"))\n\n" +
                                NSLocalizedString("Updating the food item will also update the associated recipes.", comment: "")
                            )
                        }
                    }
                }
            }
            .alert("Data alert", isPresented: $showingAlert, actions: {}, message: { Text(self.errorMessage) })
            .sheet(item: $activeSheet) {
                sheetContent($0)
            }
            .onAppear() {
                self.oldName = self.draftFoodItemVM.name
                self.oldCaloriesPer100gAsString = self.draftFoodItemVM.caloriesPer100gAsString
                self.oldCarbsPer100gAsString = self.draftFoodItemVM.carbsPer100gAsString
                self.oldSugarsPer100gAsString = self.draftFoodItemVM.sugarsPer100gAsString
                self.oldAmountAsString = self.draftFoodItemVM.amountAsString
            }
            
            // Notification
            if notificationState != .void {
                NotificationView {
                    notificationViewContent()
                }
            }
        }
    }
    
    private func saveFoodItem() {
        // First check if there's an unsaved typical amount
        if self.newTypicalAmount != "" && self.newTypicalAmountComment != "" { // We have an unsaved typical amount
            self.addTypicalAmount()
        }
        
        // Create error to store feedback from FoodItemViewModel
        var error = FoodItemViewModelError.none
        
        // Create updated food item
        if let updatedFoodItemVM = FoodItemViewModel(
            id: draftFoodItemVM.hasAssociatedFoodItem() ? self.draftFoodItemVM.cdFoodItem!.id : UUID(),
            name: self.draftFoodItemVM.name,
            category: self.draftFoodItemVM.category,
            favorite: self.draftFoodItemVM.favorite,
            caloriesAsString: self.draftFoodItemVM.caloriesPer100gAsString,
            carbsAsString: self.draftFoodItemVM.carbsPer100gAsString,
            sugarsAsString: self.draftFoodItemVM.sugarsPer100gAsString,
            amountAsString: self.draftFoodItemVM.amountAsString,
            error: &error,
            sourceID: self.draftFoodItemVM.sourceID,
            sourceDB: self.draftFoodItemVM.sourceDB
        ) { // We have a valid food item
            self.updatedFoodItemVM = updatedFoodItemVM
            
            // Add typical amounts
            self.updatedFoodItemVM!.typicalAmounts = draftFoodItemVM.typicalAmounts
            
            if draftFoodItemVM.hasAssociatedFoodItem() { // We need to update an existing food item
                // Add associated FoodItem to updatedFoodItemVM
                self.updatedFoodItemVM!.cdFoodItem = draftFoodItemVM.cdFoodItem
                
                // Check for related Ingredients
                if self.updatedFoodItemVM!.cdFoodItem!.ingredients?.count ?? 0 > 0 {
                    // Get the names of the ingredients
                    for case let ingredient as Ingredient in self.updatedFoodItemVM!.cdFoodItem!.ingredients! {
                        associatedRecipes.append(ingredient.composedFoodItem.name)
                    }
                    
                    // Show alert
                    self.showingUpdateIngredientsAlert = true
                } else {
                    // No associated recipe
                    
                    // Remove the typicalAmountsToBeDeleted from the view model
                    for typicalAmountToBeDeleted in typicalAmountsToBeDeleted {
                        if let index = self.updatedFoodItemVM!.typicalAmounts.firstIndex(of: typicalAmountToBeDeleted) {
                            self.updatedFoodItemVM!.typicalAmounts.remove(at: index)
                        }
                    }
                    
                    // Update FoodItem
                    self.updatedFoodItemVM!.update(typicalAmountsToBeDeleted)
                    
                    // Reset typical amounts to be deleted
                    self.typicalAmountsToBeDeleted.removeAll()
                    
                    // Quit edit mode
                    presentation.wrappedValue.dismiss()
                }
            } else { // We have a new food item
                self.updatedFoodItemVM!.save()
                
                // Quit edit mode
                presentation.wrappedValue.dismiss()
            }
        } else { // Invalid data, display alert
            // Evaluate error
            switch error {
            case .name(let errorMessage):
                self.errorMessage = errorMessage
                self.draftFoodItemVM.name = self.oldName
            case .calories(let errorMessage):
                self.errorMessage = NSLocalizedString("Calories: ", comment:"") + errorMessage
                self.draftFoodItemVM.caloriesPer100gAsString = self.oldCaloriesPer100gAsString
            case .carbs(let errorMessage):
                self.errorMessage = NSLocalizedString("Carbs: ", comment:"") + errorMessage
                self.draftFoodItemVM.carbsPer100gAsString = self.oldCarbsPer100gAsString
            case .sugars(let errorMessage):
                self.errorMessage = NSLocalizedString("Sugars: ", comment: "") + errorMessage
                self.draftFoodItemVM.sugarsPer100gAsString = self.oldSugarsPer100gAsString
            case .tooMuchCarbs(let errorMessage):
                self.errorMessage = errorMessage
                self.draftFoodItemVM.caloriesPer100gAsString = self.oldCaloriesPer100gAsString
                self.draftFoodItemVM.carbsPer100gAsString = self.oldCarbsPer100gAsString
            case .tooMuchSugars(let errorMessage):
                self.errorMessage = errorMessage
                self.draftFoodItemVM.sugarsPer100gAsString = self.oldSugarsPer100gAsString
                self.draftFoodItemVM.carbsPer100gAsString = self.oldCarbsPer100gAsString
            case .amount(let errorMessage):
                self.errorMessage = NSLocalizedString("Amount: ", comment:"") + errorMessage
                self.draftFoodItemVM.amountAsString = self.oldAmountAsString
            case .none:
                debugPrint("No error")
            }
            
            // Display alert and stay in edit mode
            self.showingAlert = true
        }
    }
    
    private func deleteTypicalAmount(_ typicalAmountToBeDeleted: TypicalAmountViewModel) {
        typicalAmountsToBeDeleted.append(typicalAmountToBeDeleted)
        guard let originalIndex = self.draftFoodItemVM.typicalAmounts.firstIndex(where: { $0.id == typicalAmountToBeDeleted.id }) else {
            self.errorMessage = NSLocalizedString("Cannot find typical amount ", comment: "") + typicalAmountToBeDeleted.comment
            return
        }
        self.draftFoodItemVM.typicalAmounts.remove(at: originalIndex)
    }
    
    private func addTypicalAmount() {
        if newTypicalAmountId == nil { // This is a new typical amount
            if let newTypicalAmount = TypicalAmountViewModel(amountAsString: self.newTypicalAmount, comment: self.newTypicalAmountComment, errorMessage: &self.errorMessage) {
                // Add new typical amount to typical amounts of food item
                self.draftFoodItemVM.typicalAmounts.append(newTypicalAmount)
                
                // Reset text fields
                self.newTypicalAmount = ""
                self.newTypicalAmountComment = ""
                self.updateButton = false
            } else {
                self.showingAlert = true
            }
        } else { // This is an existing typical amount
            guard let index = self.draftFoodItemVM.typicalAmounts.firstIndex(where: { $0.id == self.newTypicalAmountId! }) else {
                self.errorMessage = NSLocalizedString("Fatal error: Could not identify typical amount", comment: "")
                self.showingAlert = true
                return
            }
            self.draftFoodItemVM.typicalAmounts[index].amountAsString = self.newTypicalAmount
            self.draftFoodItemVM.typicalAmounts[index].comment = self.newTypicalAmountComment
            
            // Reset text fields and typical amount id
            self.newTypicalAmount = ""
            self.newTypicalAmountComment = ""
            self.updateButton = false
            self.newTypicalAmountId = nil
            
            // Broadcast changed object
            self.draftFoodItemVM.objectWillChange.send()
        }
    }
    
    private func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        // Dismiss Code Scanner
        self.activeSheet = nil
        
        switch result {
        case .success(let barcode):
            // Show search notification
            notificationState = .searching
            
            UserSettings.shared.foodDatabase.prepare(barcode, category: category) { result in
                switch result {
                case .success(let networkFoodDatabaseEntry):
                    guard let foodDatabaseEntry = networkFoodDatabaseEntry else {
                        DispatchQueue.main.async { self.notificationState = .noSearchResults }
                        return
                    }
                    DispatchQueue.main.async {
                        self.notificationState = .void
                        self.scanResult = foodDatabaseEntry
                        self.activeSheet = .foodPreview
                    }
                    
                    
                case .failure(let error):
                    DispatchQueue.main.async { self.notificationState = .void }
                    errorMessage = error.evaluate()
                    debugPrint(errorMessage)
                    self.showingAlert = true
                }
            }
        case .failure(let error):
            errorMessage = NSLocalizedString("Error scanning food: ", comment: "") + error.localizedDescription
            self.showingAlert = true
        }
    }
    
    private func performSearch() {
        notificationState = .searching
        UserSettings.shared.foodDatabase.search(for: draftFoodItemVM.name, category: category) { result in
            switch result {
            case .success(let networkSearchResults):
                guard let searchResults = networkSearchResults, !searchResults.isEmpty else {
                    DispatchQueue.main.async { self.notificationState = .noSearchResults }
                    return
                }
                
                DispatchQueue.main.async {
                    self.notificationState = .void
                    self.foodDatabaseResults.searchResults = searchResults
                    self.activeSheet = .search
                }
            case .failure(let error):
                DispatchQueue.main.async { self.notificationState = .void }
                errorMessage = error.evaluate()
                debugPrint(errorMessage)
                self.showingAlert = true
            }
        }
    }
    
    @ViewBuilder
    private func notificationViewContent() -> some View {
        switch notificationState {
        case .searching:
            ActivityIndicatorDynamicText(staticText: NSLocalizedString("Searching", comment: ""))
        case .noSearchResults:
            Text("No food found")
                .onAppear() {
                    Timer.scheduledTimer(withTimeInterval: 3.5, repeats: false) { timer in
                        self.notificationState = .void
                    }
                }
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func sheetContent(_ state: SheetState) -> some View {
        switch state {
        case .help:
            HelpView(helpScreen: self.helpScreen)
                .accessibilityIdentifierBranch("HelpEditFoodItem")
        case .search:
            FoodSearch(foodDatabaseResults: foodDatabaseResults, draftFoodItem: self.draftFoodItemVM, category: category)
                .accessibilityIdentifierBranch("SearchFood")
        case .scan:
            CodeScannerView(codeTypes: [.ean8, .ean13], simulatedData: "4101530002123", completion: self.handleScan)
                .accessibilityIdentifierBranch("ScanBarCode")
        case .foodPreview:
            FoodPreview(product: $scanResult, databaseResults: foodDatabaseResults, draftFoodItem: draftFoodItemVM, category: category, foodSelected: $foodSelected)
                .accessibilityIdentifierBranch("PreviewFood")
        }
    }
}
