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
    
    enum AlertChoice {
        case simpleAlert(type: SimpleAlertType)
        case updatedIngredients
        case searchDisclaimer
        case searchWorldwide
    }
    
    enum NotificationState {
        case void, searching
    }
    
    @Binding var navigationPath: NavigationPath
    var navigationTitle: String
    
    /// The source food item, which is modified, or nil if creating a new food item.
    /// When hitting the Save button of this view, the data from draftFoodItem are copied into the sourceFoodItem
    var sourceFoodItem: FoodItemViewModel?
    
    /// The food item representing the data of this view
    @ObservedObject var draftFoodItemVM: FoodItemViewModel
    
    var category: FoodItemCategory
    @State private var searchResults = [FoodDatabaseEntry]()
    @State private var notificationState = NotificationState.void
    @State private var activeSheet: SheetState?
    
    // General alert
    @State private var showingAlert = false
    @State private var activeAlert: AlertChoice?
    
    private var typicalAmounts: [TypicalAmountViewModel] { draftFoodItemVM.typicalAmounts.sorted() }
    private var sourceDB: FoodDatabase {
        (draftFoodItemVM.sourceDB != nil) ? FoodDatabaseType.getFoodDatabase(type: draftFoodItemVM.sourceDB!) : UserSettings.shared.foodDatabase
    }
    
    @State private var newTypicalAmount = ""
    @State private var newTypicalAmountComment = ""
    @State private var newTypicalAmountId: UUID?
    @State private var typicalAmountEdited = false
    @State private var notificationStatus = FoodItemEditor.NotificationState.void
    @State private var associatedRecipes: [String] = []
    
    private let helpScreen = HelpScreen.foodItemEditor
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                Form {
                    Section {
                        HStack {
                            // Name
                            TextField("Name", text: $draftFoodItemVM.name)
                                .accessibilityIdentifierLeaf("NameValue")
                            
                            // Search and Scan buttons
                            Button(action: {
                                if draftFoodItemVM.name.isEmpty {
                                    activeAlert = .simpleAlert(type: .error(message: "Search term must not be empty"))
                                    showingAlert = true
                                } else {
                                    if UserSettings.shared.foodDatabaseUseAtOwnRiskAccepted {
                                        performSearch()
                                    } else {
                                        activeAlert = .searchDisclaimer
                                        showingAlert = true
                                    }
                                }
                            }) {
                                Image(systemName: "magnifyingglass")
                                    .imageScale(.large)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .accessibilityIdentifierLeaf("SearchButton")
                            
                            
                            Button(action: {
                                if UserSettings.shared.foodDatabaseUseAtOwnRiskAccepted {
                                    navigationPath.append(FoodItemEditorNavigationDestination.Scan)
                                } else {
                                    activeAlert = .searchDisclaimer
                                    showingAlert = true
                                }
                            }) {
                                Image(systemName: "barcode.viewfinder")
                                    .imageScale(.large)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .accessibilityIdentifierLeaf("ScanButton")
                        }
                        
                        // Food Category
                        
                        
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
                    
                    Section(header: Text("Typical amounts:"), footer: Text("Tap to edit")) {
                        List {
                            if typicalAmountEdited {
                                HStack {
                                    CustomTextField(titleKey: "Amount", text: $newTypicalAmount, keyboardType: .numberPad)
                                        .accessibilityIdentifierLeaf("EditTypicalAmountValue")
                                    Text("g")
                                        .accessibilityIdentifierLeaf("AmountUnit")
                                    TextField("Comment", text: $newTypicalAmountComment)
                                        .accessibilityIdentifierLeaf("EditTypicalAmountComment")
                                    Button {
                                        withAnimation {
                                            self.addTypicalAmount()
                                        }
                                    } label: {
                                        Image(systemName: "checkmark.circle.fill")
                                    }
                                    .accessibilityIdentifierLeaf("EditTypicalAmountButton")
                                }
                            } else {
                                HStack {
                                    Button("Add", systemImage: "plus.circle") {
                                        withAnimation {
                                            self.typicalAmountEdited = true
                                        }
                                    }
                                    .accessibilityIdentifierLeaf("AddTypicalAmountButton")
                                }
                            }
                            
                            // The existing typical amounts list
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
                                .foregroundStyle(newTypicalAmountId != nil && newTypicalAmountId! == typicalAmount.id ? .secondary : .primary)
                                .onTapGesture {
                                    withAnimation {
                                        // Select if not selected, unselect if selected
                                        if newTypicalAmountId != nil && newTypicalAmountId! == typicalAmount.id { // Is selected
                                            deselectTypicalAmount()
                                        } else { // Is not selected
                                            selectTypicalAmount(typicalAmount)
                                        }
                                    }
                                }
                                .swipeActions(allowsFullSwipe: true) {
                                    Button("Delete", systemImage: "trash", role: .destructive) {
                                        // First clear edit fields if filled
                                        if self.typicalAmountEdited {
                                            deselectTypicalAmount()
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
            .safeAreaPadding(EdgeInsets(top: 0, leading: 0, bottom: ActionButton.safeButtonSpace, trailing: 0)) // Required to avoid the content to be hidden by the cancel and save buttons
            
            // The overlaying cancel and save button
            if !typicalAmountEdited { // We hide the buttons when typical amounts are edited to avoid confusion
                VStack {
                    Spacer()
                    HStack {
                        // The cancel button
                        Button(role: .cancel) {
                            // Quit edit mode
                            navigationPath.removeLast()
                        } label: {
                            HStack {
                                Image(systemName: "xmark.circle.fill").imageScale(.large)
                                Text("Cancel")
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .buttonStyle(CancelButton())
                        .accessibilityIdentifierLeaf("CancelButton")
                        
                        // The save button
                        Button {
                            // Trim white spaces from name
                            draftFoodItemVM.name = draftFoodItemVM.name.trimmingCharacters(in: .whitespacesAndNewlines)
                            
                            // Check if we have duplicate names (if this is a new food item)
                            if sourceFoodItem == nil && draftFoodItemVM.nameExists() {
                                activeAlert = .simpleAlert(type: .warning(message: "A food item with this name already exists"))
                                showingAlert = true
                            } else {
                                saveFoodItem()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.circle.fill").imageScale(.large).foregroundStyle(.green)
                                Text("Save")
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .disabled(draftFoodItemVM.name.isEmpty)
                        .buttonStyle(ActionButton())
                        .accessibilityIdentifierLeaf("SaveButton")
                    }
                    .padding()
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            // Notification
            if notificationState != .void {
                NotificationView {
                    notificationViewContent()
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
            // The help button
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    activeSheet = .help
                }) {
                    Image(systemName: "questionmark.circle").imageScale(.large)
                }
                .accessibilityIdentifierLeaf("HelpButton")
            }
            
            // The share button
            ToolbarItem(placement: .navigationBarTrailing) {
                ShareLink(item: DataWrapper(dataModelVersion: .version2, foodItemVMs: [draftFoodItemVM], composedFoodItemVMs: []), preview: .init("Share"))
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
    }
    
    private func saveFoodItem() {
        // First check if there's an unsaved typical amount
        if self.newTypicalAmount != "" { // We have an unsaved typical amount
            self.addTypicalAmount()
        }
        
        if sourceFoodItem == nil { // We have a new food item
            // Create error to store feedback from FoodItemViewModel
            var error = FoodItemViewModelError.none
            
            // Create new food item
            if let newFoodItemVM = FoodItemViewModel(
                id: UUID(),
                name: self.draftFoodItemVM.name,
                foodCategoryVM: self.draftFoodItemVM.foodCategoryVM,
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
                // Save in CoreData
                newFoodItemVM.save()
                
                // Quit edit mode
                navigationPath.removeLast()
            } else { // Invalid data, display alert
                var errMessage = ""
                
                // Evaluate error
                switch error {
                case .name(let errorMessage):
                    errMessage = errorMessage
                case .calories(let errorMessage):
                    errMessage = NSLocalizedString("Calories: ", comment:"") + errorMessage
                case .carbs(let errorMessage):
                    errMessage = NSLocalizedString("Carbs: ", comment:"") + errorMessage
                case .sugars(let errorMessage):
                    errMessage = NSLocalizedString("Sugars: ", comment: "") + errorMessage
                case .tooMuchCarbs(let errorMessage):
                    errMessage = errorMessage
                case .tooMuchSugars(let errorMessage):
                    errMessage = errorMessage
                case .amount(let errorMessage):
                    errMessage = NSLocalizedString("Amount: ", comment:"") + errorMessage
                case .none:
                    debugPrint("No error")
                }
                
                // Display alert and stay in edit mode
                activeAlert = .simpleAlert(type: .error(message: errMessage))
                showingAlert = true
            }
        } else { // We need to update an existing food item
            // Check if the nutritional values have changed
            if sourceFoodItem!.hasDifferentNutritionalValues(comparedTo: draftFoodItemVM) {
                // If the nutritional values have changed, we need to check for related Ingredients and update all Recipes, where these Ingredients are used
                if sourceFoodItem!.cdFoodItem?.ingredients?.count ?? 0 > 0 {
                    // Get the names of the ingredients
                    for case let ingredient as Ingredient in sourceFoodItem!.cdFoodItem!.ingredients! {
                        associatedRecipes.append(ingredient.composedFoodItem.name)
                    }
                    
                    // Show alert
                    activeAlert = .updatedIngredients
                    self.showingAlert = true
                }
            } else {
                // Update the source food item
                updateSourceFoodItem()
            }
        }
    }
    
    private func updateSourceFoodItem() {
        if let sourceFoodItem {
            var errorMessage = ""
            if sourceFoodItem.update(from: draftFoodItemVM, errorMessage: &errorMessage) {
                // Successfully updated source food item, leave edit mode
                navigationPath.removeLast()
            } else {
                // Error updating source food item, display alert
                activeAlert = .simpleAlert(type: .fatalError(message: errorMessage))
                showingAlert = true
            }
        }
    }
    
    private func selectTypicalAmount(_ typicalAmount: TypicalAmountViewModel) {
        self.newTypicalAmount = typicalAmount.amountAsString
        self.newTypicalAmountComment = typicalAmount.comment
        self.newTypicalAmountId = typicalAmount.id
        self.typicalAmountEdited = true
    }
    
    private func deselectTypicalAmount() {
        self.newTypicalAmount = ""
        self.newTypicalAmountComment = ""
        self.newTypicalAmountId = nil
        self.typicalAmountEdited = false
    }
    
    private func deleteTypicalAmount(_ typicalAmountToBeDeleted: TypicalAmountViewModel) {
        guard let originalIndex = self.draftFoodItemVM.typicalAmounts.firstIndex(where: { $0.id == typicalAmountToBeDeleted.id }) else {
            activeAlert = .simpleAlert(type: .fatalError(message: NSLocalizedString("Cannot find typical amount ", comment: "") + typicalAmountToBeDeleted.comment))
            showingAlert = true
            return
        }
        self.draftFoodItemVM.typicalAmounts.remove(at: originalIndex)
    }
    
    private func addTypicalAmount() {
        // If no amount is entered at all, we just leave the edit mode
        if self.newTypicalAmount.isEmpty {
            deselectTypicalAmount()
            return
        }
        
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
                deselectTypicalAmount()
            } else {
                activeAlert = .simpleAlert(type: .error(message: errorMessage))
                showingAlert = true
            }
        } else { // This is an existing typical amount
            guard let index = self.draftFoodItemVM.typicalAmounts.firstIndex(where: { $0.id == self.newTypicalAmountId! }) else {
                activeAlert = .simpleAlert(type: .fatalError(message: "Could not identify typical amount."))
                showingAlert = true
                return
            }
            self.draftFoodItemVM.typicalAmounts[index].amountAsString = self.newTypicalAmount
            self.draftFoodItemVM.typicalAmounts[index].comment = self.newTypicalAmountComment
            
            // Reset text fields and typical amount id
            deselectTypicalAmount()
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
                            activeAlert = .simpleAlert(type: .warning(message: "No food found"))
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        self.notificationState = .void
                        self.navigationPath.append(FoodItemEditorNavigationDestination.FoodSearchResultDetails(product: foodDatabaseEntry, backNavigationIfSelected: 2))
                    }
                    
                    
                case .failure(let error):
                    DispatchQueue.main.async { self.notificationState = .void }
                    let errorMessage = error.evaluate()
                    debugPrint(errorMessage)
                    activeAlert = .simpleAlert(type: .error(message: errorMessage))
                    showingAlert = true
                }
            }
        case .failure(let error):
            activeAlert = .simpleAlert(type: .error(message: NSLocalizedString("Error scanning food: ", comment: "") + error.localizedDescription))
            showingAlert = true
        }
    }
    
    private func performSearch(isSecondSearch: Bool = false) {
        notificationState = .searching
        UserSettings.shared.foodDatabase.search(for: draftFoodItemVM.name, category: category) { result in
            switch result {
            case .success(let networkSearchResults):
                guard let searchResults = networkSearchResults, !searchResults.isEmpty else {
                    DispatchQueue.main.async {
                        self.notificationState = .void
                        if UserSettings.shared.searchWorldwide || isSecondSearch {
                            // The worldwide search has returned no results
                            activeAlert = .simpleAlert(type: .warning(message: "No food found"))
                            showingAlert = true
                        } else {
                            activeAlert = .searchWorldwide
                            showingAlert = true
                        }
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
                activeAlert = .simpleAlert(type: .warning(message: errorMessage))
                showingAlert = true
            }
        }
    }
    
    @ViewBuilder
    private func alertMessage(for alert: AlertChoice) -> some View {
        switch alert {
        case let .simpleAlert(type: type):
            type.message()
        case .updatedIngredients:
            Text(
                NSLocalizedString("This food item is used as ingredient in the following recipes:", comment: "") +
                "\n\n\(self.associatedRecipes.joined(separator: "\n"))\n\n" +
                NSLocalizedString("Updating the food item will also update the associated recipes.", comment: "")
            )
        case .searchDisclaimer:
            Text("The nutritional values from the database may not be correct, please cross-check! Use at your own risk.")
        case .searchWorldwide:
            Text(
                UserSettings.shared.countryCode != nil ? "\(NSLocalizedString("No food found in", comment: "")) \(UserSettings.shared.countryCode!)." : "No food found"
            )
        }
    }

    @ViewBuilder
    private func alertAction(for alert: AlertChoice) -> some View {
        switch alert {
        case let .simpleAlert(type: type):
            type.button()
        case .updatedIngredients:
            Button("Update recipes") {
                // Update SourceFoodItem
                updateSourceFoodItem()
            }
            Button("Cancel", role: .cancel) {}
        case .searchDisclaimer:
            Button("Accept and continue") {
                var settingsError = ""
                if !UserSettings.set(UserSettings.UserDefaultsType.bool(true, UserSettings.UserDefaultsBoolKey.foodDatabaseUseAtOwnRiskAccepted), errorMessage: &settingsError) {
                    activeAlert = .simpleAlert(type: .fatalError(message: settingsError))
                    showingAlert = true
                }
            }
            Button("Decline and cancel", role: .cancel) {}
        case .searchWorldwide:
            Button("Cancel", role: .cancel) {}
            Button("Search worldwide") {
                // Try once more with worldwide search
                // Set search to worldwide, but don't save it
                UserSettings.shared.searchWorldwide = true
                
                // Perform search again
                performSearch(isSecondSearch: true)
                
                // Set search back to initial value
                UserSettings.shared.searchWorldwide = false
            }
        }
    }
    
    private var alertTitle: LocalizedStringKey {
        switch activeAlert {
        case let .simpleAlert(type: type):
            LocalizedStringKey(type.title())
        case .updatedIngredients:
            LocalizedStringKey("Associated Ingredients")
        case .searchDisclaimer:
            LocalizedStringKey("Disclaimer")
        case .searchWorldwide:
            LocalizedStringKey("Warning")
        case nil:
            ""
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

struct FoodItemEditor_Previews: PreviewProvider {
    @State private static var navigationPath = NavigationPath()
    static var previews: some View {
        FoodItemEditor(
            navigationPath: $navigationPath,
            navigationTitle: "Sample Food Item",
            draftFoodItemVM: FoodItemViewModel.sampleData(),
            category: .product
        )
    }
}
