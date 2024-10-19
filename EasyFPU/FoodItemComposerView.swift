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
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                VStack {
                    if composedFoodItemVM.foodItemVMs.isEmpty {
                        // No ingredients selected for the recipe, so display info and a call for action button
                        Image("eggs-color").padding()
                        Text("Your yummy recipe will appear here once you add some ingredients.").padding()
                        Button {
                            // Add new product to composed food item
                            activeSheet = .addIngredients
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
                    } else {
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
                            
                            
                            Section(header: Text("Generate Typical Amounts")) {
                                // Number of portions
                                HStack {
                                    Stepper("Number of portions", value: $composedFoodItemVM.numberOfPortions, in: 0...100)
                                    Text("\(composedFoodItemVM.numberOfPortions)")
                                }
                                
                                Text("If the number of portions is set to 0, no typical amounts will be created.").font(.caption)
                                
                                if composedFoodItemVM.numberOfPortions > 0 {
                                    Text("\(composedFoodItemVM.amount / composedFoodItemVM.numberOfPortions)g " + NSLocalizedString("per portion", comment: ""))
                                }
                            }
                            
                            Section(header: Text("Ingredients")) {
                                Button(action: {
                                    activeSheet = .addIngredients
                                }) {
                                    HStack {
                                        Image(systemName: "pencil.circle")
                                            .imageScale(.large)
                                        Text("Edit ingredients")
                                    }
                                }
                                List {
                                    ForEach(composedFoodItemVM.foodItemVMs) { foodItem in
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
                }
                .navigationBarTitle(Text("Final product"))
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            activeSheet = .help
                        }) {
                            Image(systemName: "questionmark.circle")
                                .imageScale(.large)
                        }
                    }
                    
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button(action: {
                            presentation.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark.circle")
                                .imageScale(.large)
                        }
                        
                        Button(action: {
                            // Trim white spaces from name
                            composedFoodItemVM.name = composedFoodItemVM.name.trimmingCharacters(in: .whitespacesAndNewlines)
                            
                            // Check if this is a new ComposedFoodItem (no Core Data object attached yet) and, if yes, the name already exists
                            if !composedFoodItemVM.hasAssociatedComposedFoodItem() && composedFoodItemVM.nameExists() {
                                alertMessage = NSLocalizedString("A food item with this name already exists", comment: "")
                                showingAlert = true
                            } else {
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
                            }
                        }) {
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                        }.disabled(composedFoodItemVM.foodItemVMs.count == 0)
                    }
                }
            }
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
                alertMessage = NSLocalizedString("Could not create the composed food item", comment: "")
                showingAlert = true
            }
        } else { // We edit an existing ComposedFoodItem
            // Update Core Data ComposedFoodItem
            if !composedFoodItemVM.update() {
                // No Core Data ComposedFoodItem found - this should never happen!
                alertMessage = NSLocalizedString("Could not update the composed food item", comment: "")
                showingAlert = true
            }
        }
        
        // Clear the ComposedFoodItemViewModel
        composedFoodItemVM.clear()
        presentation.wrappedValue.dismiss()
    }
    
    @ViewBuilder
    private func sheetContent(_ state: FoodItemComposerViewSheets.State) -> some View {
        switch state {
        case .addIngredients:
            IngredientSelectionListView(composedFoodItemVM: self.composedFoodItemVM)
        case .help:
            HelpView(helpScreen: self.helpScreen)
        }
    }
    
    private func actionSheetContent() -> ActionSheet {
        switch activeActionSheet {
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
