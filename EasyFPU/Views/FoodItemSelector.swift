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
    @Binding var navigationPath: NavigationPath
    @ObservedObject var draftFoodItem: FoodItemViewModel
    @ObservedObject var composedFoodItem: ComposedFoodItemViewModel
    var category: FoodItemCategory
    @State private var newTypicalAmountComment = ""
    @State private var addToTypicalAmounts = false
    @State private var showingSheet = false
    @State private var showingAlert = false
    @State private var activeAlert: SimpleAlertType?
    private let helpScreen = HelpScreen.foodItemSelector
    
    var body: some View {
        ZStack {
            // The form with the food item details
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
                                    TextField("Comment", text: self.$newTypicalAmountComment)
                                        .accessibilityIdentifierLeaf("TypicalAmountComment")
                                    Button(action: {
                                        self.addTypicalAmount()
                                    }) {
                                        Image(systemName: "checkmark.circle.fill")
                                    }
                                    .accessibilityIdentifierLeaf("EditTypicalAmountButton")
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
            .safeAreaPadding(EdgeInsets(top: 0, leading: 0, bottom: 70, trailing: 0)) // Required to avoid the content to be hidden by the Add button
            
            // The overlaying add button
            if draftFoodItem.amount > 0 {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            // First check for unsaved typical amount
                            if self.addToTypicalAmounts {
                                self.addTypicalAmount()
                            }
                            
                            let amountResult = DataHelper.checkForPositiveInt(valueAsString: self.draftFoodItem.amountAsString, allowZero: true)
                            switch amountResult {
                            case .success(_):
                                composedFoodItem.add(foodItem: draftFoodItem)
                                
                                // Quit edit mode
                                navigationPath.removeLast()
                            case .failure(let err):
                                // Display alert and stay in edit mode
                                activeAlert = .error(message: err.evaluate())
                                showingAlert = true
                            }
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill").imageScale(.large).foregroundStyle(.green)
                                Text("Add")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(.yellow)
                            )
                        }
                        .accessibilityIdentifierLeaf("AddButton")
                        Spacer()
                    }
                    .padding()
                }
            }
        }
        .navigationTitle(self.draftFoodItem.name)
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
        .alert(
            activeAlert?.title() ?? "Notice",
            isPresented: $showingAlert,
            presenting: activeAlert
        ) { activeAlert in
            activeAlert.button()
        } message: { activeAlert in
            activeAlert.message()
        }
        .sheet(isPresented: self.$showingSheet) {
            HelpView(helpScreen: self.helpScreen)
                .accessibilityIdentifierBranch("HelpSelectFoodItem")
        }
    }
    
    private func addTypicalAmount() {
        var errorMessage = ""
        if let newTypicalAmount = TypicalAmountViewModel(amountAsString: self.draftFoodItem.amountAsString, comment: self.newTypicalAmountComment, errorMessage: &errorMessage) {
            // Add new typical amount to typical amounts of food item
            self.draftFoodItem.typicalAmounts.append(newTypicalAmount)
            
            // Reset text fields
            self.newTypicalAmountComment = ""
            
            // Update food item in core data, save and broadcast changed object
            _ = newTypicalAmount.save(to: draftFoodItem)
            
            self.addToTypicalAmounts = false
        } else {
            activeAlert = .error(message: errorMessage)
            showingAlert = true
        }
    }
}
