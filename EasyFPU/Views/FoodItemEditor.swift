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
import CoreData

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
    var tempContext: NSManagedObjectContext? // If set, this is a new food item
    var category: FoodItemCategory
    @State private var searchResults = [FoodDatabaseEntry]()
    @State private var notificationState = NotificationState.void
    @State private var activeSheet: SheetState?
    
    // General alert
    @State private var showingAlert = false
    @State private var activeAlert: AlertChoice?
    
    private var isNew: Bool {
        return tempContext != nil
    }
    
    private var sourceDB: FoodDatabase {
        if let sourceDB = editedCDFoodItem.sourceDB, let foodDatabaseType = FoodDatabaseType(rawValue: sourceDB) {
            return FoodDatabaseType.getFoodDatabase(type: foodDatabaseType)
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
                    Picker("Category", selection: $editedCDFoodItem.foodCategoryObjectID) {
                        Text("Uncategorized").tag(nil as URL?)
                        ForEach(FoodCategory.fetchAll(category: category), id: \.id) { foodCategory in
                            Text(foodCategory.name).tag(foodCategory.objectID.uriRepresentation())
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
                if !isNew { // We are editing an existing food item
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
                            if editedCDFoodItem.nameExists(isNew: isNew) {
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
    
    init(
        navigationPath: Binding<NavigationPath>,
        navigationTitle: String,
        foodItem: FoodItem? = nil,
        tempContext: NSManagedObjectContext? = nil,
        category: FoodItemCategory
    ) {
        self._navigationPath = navigationPath
        self.navigationTitle = navigationTitle
        self.category = category
        
        if let foodItem = foodItem { // We are editing an existing food item
            // Set the transient property for the food category object ID before editing, if not set yet
            if foodItem.foodCategoryObjectID == nil {
                foodItem.foodCategoryObjectID = foodItem.foodCategory?.objectID.uriRepresentation()
            }
            
            self.editedCDFoodItem = foodItem
            self.tempContext = nil
        } else { // We are creating a new food item
            self.tempContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            self.tempContext!.name = "Temporary food item context"
            self.tempContext!.parent = CoreDataStack.viewContext
            self.editedCDFoodItem = FoodItem.new(category: category, context: self.tempContext!)
        }
    }

    
    private func saveFoodItem() {
        // Check if there's an unsaved typical amount
        if self.newTypicalAmount != "" { // We have an unsaved typical amount
            self.addTypicalAmount()
        }
        
        // Validate input
        let error = editedCDFoodItem.validateInput()
        if error == .none {
            if isNew { // This is a new food item (tempContext != nil), so we need to create a new permanent food item
                // Save the temporary context, so the temporary food item is promoted to the main context
                if tempContext!.hasChanges {
                    do {
                        try tempContext!.save()
                        
                        // Get the ID of the ComposedFoodItem
                        let foodItemID = self.editedCDFoodItem.objectID
                        
                        // Retrieve the FoodItem in the main context
                        let mainContextFoodItem = CoreDataStack.viewContext.object(with: foodItemID) as! FoodItem
                        
                        // Update food category
                        updateFoodCategory(foodItem: mainContextFoodItem, foodCategoryObjectID: editedCDFoodItem.foodCategoryObjectID)
                    } catch {
                        activeAlert = .simpleAlert(type: .fatalError(message: "Could not save new food item: \(error.localizedDescription)"))
                        showingAlert = true
                        return
                    }
                }
                
                // Save main context and exit
                saveContextAndExit()
            } else { // We need to update an existing food item
                // Update food category
                updateFoodCategory(foodItem: editedCDFoodItem, foodCategoryObjectID: editedCDFoodItem.foodCategoryObjectID)
                
                // We need to check for related Ingredients and update all Recipes, where these Ingredients are used
                if let associatedRecipes = editedCDFoodItem.getAssociatedRecipeNames() {
                    self.associatedRecipes = associatedRecipes
                    
                    // Show alert
                    activeAlert = .updatedIngredients
                    self.showingAlert = true
                } else { // There are no related ingredients, just save and exit
                    // Save and exit
                    saveContextAndExit()
                }
            }
        } else { // Invalid data, display alert
            let errMessage = error.localizedDescription()
            
            // Display alert and stay in edit mode
            activeAlert = .simpleAlert(type: .error(message: errMessage))
            showingAlert = true
        }
    }
    
    private func updateFoodCategory(foodItem: FoodItem, foodCategoryObjectID: URL?) {
        if let foodCategoryObjectID, let moID = CoreDataStack.viewContext.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: foodCategoryObjectID) { // A food category has been selected
            let relatedFoodCategory = CoreDataStack.viewContext.object(with: moID) as! FoodCategory
            foodItem.foodCategory = relatedFoodCategory
        } else { // No food category has been selected
            foodItem.foodCategory = nil
        }
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
            // Send Message that the Item  should be deleted
            NotificationCenter.default.post(name: .deleteFoodItem, object: editedCDFoodItem.objectID.uriRepresentation())
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
            if let moc = editedCDFoodItem.managedObjectContext {
                let newTA = TypicalAmount.create(amount: Int64(newTAAmount), comment: self.newTypicalAmountComment, context: moc)
                editedCDFoodItem.addToTypicalAmounts(newTA)
            }
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

extension Notification.Name {
    static var deleteFoodItem: Notification.Name {
        return Notification.Name("Delete FoodItem")
    }
}
