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
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var navigationPath: NavigationPath
    var navigationTitle: String
    
    /// The food item representing the data of this view
    @ObservedObject var editedCDFoodItem: FoodItem
    var isNewFoodItem: Bool
    
    var category: FoodItemCategory
    @State private var searchResults = [FoodDatabaseEntry]()
    @State private var notificationState = NotificationState.void
    @State private var activeSheet: SheetState?
    
    // General alert
    @State private var showingAlert = false
    @State private var activeAlert: AlertChoice?
    
    private var sourceDB: FoodDatabase {
        if editedCDFoodItem.sourceDB != nil {
            return FoodDatabaseType(rawValue: editedCDFoodItem.sourceDB!) as! FoodDatabase
        } else {
            return UserSettings.shared.foodDatabase
        }
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
            Form {
                Section {
                    HStack {
                        // Name
                        TextField("Name", text: $editedCDFoodItem.name)
                            .accessibilityIdentifierLeaf("NameValue")
                        
                        // Search and Scan buttons
                        Button(action: {
                            if editedCDFoodItem.name.isEmpty {
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
                    Picker("Category", selection: $editedCDFoodItem.foodCategory) {
                        Text("Uncategorized").tag(nil as FoodCategory?)
                        ForEach(FoodCategory.fetchAll(category: category), id: \.id) { foodCategory in
                            Text(foodCategory.name).tag(foodCategory as FoodCategory?)
                        }
                    }
                    .accessibilityIdentifierLeaf("CategoryPicker")
                    
                    // Favorite
                    Toggle("Favorite", isOn: $editedCDFoodItem.favorite)
                        .accessibilityIdentifierLeaf("FavoriteToggle")
                }
                
                Section(header: Text("Nutritional values per 100g:")) {
                    // Calories
                    HStack {
                        TextField("Calories per 100g", value: $editedCDFoodItem.caloriesPer100g, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .accessibilityIdentifierLeaf("CaloriesValue")
                        Text("kcal")
                            .accessibilityIdentifierLeaf("CaloriesUnit")
                    }
                    
                    // Carbs
                    HStack {
                        TextField("Carbs per 100g", value: $editedCDFoodItem.carbsPer100g, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .accessibilityIdentifierLeaf("CarbsValue")
                        Text("g Carbs")
                            .accessibilityIdentifierLeaf("CarbsUnit")
                    }
                    
                    // Sugars
                    HStack {
                        TextField("Thereof Sugars per 100g", value: $editedCDFoodItem.sugarsPer100g, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .accessibilityIdentifierLeaf("SugarsValue")
                        Text("g Sugars")
                            .accessibilityIdentifierLeaf("SugarsUnit")
                    }
                }
                
                Section(header: Text("Typical amounts:")) {
                    if typicalAmountEdited {
                        HStack {
                            TextField("Amount", text: $newTypicalAmount)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
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
                    try? DynamicList(
                        filterKey: "foodItem",
                        filterValue: editedCDFoodItem,
                        sortKey: "amount",
                        sortAscending: true,
                        emptyStateMessage: NSLocalizedString("You have not added any typical amounts yet.", comment: ""),
                    ) { (typicalAmount: TypicalAmount) in
                        HStack {
                            HStack {
                                Text(typicalAmount.amount, format: .number)
                                    .accessibilityIdentifierLeaf("TypicalAmountValue")
                                Text("g")
                                    .accessibilityIdentifierLeaf("TypicalAmountUnit")
                                Text(typicalAmount.comment ?? "")
                                    .accessibilityIdentifierLeaf("TypicalAmountComment")
                            }
                        }
                        .foregroundStyle(newTypicalAmountId != nil && newTypicalAmountId! == typicalAmount.id ? .secondary : .primary)
                        .swipeActions(edge: .trailing) {
                            // The edit button
                            Button("Edit", systemImage: "pencil") {
                                withAnimation {
                                    // Select if not selected, unselect if selected
                                    if newTypicalAmountId != nil && newTypicalAmountId! == typicalAmount.id { // Is selected
                                        deselectTypicalAmount()
                                    } else { // Is not selected
                                        selectTypicalAmount(typicalAmount)
                                    }
                                }
                            }
                            .tint(.blue)
                            .accessibilityIdentifierLeaf("EditButton")
                            
                            // The delete button
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                withAnimation {
                                    // First clear edit fields if filled
                                    if self.typicalAmountEdited {
                                        deselectTypicalAmount()
                                    }
                                    
                                    // Then delete typical amount
                                    TypicalAmount.delete(typicalAmount)
                                }
                            }
                            .tint(.red)
                            .accessibilityIdentifierLeaf("DeleteButton")
                            
                            
                        }
                        .accessibilityIdentifierBranch("TAmount\(typicalAmount.amount)")
                    }
                } // End Section Typical Amounts
                
                // Link to Food Database Entry (if sourceID is available)
                if let sourceID = editedCDFoodItem.sourceID {
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
                if !isNewFoodItem { // We are editing an existing food item
                    Section {
                        Button("Delete food item", role: .destructive) {
                            // Save the context and exit
                            saveContextAndExit(deletingFoodItem: true)
                        }
                        .frame(maxWidth: .infinity)
                        .accessibilityIdentifierLeaf("DeleteButton")
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
                            // Cancel and exit
                            cancelAndExit()
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
                            editedCDFoodItem.name = editedCDFoodItem.name.trimmingCharacters(in: .whitespacesAndNewlines)
                            
                            // Check if we have duplicate names (if this is a new food item)
                            if isNewFoodItem && editedCDFoodItem.nameExists() {
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
                        .disabled(editedCDFoodItem.name.isEmpty)
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
                    editedCDFoodItem: self.editedCDFoodItem,
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
                    editedCDFoodItem: self.editedCDFoodItem,
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
            /*ToolbarItem(placement: .navigationBarTrailing) {
                ShareLink(item: DataWrapper(dataModelVersion: .version2, foodItems: [editedCDFoodItem], composedFoodItems: []), preview: .init("Share"))
            } TODO - Implement share button - gives exception if a FoodItem is deleted */
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
        // Check if there's an unsaved typical amount
        if self.newTypicalAmount != "" { // We have an unsaved typical amount
            self.addTypicalAmount()
        }
        
        // Validate input
        let error = validateInput()
        if error == .none {
            if !isNewFoodItem { // We need to update an existing food item
                // We need to check for related Ingredients and update all Recipes, where these Ingredients are used
                if editedCDFoodItem.ingredients?.count ?? 0 > 0 {
                    // Get the names of the ingredients
                    for case let ingredient as Ingredient in editedCDFoodItem.ingredients! {
                        associatedRecipes.append(ingredient.composedFoodItem.name)
                    }
                    
                    // Show alert
                    activeAlert = .updatedIngredients
                    self.showingAlert = true
                } else {
                    // Save and exit
                    saveContextAndExit()
                }
            } else {
                // Save and exit
                saveContextAndExit()
            }
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
    }
    
    private func validateInput() -> FoodItemDataError {
        // Check for a correct name
        let foodName = editedCDFoodItem.name.trimmingCharacters(in: .whitespacesAndNewlines)
        if foodName == "" {
            return .name(NSLocalizedString("Name must not be empty", comment: ""))
        } else {
            editedCDFoodItem.name = foodName
        }
        
        // Check for valid calories
        if editedCDFoodItem.caloriesPer100g < 0.0 {
            return .calories(NSLocalizedString("Value must not be negative", comment: ""))
        }
        
        // Check for valid carbs
        if editedCDFoodItem.carbsPer100g < 0.0 {
            return .carbs(NSLocalizedString("Value must not be negative", comment: ""))
        }
        
        // Check for valid sugars
        if editedCDFoodItem.sugarsPer100g < 0.0 {
            return .sugars(NSLocalizedString("Value must not be negative", comment: ""))
        }
        
        // Check if sugars exceed carbs
        if editedCDFoodItem.sugarsPer100g > editedCDFoodItem.carbsPer100g {
            return .tooMuchSugars(NSLocalizedString("Sugars exceed carbs", comment: ""))
        }
        
        // Check if calories from carbs exceed total calories
        if editedCDFoodItem.carbsPer100g * 4 > editedCDFoodItem.caloriesPer100g {
            return .tooMuchCarbs(NSLocalizedString("Calories from carbs (4 kcal per gram) exceed total calories", comment: ""))
        }
        
        return .none
    }
    
    private func updateRelatedRecipesAndSave() {
        editedCDFoodItem.updateRelatedRecipes()
        
        // Save and exit
        saveContextAndExit()
    }
    
    /// Saves the context and exits the edit mode
    /// - Parameter deletingFoodItem: If true, the food item will be deleted before saving
    private func saveContextAndExit(deletingFoodItem: Bool = false) {
        // Leave edit mode
        navigationPath.removeLast()
        
        if deletingFoodItem {
            // Delete food item
            FoodItem.delete(editedCDFoodItem)
        }
        
        // Save
        CoreDataStack.shared.save()
    }
    
    /// Cancels the edit, rolls back all changes and exits the edit mode
    private func cancelAndExit() {
        // Rollback changes
        CoreDataStack.viewContext.rollback()
        
        // Leave edit mode
        navigationPath.removeLast()
    }
    
    private func selectTypicalAmount(_ typicalAmount: TypicalAmount) {
        self.newTypicalAmount = String(typicalAmount.amount)
        self.newTypicalAmountComment = typicalAmount.comment ?? ""
        self.newTypicalAmountId = typicalAmount.id
        self.typicalAmountEdited = true
    }
    
    private func deselectTypicalAmount() {
        self.newTypicalAmount = ""
        self.newTypicalAmountComment = ""
        self.newTypicalAmountId = nil
        self.typicalAmountEdited = false
    }
    
    private func addTypicalAmount() {
        // If no amount is entered at all, we just leave the edit mode
        if self.newTypicalAmount.isEmpty {
            deselectTypicalAmount()
            return
        }
        
        // Check for valid amount
        var errorMessage = ""
        var newTAAmount: Int = 0
        let result = DataHelper.checkForPositiveInt(valueAsString: self.newTypicalAmount, allowZero: false)
        switch result {
        case .success(let amount):
            newTAAmount = amount
        case .failure(let err):
            errorMessage = err.evaluate()
            activeAlert = .simpleAlert(type: .error(message: errorMessage))
            showingAlert = true
            return
        }
        
        if newTypicalAmountId == nil { // This is a new typical amount
            let newTA = TypicalAmount.create(amount: Int64(newTAAmount), comment: self.newTypicalAmountComment)
            editedCDFoodItem.addToTypicalAmounts(newTA)
            deselectTypicalAmount()
        } else { // This is an existing typical amount
            guard let cdTypicalAmount = TypicalAmount.getTypicalAmountByID(id: newTypicalAmountId!) else {
                activeAlert = .simpleAlert(type: .fatalError(message: "Could not identify typical amount."))
                showingAlert = true
                return
            }
            cdTypicalAmount.amount = Int64(newTAAmount)
            cdTypicalAmount.comment = self.newTypicalAmountComment
            
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
        UserSettings.shared.foodDatabase.search(for: editedCDFoodItem.name, category: category) { result in
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
                updateRelatedRecipesAndSave()
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
            editedCDFoodItem: FoodItem.new(category: .product),
            isNewFoodItem: true,
            category: .product
        )
    }
}
