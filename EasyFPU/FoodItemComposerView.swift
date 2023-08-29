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
    @State var message: String = ""
    @State var showingActionSheet: Bool = false
    @Environment(\.presentationMode) var presentation
    @Environment(\.managedObjectContext) var managedObjectContext
    @State private var activeSheet: FoodItemComposerViewSheets.State?
    @Binding var notificationState: FoodItemListView.NotificationState?
    private let helpScreen = HelpScreen.foodItemComposer
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
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
                                message = NSLocalizedString("The weight of the composed product is less than the sum of its ingredients", comment: "")
                                showingActionSheet = true
                            } else if weightCheck(isLess: false) {
                                message = NSLocalizedString("The weight of the composed product is more than the sum of its ingredients", comment: "")
                                showingActionSheet = true
                            } else {
                                saveProduct()
                                presentation.wrappedValue.dismiss()
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
        .actionSheet(isPresented: self.$showingActionSheet) {
            ActionSheet(title: Text("Notice"), message: Text(message), buttons: [
                .default(Text("Save anyway")) {
                    saveProduct()
                    presentation.wrappedValue.dismiss()
                },
                .cancel()
            ])
        }
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
    
    private func saveProduct() {
        // Check if this was an existing ComposedFoodItem
        if composedFoodItemVM.cdComposedFoodItem == nil { // This is a new ComposedFoodItem
            // Store new ComposedFoodItem in CoreData
            if ComposedFoodItem.create(from: composedFoodItemVM, generateTypicalAmounts: generateTypicalAmounts) != nil {
                // Notify user of successful creation
                notificationState = .successfullySavedFoodItem(composedFoodItemVM.name)
            } else {
                // We're missing ingredients, the composedFoodItem could not be saved - this should not happen!
                alertMessage = NSLocalizedString("Could not create the composed food item", comment: "")
                showingAlert = true
            }
        } else { // We edit an existing ComposedFoodItem
            // Update Core Data ComposedFoodItem
            if ComposedFoodItem.update(composedFoodItemVM) != nil {
                // Notify user of successful update
                notificationState = .successfullySavedFoodItem(composedFoodItemVM.name)
            } else {
                alertMessage = NSLocalizedString("Could not update the composed food item", comment: "")
                showingAlert = true
            }
        }
        
        // Clear the ComposedFoodItem
        composedFoodItemVM.clear()
    }
    
    @ViewBuilder
    private func sheetContent(_ state: FoodItemComposerViewSheets.State) -> some View {
        switch state {
        case .help:
            HelpView(helpScreen: self.helpScreen)
        }
    }
}
