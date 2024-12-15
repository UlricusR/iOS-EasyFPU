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
    enum FoodItemEditorNavigationDestination: Hashable {
        case Search
        case FoodSearchResultDetails(product: FoodDatabaseEntry, backNavigationIfSelected: Int)
        case Scan
    }
    
    enum SheetState: Identifiable {
        case help
        
        var id: SheetState { self }
    }
    
    enum NotificationState {
        case void, searching
    }
    
    @Binding var navigationPath: NavigationPath
    var navigationTitle: String
    @ObservedObject var draftFoodItemVM: FoodItemViewModel
    var category: FoodItemCategory
    @State private var searchResults = [FoodDatabaseEntry]()
    @State private var notificationState = NotificationState.void
    @State private var activeSheet: SheetState?
    
    // Specific alerts
    @State private var showingScanAlert = false
    @State private var showingSearchAlert = false
    @State private var showingUpdateIngredientsAlert = false
    
    // General alert
    @State private var showingAlert = false
    @State private var activeAlert: SimpleAlertType?
    
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
                                    activeAlert = .error(message: "Search term must not be empty")
                                    showingAlert = true
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
                                        activeAlert = .fatalError(message: settingsError)
                                        showingAlert = true
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
                                    navigationPath.append(FoodItemEditorNavigationDestination.Scan)
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
                                        activeAlert = .fatalError(message: settingsError)
                                        showingAlert = true
                                    }

                                    // Set dynamic variable
                                    UserSettings.shared.foodDatabaseUseAtOwnRiskAccepted = true
                                    
                                    // Perform scan
                                    navigationPath.append(FoodItemEditorNavigationDestination.Scan)
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
                                navigationPath.removeLast()
                                
                                // Delete food item
                                self.draftFoodItemVM.delete(includeAssociatedRecipe: false)
                            }
                            .frame(maxWidth: .infinity)
                            .accessibilityIdentifierLeaf("DeleteButton")
                        }
                    }
                }
            }
            .navigationTitle(navigationTitle)
            .navigationDestination(for: FoodItemEditorNavigationDestination.self) { screen in
                switch screen {
                case .Search:
                    FoodSearch(
                        draftFoodItem: self.draftFoodItemVM,
                        searchResults: searchResults,
                        navigationPath: $navigationPath
                    )
                    .accessibilityIdentifierBranch("SearchFood")
                case let .FoodSearchResultDetails(
                    product: selectedProduct,
                    backNavigationIfSelected: backNavigationIfSelected
                ):
                    FoodPreview(
                        product: selectedProduct,
                        draftFoodItem: draftFoodItemVM,
                        navigationPath: $navigationPath,
                        backNavigationIfSelected: backNavigationIfSelected
                    )
                    .accessibilityIdentifierBranch("ProductDetails")
                case .Scan:
                    CodeScannerView(codeTypes: [.ean8, .ean13], simulatedData: "4101530002123", completion: self.handleScan)
                        .accessibilityIdentifierBranch("ScanBarCode")
                }
            }
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
                        navigationPath.removeLast()
                        
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
                            activeAlert = .warning(message: "A food item with this name already exists")
                            showingAlert = true
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
                            navigationPath.removeLast()
                        }
                        Button("Cancel", role: .cancel) {
                            // Reset to original values
                            draftFoodItemVM.reset()
                            
                            // Quit edit mode
                            navigationPath.removeLast()
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
                    navigationPath.removeLast()
                }
            } else { // We have a new food item
                self.updatedFoodItemVM!.save()
                
                // Quit edit mode
                navigationPath.removeLast()
            }
        } else { // Invalid data, display alert
            var errMessage = ""
            
            // Evaluate error
            switch error {
            case .name(let errorMessage):
                errMessage = errorMessage
                self.draftFoodItemVM.name = self.oldName
            case .calories(let errorMessage):
                errMessage = NSLocalizedString("Calories: ", comment:"") + errorMessage
                self.draftFoodItemVM.caloriesPer100gAsString = self.oldCaloriesPer100gAsString
            case .carbs(let errorMessage):
                errMessage = NSLocalizedString("Carbs: ", comment:"") + errorMessage
                self.draftFoodItemVM.carbsPer100gAsString = self.oldCarbsPer100gAsString
            case .sugars(let errorMessage):
                errMessage = NSLocalizedString("Sugars: ", comment: "") + errorMessage
                self.draftFoodItemVM.sugarsPer100gAsString = self.oldSugarsPer100gAsString
            case .tooMuchCarbs(let errorMessage):
                errMessage = errorMessage
                self.draftFoodItemVM.caloriesPer100gAsString = self.oldCaloriesPer100gAsString
                self.draftFoodItemVM.carbsPer100gAsString = self.oldCarbsPer100gAsString
            case .tooMuchSugars(let errorMessage):
                errMessage = errorMessage
                self.draftFoodItemVM.sugarsPer100gAsString = self.oldSugarsPer100gAsString
                self.draftFoodItemVM.carbsPer100gAsString = self.oldCarbsPer100gAsString
            case .amount(let errorMessage):
                errMessage = NSLocalizedString("Amount: ", comment:"") + errorMessage
                self.draftFoodItemVM.amountAsString = self.oldAmountAsString
            case .none:
                debugPrint("No error")
            }
            
            // Display alert and stay in edit mode
            activeAlert = .error(message: errMessage)
            showingAlert = true
        }
    }
    
    private func deleteTypicalAmount(_ typicalAmountToBeDeleted: TypicalAmountViewModel) {
        typicalAmountsToBeDeleted.append(typicalAmountToBeDeleted)
        guard let originalIndex = self.draftFoodItemVM.typicalAmounts.firstIndex(where: { $0.id == typicalAmountToBeDeleted.id }) else {
            activeAlert = .fatalError(message: NSLocalizedString("Cannot find typical amount ", comment: "") + typicalAmountToBeDeleted.comment)
            showingAlert = true
            return
        }
        self.draftFoodItemVM.typicalAmounts.remove(at: originalIndex)
    }
    
    private func addTypicalAmount() {
        var errorMessage = ""
        if newTypicalAmountId == nil { // This is a new typical amount
            if let newTypicalAmount = TypicalAmountViewModel(
                amountAsString: self.newTypicalAmount,
                comment: self.newTypicalAmountComment,
                errorMessage: &errorMessage
            ) {
                // Add new typical amount to typical amounts of food item
                self.draftFoodItemVM.typicalAmounts.append(newTypicalAmount)
                
                // Reset text fields
                self.newTypicalAmount = ""
                self.newTypicalAmountComment = ""
                self.updateButton = false
            } else {
                activeAlert = .error(message: errorMessage)
                showingAlert = true
            }
        } else { // This is an existing typical amount
            guard let index = self.draftFoodItemVM.typicalAmounts.firstIndex(where: { $0.id == self.newTypicalAmountId! }) else {
                activeAlert = .fatalError(message: "Could not identify typical amount.")
                showingAlert = true
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
                        DispatchQueue.main.async {
                            activeAlert = .warning(message: "No food found")
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        self.notificationState = .void
                        self.navigationPath.append(FoodItemEditorNavigationDestination.FoodSearchResultDetails(product: foodDatabaseEntry, backNavigationIfSelected: 1))
                    }
                    
                    
                case .failure(let error):
                    DispatchQueue.main.async { self.notificationState = .void }
                    let errorMessage = error.evaluate()
                    debugPrint(errorMessage)
                    activeAlert = .error(message: errorMessage)
                    showingAlert = true
                }
            }
        case .failure(let error):
            activeAlert = .error(message: NSLocalizedString("Error scanning food: ", comment: "") + error.localizedDescription)
            showingAlert = true
        }
    }
    
    private func performSearch() {
        notificationState = .searching
        UserSettings.shared.foodDatabase.search(for: draftFoodItemVM.name, category: category) { result in
            switch result {
            case .success(let networkSearchResults):
                guard let searchResults = networkSearchResults, !searchResults.isEmpty else {
                    DispatchQueue.main.async {
                        self.notificationState = .void
                        activeAlert = .warning(message: "No food found")
                        showingAlert = true
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self.notificationState = .void
                    self.searchResults = searchResults
                    self.navigationPath.append(FoodItemEditorNavigationDestination.Search)
                }
            case .failure(let error):
                DispatchQueue.main.async { self.notificationState = .void }
                let errorMessage = error.evaluate()
                debugPrint(errorMessage)
                activeAlert = .warning(message: errorMessage)
                showingAlert = true
            }
        }
    }
    
    @ViewBuilder
    private func notificationViewContent() -> some View {
        switch notificationState {
        case .searching:
            ActivityIndicatorDynamicText(staticText: NSLocalizedString("Searching", comment: ""))
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
        }
    }
}
