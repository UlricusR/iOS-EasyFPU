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
    @ObservedObject var composedFoodItem: ComposedFoodItemViewModel
    var category: FoodItemCategory
    @State private var showingAlert = false
    @State private var errorMessage = ""
    @State private var newTypicalAmountComment = ""
    @State private var addToTypicalAmounts = false
    @State private var showingSheet = false
    private let helpScreen = HelpScreen.foodItemSelector
    
    var body: some View {
        
        NavigationStack {
            VStack {
                GeometryReader { geometry in
                    Form {
                        Section(header: self.draftFoodItem.typicalAmounts.isEmpty ? Text(category == .product ? "Enter amount consumed" : "Enter amount used") : Text(category == .product ? "Enter amount consumed or select typical amount" : "Enter amount used or select typical amount")) {
                            HStack {
                                Text(category == .product ? "Amount consumed": "Amount used")
                                CustomTextField(titleKey: category == .product ? "Amount consumed" : "Amount used", text: self.$draftFoodItem.amountAsString, keyboardType: .numberPad)
                                    .multilineTextAlignment(.trailing)
                                    .accessibilityIdentifierLeaf("AmountConsumed")
                                Text("g")
                                    .accessibilityIdentifierLeaf("UnitConsumed")
                            }
                            
                            // Buttons to ease input
                            HStack {
                                Spacer()
                                NumberButton(number: 100, variableAmountItem: self.draftFoodItem, width: geometry.size.width / 7)
                                    .accessibilityIdentifierLeaf("Add100Button")
                                NumberButton(number: 50, variableAmountItem: self.draftFoodItem, width: geometry.size.width / 7)
                                    .accessibilityIdentifierLeaf("Add50Button")
                                NumberButton(number: 10, variableAmountItem: self.draftFoodItem, width: geometry.size.width / 7)
                                    .accessibilityIdentifierLeaf("Add10Button")
                                NumberButton(number: 5, variableAmountItem: self.draftFoodItem, width: geometry.size.width / 7)
                                    .accessibilityIdentifierLeaf("Add5Button")
                                NumberButton(number: 1, variableAmountItem: self.draftFoodItem, width: geometry.size.width / 7)
                                    .accessibilityIdentifierLeaf("Add1Button")
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
                                            Image(systemName: "checkmark.circle.fill")
                                        }
                                        .accessibilityIdentifierLeaf("EditTypicalAmountComment")
                                    }
                                } else {
                                    // Give user possibility to add the entered amount to typical amounts
                                    Button("Add to typical amounts") {
                                        self.addToTypicalAmounts = true
                                    }
                                    .accessibilityIdentifierLeaf("AddTypicalAmountButton")
                                }
                            }
                        }
                        
                        if !self.draftFoodItem.typicalAmounts.isEmpty {
                            Section(header: Text("Typical amounts:")) {
                                ForEach(self.draftFoodItem.typicalAmounts.sorted()) { typicalAmount in
                                    HStack {
                                        Text(typicalAmount.amountAsString)
                                            .accessibilityIdentifierLeaf("TypicalAmountValue")
                                        Text("g")
                                            .accessibilityIdentifierLeaf("TypicalAmountUnit")
                                        Text(typicalAmount.comment)
                                            .accessibilityIdentifierLeaf("TypicalAmountComment")
                                    }
                                    .onTapGesture {
                                        self.draftFoodItem.amountAsString = typicalAmount.amountAsString
                                    }
                                    .accessibilityIdentifierBranch("TAmount" + typicalAmount.amountAsString)
                                }
                            }
                        }
                    }
                }
                
                HStack {
                    Button("Cancel") {
                        // Do nothing, just quit edit mode, as food item hasn't been modified
                        presentation.wrappedValue.dismiss()
                    }
                    .padding()
                    .buttonStyle(.bordered)
                    .accessibilityIdentifierLeaf("CancelButton")
                    
                    Button("Add") {
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
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                    .disabled(draftFoodItem.amount <= 0)
                    .accessibilityIdentifierLeaf("AddButton")
                }
            }
            .navigationBarTitle(self.draftFoodItem.name)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        self.showingSheet = true
                    }) {
                        Image(systemName: "questionmark.circle")
                            .imageScale(.large)
                    }
                    .accessibilityIdentifierLeaf("HelpButton")
                }
            }
        }
        .alert(isPresented: self.$showingAlert) {
            Alert(
                title: Text("Data alert"),
                message: Text(self.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .sheet(isPresented: self.$showingSheet) {
            HelpView(helpScreen: self.helpScreen)
                .accessibilityIdentifierBranch("HelpSelectFoodItem")
        }
    }
    
    private func addTypicalAmount() {
        if let newTypicalAmount = TypicalAmountViewModel(amountAsString: self.draftFoodItem.amountAsString, comment: self.newTypicalAmountComment, errorMessage: &self.errorMessage) {
            // Add new typical amount to typical amounts of food item
            self.draftFoodItem.typicalAmounts.append(newTypicalAmount)
            
            // Reset text fields
            self.newTypicalAmountComment = ""
            
            // Update food item in core data, save and broadcast changed object
            _ = newTypicalAmount.save(to: draftFoodItem)
            
            self.addToTypicalAmounts = false
        } else {
            self.showingAlert = true
        }
    }
}
