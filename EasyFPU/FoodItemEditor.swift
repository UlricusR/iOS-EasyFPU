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
    enum NotificationState {
        case void, searching, noSearchResults
    }
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var presentation
    var navigationBarTitle: String
    @ObservedObject var draftFoodItem: FoodItemViewModel
    var editedFoodItem: FoodItem? // Working copy of the food item
    var category: FoodItemCategory
    @ObservedObject var foodDatabaseResults = FoodDatabaseResults()
    @State private var scanResult: FoodDatabaseEntry?
    @State private var notificationState = NotificationState.void
    @State private var errorMessage: String = ""
    @State private var activeSheet: FoodItemEditorSheets.State?
    @State private var foodSelected = false // We don't need this variable here
    
    @State var activeAlert: FoodItemEditorSheets.AlertState?
    
    @FetchRequest(
        entity: FoodItem.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \FoodItem.name, ascending: true)
        ]
    ) var foodItems: FetchedResults<FoodItem>
    
    var typicalAmounts: [TypicalAmountViewModel] { draftFoodItem.typicalAmounts.sorted() }
    
    @State private var oldName = ""
    @State private var oldCaloriesPer100gAsString = ""
    @State private var oldCarbsPer100gAsString = ""
    @State private var oldSugarsPer100gAsString = ""
    @State private var oldAmountAsString = ""
    
    @State var newTypicalAmount = ""
    @State var newTypicalAmountComment = ""
    @State var newTypicalAmountId: UUID?
    @State var typicalAmountsToBeDeleted = [TypicalAmountViewModel]()
    @State var updateButton = false
    @State var notificationStatus = FoodItemEditor.NotificationState.void
    @State var productWasChosenInFoodPreview = false // We actually don't need this variable in this view
    
    private let helpScreen = HelpScreen.foodItemEditor
    
    var body: some View {
        ZStack(alignment: .top) {
            NavigationView {
                VStack {
                    Form {
                        Section {
                            HStack {
                                // Name
                                CustomTextField(titleKey: "Name", text: $draftFoodItem.name, keyboardType: .default)
                                
                                // Search and Scan buttons
                                Button(action: {
                                    if draftFoodItem.name.isEmpty {
                                        self.errorMessage = NSLocalizedString("Search term must not be empty", comment: "")
                                        self.activeAlert = .alertMessage
                                    } else {
                                        if UserSettings.shared.foodDatabaseUseAtOwnRiskAccepted {
                                            performSearch()
                                        } else {
                                            self.activeAlert = .search
                                        }
                                    }
                                }) {
                                    Image(systemName: "magnifyingglass").imageScale(.large)
                                }.buttonStyle(BorderlessButtonStyle())
                                
                                Button(action: {
                                    if UserSettings.shared.foodDatabaseUseAtOwnRiskAccepted {
                                        self.activeSheet = .scan
                                    } else {
                                        self.activeAlert = .scan
                                    }
                                }) {
                                    Image(systemName: "barcode.viewfinder").imageScale(.large)
                                }.buttonStyle(BorderlessButtonStyle())
                            }
                            
                            // Category
                            Picker("Category", selection: $draftFoodItem.category) {
                                Text("Product").tag(FoodItemCategory.product)
                                Text("Ingredient").tag(FoodItemCategory.ingredient)
                            }
                            
                            // Favorite
                            Toggle("Favorite", isOn: $draftFoodItem.favorite)
                        }
                        
                        Section(header: Text("Nutritional values per 100g:")) {
                            // Calories
                            HStack {
                                CustomTextField(titleKey: "Calories per 100g", text: $draftFoodItem.caloriesPer100gAsString, keyboardType: .decimalPad)
                                Text("kcal")
                            }
                            
                            // Carbs
                            HStack {
                                CustomTextField(titleKey: "Carbs per 100g", text: $draftFoodItem.carbsPer100gAsString, keyboardType: .decimalPad)
                                Text("g Carbs")
                            }
                            
                            // Sugars
                            HStack {
                                CustomTextField(titleKey: "Thereof Sugars per 100g", text: $draftFoodItem.sugarsPer100gAsString, keyboardType: .decimalPad)
                                Text("g Sugars")
                            }
                        }
                        
                        Section(header: Text("Typical amounts:")) {
                            HStack {
                                CustomTextField(titleKey: "Amount", text: $newTypicalAmount, keyboardType: .decimalPad)
                                Text("g")
                                CustomTextField(titleKey: "Comment", text: $newTypicalAmountComment, keyboardType: .default)
                                Button(action: {
                                    self.addTypicalAmount()
                                }) {
                                    Image(systemName: self.updateButton ? "checkmark.circle" : "plus.circle").foregroundColor(self.updateButton ? .yellow : .green)
                                }
                            }
                        }
                        
                        if self.typicalAmounts.count > 0 {
                            Section(footer: Text("Tap to edit")) {
                                ForEach(self.typicalAmounts) { typicalAmount in
                                    HStack {
                                        HStack {
                                            Text(typicalAmount.amountAsString)
                                            Text("g")
                                            Text(typicalAmount.comment)
                                        }
                                        .onTapGesture {
                                            self.newTypicalAmount = typicalAmount.amountAsString
                                            self.newTypicalAmountComment = typicalAmount.comment
                                            self.newTypicalAmountId = typicalAmount.id
                                            self.updateButton = true
                                        }
                                        
                                        Spacer()
                                        Button(action: {
                                            // First clear edit fields if filled
                                            if self.updateButton {
                                                self.newTypicalAmount = ""
                                                self.newTypicalAmountComment = ""
                                                self.newTypicalAmountId = nil
                                                self.updateButton.toggle()
                                            }
                                            
                                            // Then delete typical amount
                                            self.deleteTypicalAmount(typicalAmount)
                                        }) {
                                            Image(systemName: "xmark.circle").foregroundColor(.red)
                                        }
                                    }
                                }.onDelete(perform: deleteTypicalAmount)
                            }
                        }
                        
                        // Delete food item (only when editing an existing food item)
                        if editedFoodItem != nil {
                            Section {
                                Button(action: {
                                    // Close the sheet
                                    presentation.wrappedValue.dismiss()
                                    
                                    // Delete food item
                                    if let foodItemToBeDeleted = self.draftFoodItem.cdFoodItem {
                                        FoodItem.delete(foodItemToBeDeleted)
                                    }
                                }) {
                                    Text("Delete food item")
                                }
                            }
                        }
                    }
                }
                .navigationBarTitle(navigationBarTitle)
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button(action: {
                            // First quit edit mode
                            presentation.wrappedValue.dismiss()
                            
                            // Then undo the changes made to typical amounts
                            for typicalAmountToBeDeleted in self.typicalAmountsToBeDeleted {
                                self.draftFoodItem.typicalAmounts.append(typicalAmountToBeDeleted)
                            }
                            self.typicalAmountsToBeDeleted.removeAll()
                        }) {
                            Text("Cancel")
                        }
                        
                        Button(action: {
                            activeSheet = .help
                        }) {
                            Image(systemName: "questionmark.circle").imageScale(.large)
                        }.padding()
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            saveFoodItem()
                        }) {
                            Text("Done")
                        }
                    }
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .alert(item: $activeAlert) { state in
                alertContent(state)
            }
            .sheet(item: $activeSheet) {
                sheetContent($0)
            }
            .onAppear() {
                self.oldName = self.draftFoodItem.name
                self.oldCaloriesPer100gAsString = self.draftFoodItem.caloriesPer100gAsString
                self.oldCarbsPer100gAsString = self.draftFoodItem.carbsPer100gAsString
                self.oldSugarsPer100gAsString = self.draftFoodItem.sugarsPer100gAsString
                self.oldAmountAsString = self.draftFoodItem.amountAsString
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
        var error = FoodItemViewModelError.name("Dummy")
        
        // Create updated food item
        if let updatedFoodItem = FoodItemViewModel(
            name: self.draftFoodItem.name,
            category: self.draftFoodItem.category,
            favorite: self.draftFoodItem.favorite,
            caloriesAsString: self.draftFoodItem.caloriesPer100gAsString,
            carbsAsString: self.draftFoodItem.carbsPer100gAsString,
            sugarsAsString: self.draftFoodItem.sugarsPer100gAsString,
            amountAsString: self.draftFoodItem.amountAsString,
            error: &error) { // We have a valid food item
            // Add typical amounts
            updatedFoodItem.typicalAmounts = draftFoodItem.typicalAmounts
            
            if self.editedFoodItem != nil { // We need to update an existing food item
                FoodItem.update(editedFoodItem!, with: updatedFoodItem)
                FoodItem.remove(typicalAmountsToBeDeleted, from: editedFoodItem!)
                
                // Reset typical amounts to be deleted
                self.typicalAmountsToBeDeleted.removeAll()
            } else { // We have a new food item
                let _ = FoodItem.create(from: updatedFoodItem)
            }
            
            // Quit edit mode
            presentation.wrappedValue.dismiss()
        } else { // Invalid data, display alert
            // Evaluate error
            switch error {
            case .name(let errorMessage):
                self.errorMessage = errorMessage
                self.draftFoodItem.name = self.oldName
            case .calories(let errorMessage):
                self.errorMessage = NSLocalizedString("Calories: ", comment:"") + errorMessage
                self.draftFoodItem.caloriesPer100gAsString = self.oldCaloriesPer100gAsString
            case .carbs(let errorMessage):
                self.errorMessage = NSLocalizedString("Carbs: ", comment:"") + errorMessage
                self.draftFoodItem.carbsPer100gAsString = self.oldCarbsPer100gAsString
            case .sugars(let errorMessage):
                self.errorMessage = NSLocalizedString("Sugars: ", comment: "") + errorMessage
                self.draftFoodItem.sugarsPer100gAsString = self.oldSugarsPer100gAsString
            case .tooMuchCarbs(let errorMessage):
                self.errorMessage = errorMessage
                self.draftFoodItem.caloriesPer100gAsString = self.oldCaloriesPer100gAsString
                self.draftFoodItem.carbsPer100gAsString = self.oldCarbsPer100gAsString
            case .tooMuchSugars(let errorMessage):
                self.errorMessage = errorMessage
                self.draftFoodItem.sugarsPer100gAsString = self.oldSugarsPer100gAsString
                self.draftFoodItem.carbsPer100gAsString = self.oldCarbsPer100gAsString
            case .amount(let errorMessage):
                self.errorMessage = NSLocalizedString("Amount: ", comment:"") + errorMessage
                self.draftFoodItem.amountAsString = self.oldAmountAsString
            }
            
            // Display alert and stay in edit mode
            self.activeAlert = .alertMessage
        }
    }
    
    private func deleteTypicalAmount(at offsets: IndexSet) {
        offsets.forEach { index in
            let typicalAmountToBeDeleted = self.typicalAmounts[index]
            deleteTypicalAmount(typicalAmountToBeDeleted)
        }
    }
    
    private func deleteTypicalAmount(_ typicalAmountToBeDeleted: TypicalAmountViewModel) {
        typicalAmountsToBeDeleted.append(typicalAmountToBeDeleted)
        guard let originalIndex = self.draftFoodItem.typicalAmounts.firstIndex(where: { $0.id == typicalAmountToBeDeleted.id }) else {
            self.errorMessage = NSLocalizedString("Cannot find typical amount ", comment: "") + typicalAmountToBeDeleted.comment
            return
        }
        self.draftFoodItem.typicalAmounts.remove(at: originalIndex)
    }
    
    private func addTypicalAmount() {
        if newTypicalAmountId == nil { // This is a new typical amount
            if let newTypicalAmount = TypicalAmountViewModel(amountAsString: self.newTypicalAmount, comment: self.newTypicalAmountComment, errorMessage: &self.errorMessage) {
                // Add new typical amount to typical amounts of food item
                self.draftFoodItem.typicalAmounts.append(newTypicalAmount)
                
                // Reset text fields
                self.newTypicalAmount = ""
                self.newTypicalAmountComment = ""
                self.updateButton = false
            } else {
                self.activeAlert = .alertMessage
            }
        } else { // This is an existing typical amount
            guard let index = self.draftFoodItem.typicalAmounts.firstIndex(where: { $0.id == self.newTypicalAmountId! }) else {
                self.errorMessage = NSLocalizedString("Fatal error: Could not identify typical amount", comment: "")
                self.activeAlert = .alertMessage
                return
            }
            self.draftFoodItem.typicalAmounts[index].amountAsString = self.newTypicalAmount
            self.draftFoodItem.typicalAmounts[index].comment = self.newTypicalAmountComment
            
            // Reset text fields and typical amount id
            self.newTypicalAmount = ""
            self.newTypicalAmountComment = ""
            self.updateButton = false
            self.newTypicalAmountId = nil
            
            // Broadcast changed object
            self.draftFoodItem.objectWillChange.send()
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
                    self.activeAlert = .alertMessage
                }
            }
        case .failure(let error):
            errorMessage = NSLocalizedString("Error scanning food: ", comment: "") + error.localizedDescription
            self.activeAlert = .alertMessage
        }
    }
    
    private func performSearch() {
        notificationState = .searching
        UserSettings.shared.foodDatabase.search(for: draftFoodItem.name, category: category) { result in
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
                self.activeAlert = .alertMessage
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
    private func sheetContent(_ state: FoodItemEditorSheets.State) -> some View {
        switch state {
        case .help:
            HelpView(helpScreen: self.helpScreen)
        case .search:
            FoodSearch(foodDatabaseResults: foodDatabaseResults, draftFoodItem: self.draftFoodItem, category: category)
        case .scan:
            CodeScannerView(codeTypes: [.ean8, .ean13], simulatedData: "4101530002123", completion: self.handleScan)
        case .foodPreview:
            FoodPreview(product: $scanResult, databaseResults: foodDatabaseResults, draftFoodItem: draftFoodItem, category: category, foodSelected: $foodSelected)
        }
    }
    
    private func alertContent(_ state: FoodItemEditorSheets.AlertState) -> Alert {
        switch state {
        case .alertMessage:
            return Alert(
                title: Text("Data alert"),
                message: Text(self.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        case .scan:
            return Alert(
                title: Text("Disclaimer"),
                message: Text("The nutritional values from the database may not be correct, please cross-check! Use at your own risk."),
                primaryButton: .default(Text("Accept and continue"), action: {
                    var settingsError = ""
                    if !UserSettings.set(UserSettings.UserDefaultsType.bool(true, UserSettings.UserDefaultsBoolKey.foodDatabaseUseAtOwnRiskAccepted), errorMessage: &settingsError) {
                        errorMessage = settingsError
                        self.activeAlert = .alertMessage
                    }

                    // Set dynamic variable
                    UserSettings.shared.foodDatabaseUseAtOwnRiskAccepted = true
                    
                    // Perform scan
                    self.activeSheet = .scan
                }),
                secondaryButton: .default(Text("Decline and cancel"))
            )
        case .search:
            return Alert(
                title: Text("Disclaimer"),
                message: Text("The nutritional values from the database may not be correct, please cross-check! Use at your own risk."),
                primaryButton: .default(Text("Accept and continue"), action:  {
                    var settingsError = ""
                    if !UserSettings.set(UserSettings.UserDefaultsType.bool(true, UserSettings.UserDefaultsBoolKey.foodDatabaseUseAtOwnRiskAccepted), errorMessage: &settingsError) {
                        errorMessage = settingsError
                        self.activeAlert = .alertMessage
                    }

                    // Set dynamic variable
                    UserSettings.shared.foodDatabaseUseAtOwnRiskAccepted = true
                    
                    // Perform search
                    self.performSearch()
                }),
                secondaryButton: .default(Text("Decline and cancel"))
            )
        }
    }
}
