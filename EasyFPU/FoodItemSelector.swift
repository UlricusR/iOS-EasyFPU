//
//  FoodItemSelector.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 14.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct FoodItemSelector: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var presentation
    @ObservedObject var draftFoodItem: FoodItemViewModel
    var editedFoodItem: FoodItem
    @ObservedObject var composedFoodItem: ComposedFoodItemViewModel
    var category: FoodItemCategory
    @State private var showingAlert = false
    @State private var errorMessage = ""
    @State private var newTypicalAmountComment = ""
    @State private var addToTypicalAmounts = false
    @State private var showingSheet = false
    private let helpScreen = HelpScreen.foodItemSelector
    
    var body: some View {
        
        NavigationView {
            GeometryReader { geometry in
                Form {
                    Section(header: self.draftFoodItem.typicalAmounts.isEmpty ? Text(category == .product ? "Enter amount consumed" : "Enter amount used") : Text(category == .product ? "Enter amount consumed or select typical amount" : "Enter amount used or select typical amount")) {
                        HStack {
                            Text(category == .product ? "Amount consumed": "Amount used")
                            CustomTextField(titleKey: category == .product ? "Amount consumed" : "Amount used", text: self.$draftFoodItem.amountAsString, keyboardType: .numberPad)
                                .multilineTextAlignment(.trailing)
                            Text("g")
                        }
                        
                        // Buttons to ease input
                        HStack {
                            Spacer()
                            NumberButton(number: 100, variableAmountItem: self.draftFoodItem, width: geometry.size.width / 7)
                            NumberButton(number: 50, variableAmountItem: self.draftFoodItem, width: geometry.size.width / 7)
                            NumberButton(number: 10, variableAmountItem: self.draftFoodItem, width: geometry.size.width / 7)
                            NumberButton(number: 5, variableAmountItem: self.draftFoodItem, width: geometry.size.width / 7)
                            NumberButton(number: 1, variableAmountItem: self.draftFoodItem, width: geometry.size.width / 7)
                            Spacer()
                        }
                        
                        // Add to typical amounts (only if not connected to a ComposedFoodItem)
                        if draftFoodItem.cdFoodItem?.composedFoodItem == nil {
                            if self.addToTypicalAmounts {
                                // User wants to add amount to typical amounts, so comment is required
                                HStack {
                                    CustomTextField(titleKey: "Comment", text: self.$newTypicalAmountComment, keyboardType: .default)
                                    Button(action: {
                                        self.addTypicalAmount()
                                    }) {
                                        Image(systemName: "plus.circle").foregroundColor(.green)
                                    }
                                }
                            } else {
                                // Give user possibility to add the entered amount to typical amounts
                                Button(action: {
                                    self.addToTypicalAmounts = true
                                }) {
                                    Text("Add to typical amounts")
                                }
                            }
                        }
                    }
                    
                    if !self.draftFoodItem.typicalAmounts.isEmpty {
                        Section(header: Text("Typical amounts:")) {
                            ForEach(self.draftFoodItem.typicalAmounts.sorted()) { typicalAmount in
                                HStack {
                                    Text(typicalAmount.amountAsString)
                                    Text("g")
                                    Text(typicalAmount.comment)
                                }
                                .onTapGesture {
                                    self.draftFoodItem.amountAsString = typicalAmount.amountAsString
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarTitle(self.draftFoodItem.name)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(action: {
                        // Do nothing, just quit edit mode, as food item hasn't been modified
                        presentation.wrappedValue.dismiss()
                    }) {
                        Text("Cancel")
                    }
                    
                    Button(action: {
                        self.showingSheet = true
                    }) {
                        Image(systemName: "questionmark.circle").imageScale(.large)
                    }.padding()
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // First check for unsaved typical amount
                        if self.addToTypicalAmounts {
                            self.addTypicalAmount()
                        }
                        
                        let amountResult = DataHelper.checkForPositiveInt(valueAsString: self.draftFoodItem.amountAsString, allowZero: true)
                        switch amountResult {
                        case .success(_):
                            composedFoodItem.add(foodItem: draftFoodItem)
                            
                            // Quit edit mode
                            presentation.wrappedValue.dismiss()
                        case .failure(let err):
                            // Display alert and stay in edit mode
                            self.errorMessage = err.evaluate()
                            self.showingAlert = true
                        }
                    }) {
                        Text("Add")
                    }.disabled(draftFoodItem.amount <= 0)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .alert(isPresented: self.$showingAlert) {
            Alert(
                title: Text("Data alert"),
                message: Text(self.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .sheet(isPresented: self.$showingSheet) {
            HelpView(helpScreen: self.helpScreen)
        }
    }
    
    private func addTypicalAmount() {
        if let newTypicalAmount = TypicalAmountViewModel(amountAsString: self.draftFoodItem.amountAsString, comment: self.newTypicalAmountComment, errorMessage: &self.errorMessage) {
            // Add new typical amount to typical amounts of food item
            self.draftFoodItem.typicalAmounts.append(newTypicalAmount)
            
            // Reset text fields
            self.newTypicalAmountComment = ""
            
            // Update food item in core data, save and broadcast changed object
            let newCoreDataTypicalAmount = TypicalAmount.create(from: newTypicalAmount)
            FoodItem.add(newCoreDataTypicalAmount, to: editedFoodItem)
            
            self.addToTypicalAmounts = false
        } else {
            self.showingAlert = true
        }
    }
}
