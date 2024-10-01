//
//  ComposedProductDetail.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 29.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct FoodItemComposerView: View {
    @ObservedObject var composedFoodItemVM: ComposedFoodItemViewModel
    @Environment(\.presentationMode) var presentation
    @Environment(\.managedObjectContext) var managedObjectContext
    @State private var activeSheet: FoodItemComposerViewSheets.State?
    @State private var activeActionSheet: FoodItemComposerViewActionSheets.State?
    @Binding var notificationState: RecipeListView.NotificationState?
    private let helpScreen = HelpScreen.foodItemComposer
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var showingActionSheet: Bool = false
    @State private var actionSheetMessage: String = ""
    @State private var existingFoodItem: FoodItem?
    
    @State var generateTypicalAmounts: Bool = true
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack {
                    Form {
                        Section(header: Text("Final product")) {
                            HStack {
                                Text("Name")
                                TextField("Name", text: self.$composedFoodItemVM.name)
                            }
                            
                            HStack {
                                Text("Weight")
                                CustomTextField(titleKey: "Weight", text: self.$composedFoodItemVM.amountAsString, keyboardType: .numberPad)
                                    .multilineTextAlignment(.trailing)
                                Text("g")
                            }
                            
                            // Buttons to ease input
                            HStack {
                                Spacer()
                                NumberButton(number: 100, variableAmountItem: self.composedFoodItemVM, width: geometry.size.width / 7)
                                NumberButton(number: 50, variableAmountItem: self.composedFoodItemVM, width: geometry.size.width / 7)
                                NumberButton(number: 10, variableAmountItem: self.composedFoodItemVM, width: geometry.size.width / 7)
                                NumberButton(number: 5, variableAmountItem: self.composedFoodItemVM, width: geometry.size.width / 7)
                                NumberButton(number: 1, variableAmountItem: self.composedFoodItemVM, width: geometry.size.width / 7)
                                Spacer()
                            }
                            
                            // Favorite
                            Toggle("Favorite", isOn: $composedFoodItemVM.favorite)
                        }
                        
                        
                        Section(header: Text("Typical Amounts")) {
                            // Generate typical amounts
                            Toggle("Generate typical amounts", isOn: self.$generateTypicalAmounts)
                            
                            if generateTypicalAmounts {
                                // Number of portions
                                HStack {
                                    Stepper("Number of portions", value: $composedFoodItemVM.numberOfPortions, in: 1...100)
                                    Text("\(composedFoodItemVM.numberOfPortions)")
                                }
                                
                                if !composedFoodItemVM.typicalAmounts.isEmpty {
                                    List {
                                        ForEach(composedFoodItemVM.typicalAmounts) { typicalAmount in
                                            HStack {
                                                Text(typicalAmount.amountAsString)
                                                Text("g")
                                                Text(typicalAmount.comment)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        
                        Section(header: Text("Ingredients")) {
                            List {
                                ForEach(composedFoodItemVM.foodItems) { foodItem in
                                    HStack {
                                        Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: foodItem.amount))!)
                                        Text("g")
                                        Text(foodItem.name)
                                    }
                                }
                            }
                        }
                    }
                }
                .navigationBarTitle(Text("Final product"))
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button(action: {
                            activeSheet = .help
                        }) {
                            Image(systemName: "questionmark.circle").imageScale(.large)
                        }
                        
                        Button(action: {
                            composedFoodItemVM.clear()
                            presentation.wrappedValue.dismiss()
                        }) {
                            Text("Clear")
                        }
                    }
                    
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button(action: {
                            if weightCheck(isLess: true) {
                                activeActionSheet = .weightDifference
                                actionSheetMessage = NSLocalizedString("The weight of the composed product is less than the sum of its ingredients", comment: "")
                                showingActionSheet = true
                            } else if weightCheck(isLess: false) {
                                activeActionSheet = .weightDifference
                                actionSheetMessage = NSLocalizedString("The weight of the composed product is more than the sum of its ingredients", comment: "")
                                showingActionSheet = true
                            } else {
                                saveComposedFoodItem()
                            }
                        }) {
                            Text("Save")
                        }
                        
                        Button(action: {
                            presentation.wrappedValue.dismiss()
                        }) {
                            Text("Close")
                        }
                    }
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
        .sheet(item: $activeSheet) {
            sheetContent($0)
        }
        .actionSheet(isPresented: self.$showingActionSheet, content: actionSheetContent)
        .alert(isPresented: self.$showingAlert) {
            Alert(
                title: Text("Notice"),
                message: Text(self.alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func weightCheck(isLess: Bool) -> Bool {
        var ingredientsWeight = 0
        for ingredient in composedFoodItemVM.foodItems {
            ingredientsWeight += ingredient.amount
        }
        
        return isLess ? (composedFoodItemVM.amount < ingredientsWeight ? true : false) : (composedFoodItemVM.amount > ingredientsWeight ? true : false)
    }
    
    private func saveComposedFoodItem() {
        // Check if this was an existing ComposedFoodItem
        if composedFoodItemVM.cdComposedFoodItem == nil { // This is a new ComposedFoodItem
            // Store new ComposedFoodItem in CoreData
            if ComposedFoodItem.create(from: composedFoodItemVM, generateTypicalAmounts: generateTypicalAmounts) != nil {
                // We have created a new ComposedFoodItem, now we need to add it to the Products (where we don't expect one)
                saveFoodItem(existingFoodItemExpected: false)
            } else {
                // We're missing ingredients, the composedFoodItem could not be saved - this should not happen!
                alertMessage = NSLocalizedString("Could not create the composed food item", comment: "")
                showingAlert = true
            }
        } else { // We edit an existing ComposedFoodItem
            // Update Core Data ComposedFoodItem
            if ComposedFoodItem.update(composedFoodItemVM) != nil {
                // We have updated the ComposedFoodItem, now we need to update it in the Products (where we expect one)
                saveFoodItem(existingFoodItemExpected: true)
            } else {
                // No Core Data ComposedFoodItem found - this should never happen!
                alertMessage = NSLocalizedString("Could not update the composed food item", comment: "")
                showingAlert = true
            }
        }
    }
    
    private func saveFoodItem(existingFoodItemExpected: Bool) {
        if let existingFoodItem = FoodItem.getFoodItemByName(name: composedFoodItemVM.name) {
            // There's already a FoodItem with the same name in the database, so ...
            if existingFoodItemExpected {
                // ... replace it if this was expected
                replaceExistingFoodItem(existingFoodItem)
                
                // Notify user of successful update of both the ComposedFoodItem as well as the FoodItem
                presentation.wrappedValue.dismiss()
                notificationState = .successfullyUpdatedFoodItem(composedFoodItemVM.name)
                
                // Clear the ComposedFoodItem
                composedFoodItemVM.clear()
            } else {
                // ... ask what to do if this was not expected
                self.existingFoodItem = existingFoodItem
                activeActionSheet = .existingProduct
                actionSheetMessage = NSLocalizedString("There's already a product with the same name. What do you want to do?", comment: "")
                showingActionSheet = true
            }
        } else {
            // No existing FoodItem ...
            if existingFoodItemExpected {
                // ... although expected, so ask what to do
                activeActionSheet = .missingProduct
                actionSheetMessage = NSLocalizedString("Did not find a matching product with the same name. What do you want to do?", comment: "")
                showingActionSheet = true
            } else {
                // ... as expected, so create new one
                _ = FoodItem.create(from: composedFoodItemVM, generateTypicalAmounts: generateTypicalAmounts)
                
                // Notify user of successful creation both as ComposedFoodItem as well as FoodItem
                presentation.wrappedValue.dismiss()
                notificationState = .successfullySavedNewFoodItem(composedFoodItemVM.name)
                
                // Clear the ComposedFoodItem
                composedFoodItemVM.clear()
            }
        }
    }
    
    private func replaceExistingFoodItem(_ existingFoodItem: FoodItem) {
        // Remove existing FoodItem
        FoodItem.delete(existingFoodItem)
        
        // Create new FoodItem
        _ = FoodItem.create(from: composedFoodItemVM, generateTypicalAmounts: generateTypicalAmounts)
    }
    
    @ViewBuilder
    private func sheetContent(_ state: FoodItemComposerViewSheets.State) -> some View {
        switch state {
        case .help:
            HelpView(helpScreen: self.helpScreen)
        }
    }
    
    private func actionSheetContent() -> ActionSheet {
        switch activeActionSheet {
        case .existingProduct:
            return ActionSheet(title: Text("Notice"), message: Text(actionSheetMessage), buttons: [
                .default(Text("Keep both")) {
                    // Append " - new" to the name of the ComposedFoodItem
                    composedFoodItemVM.name += NSLocalizedString(" - new", comment: "")
                    composedFoodItemVM.cdComposedFoodItem?.name += NSLocalizedString(" - new", comment: "")
                    
                    // Create new FoodItem
                    _ = FoodItem.create(from: composedFoodItemVM, generateTypicalAmounts: generateTypicalAmounts)
                    
                    // Notify user of successful creation both as ComposedFoodItem as well as FoodItem
                    presentation.wrappedValue.dismiss()
                    notificationState = .successfullySavedNewFoodItem(composedFoodItemVM.name)
                    
                    // Clear the ComposedFoodItem
                    composedFoodItemVM.clear()
                },
                .default(Text("Replace")) {
                    if existingFoodItem != nil {
                        // Replace existing FoodItem
                        replaceExistingFoodItem(existingFoodItem!)
                        
                        // Notify user of successful creation both as ComposedFoodItem as well as FoodItem
                        presentation.wrappedValue.dismiss()
                        notificationState = .successfullySavedNewFoodItem(composedFoodItemVM.name)
                        
                        // Clear the ComposedFoodItem
                        composedFoodItemVM.clear()
                    } else {
                        // No existing food item found - this should not happen!
                        alertMessage = NSLocalizedString("Error: No existing food item found - please inform the app developer", comment: "")
                        showingAlert = true
                    }
                },
                .cancel() {
                    // The ComposedFoodItem was not saved as FoodItem
                    presentation.wrappedValue.dismiss()
                    notificationState = .successfullySavedNewComposedFoodItemOnly(composedFoodItemVM.name)
                    
                    // Clear the ComposedFoodItem
                    composedFoodItemVM.clear()
                }
            ])
        case .missingProduct:
            return ActionSheet(title: Text("Notice"), message: Text(actionSheetMessage), buttons: [
                .default(Text("Create Food Item")) {
                    // Create new FoodItem
                    _ = FoodItem.create(from: composedFoodItemVM, generateTypicalAmounts: generateTypicalAmounts)
                    
                    // Notify user of successful update of ComposedFoodItem and creation of new FoodItem
                    presentation.wrappedValue.dismiss()
                    notificationState = .successfullyUpdatedFoodItem(composedFoodItemVM.name)
                    
                    // Clear the ComposedFoodItem
                    composedFoodItemVM.clear()
                },
                .default(Text("Only update Composed Food Item")) {
                    // Only the ComposedFoodItem was updated
                    presentation.wrappedValue.dismiss()
                    notificationState = .successfullyUpdatedComposedFoodItemOnly(composedFoodItemVM.name)
                    
                    // Clear the ComposedFoodItem
                    composedFoodItemVM.clear()
                }
            ])
        case .weightDifference:
            return ActionSheet(title: Text("Notice"), message: Text(actionSheetMessage), buttons: [
                .default(Text("Save anyway")) {
                    saveComposedFoodItem()
                    presentation.wrappedValue.dismiss()
                },
                .cancel()
            ])
        case .none:
            return ActionSheet(title: Text("Error"), message: Text("This should not have happened - please inform the app developer"))
        }
    }
}
