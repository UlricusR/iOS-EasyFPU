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
    @Binding var isPresented: Bool
    @ObservedObject var draftFoodItem: FoodItemViewModel
    var editedFoodItem: FoodItem
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
                    Section(header: self.draftFoodItem.typicalAmounts.isEmpty ? Text("Enter amount consumed") : Text("Enter amount consumed or select typical amount")) {
                        HStack {
                            Text("Amount consumed")
                            TextField("Amount consumed", text: self.$draftFoodItem.amountAsString)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                            Text("g")
                        }
                        
                        // Buttons to ease input
                        HStack {
                            Spacer()
                            NumberButton(number: 100, draftFoodItem: self.draftFoodItem, width: geometry.size.width / 6)
                            NumberButton(number: 50, draftFoodItem: self.draftFoodItem, width: geometry.size.width / 6)
                            NumberButton(number: 10, draftFoodItem: self.draftFoodItem, width: geometry.size.width / 6)
                            NumberButton(number: 5, draftFoodItem: self.draftFoodItem, width: geometry.size.width / 6)
                            NumberButton(number: 1, draftFoodItem: self.draftFoodItem, width: geometry.size.width / 6)
                            Spacer()
                        }
                        
                        // Add to typical amounts
                        if self.addToTypicalAmounts {
                            // User wants to add amount to typical amounts, so comment is required
                            HStack {
                                TextField("Comment", text: self.$newTypicalAmountComment)
                                Button(action: {
                                    if let newTypicalAmount = TypicalAmountViewModel(amountAsString: self.draftFoodItem.amountAsString, comment: self.newTypicalAmountComment, errorMessage: &self.errorMessage) {
                                        // Add new typical amount to typical amounts of food item
                                        self.draftFoodItem.typicalAmounts.append(newTypicalAmount)
                                        
                                        // Reset text fields
                                        self.newTypicalAmountComment = ""
                                        
                                        // Update food item in core data, save and broadcast changed object
                                        let newCoreDataTypicalAmount = TypicalAmount(context: self.managedObjectContext)
                                        newTypicalAmount.cdTypicalAmount = newCoreDataTypicalAmount
                                        let _ = newTypicalAmount.updateCDTypicalAmount(foodItem: self.editedFoodItem)
                                        self.editedFoodItem.addToTypicalAmounts(newCoreDataTypicalAmount)
                                        try? AppDelegate.viewContext.save()
                                        self.draftFoodItem.objectWillChange.send()
                                        
                                        self.addToTypicalAmounts = false
                                    } else {
                                        self.showingAlert = true
                                    }
                                }) {
                                    Image(systemName: "checkmark.circle").foregroundColor(.yellow)
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
                    
                    if !self.draftFoodItem.typicalAmounts.isEmpty {
                        Section(header: Text("Typical amounts:")) {
                            ForEach(self.draftFoodItem.typicalAmounts.sorted(), id: \.self) { typicalAmount in
                                HStack {
                                    Text(typicalAmount.amountAsString)
                                    Text("g")
                                    Text(typicalAmount.comment)
                                }
                                .onTapGesture {
                                    self.draftFoodItem.amountAsString = typicalAmount.amountAsString
                                    self.draftFoodItem.objectWillChange.send()
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarTitle(self.draftFoodItem.name)
            .navigationBarItems(
                leading: HStack {
                    Button(action: {
                        // Do nothing, just quit edit mode, as food item hasn't been modified
                        self.isPresented = false
                    }) {
                        Text("Cancel")
                    }
                    
                    Button(action: {
                        self.showingSheet = true
                    }) {
                        Image(systemName: "questionmark.circle").imageScale(.large)
                    }.padding()
                },
                trailing: Button(action: {
                    let amountResult = FoodItemViewModel.checkForPositiveInt(valueAsString: self.draftFoodItem.amountAsString, allowZero: true)
                    switch amountResult {
                    case .success(let amountAsInt):
                        self.editedFoodItem.amount = Int64(amountAsInt)
                        
                        // Save new food item
                        try? AppDelegate.viewContext.save()
                        
                        // Quit edit mode
                        self.isPresented = false
                    case .failure(let err):
                        // Display alert and stay in edit mode
                        self.errorMessage = FoodItemViewModel.getErrorMessage(from: err)
                        self.showingAlert = true
                    }
                }) {
                    Text("Done")
                }
            )
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
            HelpView(isPresented: self.$showingSheet, helpScreen: self.helpScreen)
        }
    }
}

struct NumberButton: View {
    var number: Int
    var draftFoodItem: FoodItemViewModel
    var width: CGFloat
    
    var body: some View {
        Button(action: {
            let newValue = self.draftFoodItem.amount + self.number
            self.draftFoodItem.amountAsString = FoodItemViewModel.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: newValue))!
        }) {
            Text("+\(self.number)")
        }
        .frame(width: width, height: 40, alignment: .center)
        .background(Color.green)
        .foregroundColor(.white)
        .buttonStyle(BorderlessButtonStyle())
        .cornerRadius(20)
    }
}

