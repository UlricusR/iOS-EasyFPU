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
    @State var showingAlert = false
    @State var errorMessage = ""
    @State var newTypicalAmountComment = ""
    @State var addToTypicalAmounts = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: draftFoodItem.typicalAmounts.isEmpty ? Text("Enter amount consumed") : Text("Enter amount consumed or select typical amount")) {
                    HStack {
                        Text("Amount consumed")
                        TextField("Amount consumed", text: $draftFoodItem.amountAsString)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("g")
                    }
                    
                    // Buttons to ease input
                    HStack {
                        Spacer()
                        NumberButton(number: 100, draftFoodItem: self.draftFoodItem)
                        NumberButton(number: 50, draftFoodItem: self.draftFoodItem)
                        NumberButton(number: 10, draftFoodItem: self.draftFoodItem)
                        NumberButton(number: 5, draftFoodItem: self.draftFoodItem)
                        NumberButton(number: 1, draftFoodItem: self.draftFoodItem)
                        Spacer()
                    }
                    
                    // Add to typical amounts
                    if addToTypicalAmounts {
                        // User wants to add amount to typical amounts, so comment is required
                        HStack {
                            TextField("Comment", text: $newTypicalAmountComment)
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
                                    self.saveContext()
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
                
                if !draftFoodItem.typicalAmounts.isEmpty {
                    Section(header: Text("Typical amounts:")) {
                        ForEach(draftFoodItem.typicalAmounts.sorted(), id: \.self) { typicalAmount in
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
            .navigationBarTitle("Select amount")
            .navigationBarItems(
                leading: Button(action: {
                    // Do nothing, just quit edit mode, as food item hasn't been modified
                    self.isPresented = false
                }) {
                    Text("Cancel")
                },
                trailing: Button(action: {
                    let amountResult = FoodItemViewModel.checkForPositiveInt(valueAsString: self.draftFoodItem.amountAsString)
                    switch amountResult {
                    case .success(let amountAsInt):
                        self.editedFoodItem.amount = Int64(amountAsInt)
                        
                        // Save new food item
                        self.saveContext()
                        
                        // Quit edit mode
                        self.isPresented = false
                    case .failure(let err):
                        // Display alert and stay in edit mode
                        self.errorMessage = err.localizedDescription
                        self.showingAlert = true
                    }
                }) {
                    Text("Done")
                }
            )
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Data alert"),
                message: Text(self.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    func saveContext() {
        if self.managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                print("Error saving managed object context: \(error)")
            }
        }
    }
}

struct NumberButton: View {
    var number: Int
    var draftFoodItem: FoodItemViewModel
    
    var body: some View {
        Button(action: {
            let newValue = self.draftFoodItem.amount + self.number
            self.draftFoodItem.amountAsString = FoodItemViewModel.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: newValue))!
        }) {
            Text("+\(number)")
        }
        .padding()
        .buttonStyle(BorderlessButtonStyle())
        .background(Color.green)
        .foregroundColor(.white)
        .cornerRadius(10)
    }
}

