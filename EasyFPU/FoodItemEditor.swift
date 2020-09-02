//
//  FoodItemEditor.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 13.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI
import Combine

struct FoodItemEditor: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Binding var isPresented: Bool
    var navigationBarTitle: String
    @ObservedObject var draftFoodItem: FoodItemViewModel
    var editedFoodItem: FoodItem? // Working copy of the food item
    @State var errorMessage: String = ""
    @State private var showingSheet = false;
    
    @State var showingAlert = false
    @FetchRequest(
        entity: FoodItem.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \FoodItem.name, ascending: true)
        ]
    ) var foodItems: FetchedResults<FoodItem>
    
    var typicalAmounts: [TypicalAmountViewModel] { draftFoodItem.typicalAmounts.sorted() }
    
    @State var newTypicalAmount = ""
    @State var newTypicalAmountComment = ""
    @State var newTypicalAmountId: UUID?
    @State var typicalAmountsToBeDeleted = [TypicalAmountViewModel]()
    @State var updateButton = false
    private let helpScreen = HelpScreen.foodItemEditor
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section {
                        // Name
                        TextField("Name", text: $draftFoodItem.name)
                        
                        // Favorite
                        Toggle("Favorite", isOn: $draftFoodItem.favorite)
                    }
                    
                    Section(header: Text("Nutritional values per 100g:")) {
                        // Calories
                        HStack {
                            TextField("Calories per 100g", text: $draftFoodItem.caloriesAsString)
                                .keyboardType(.decimalPad)
                            Text("kcal")
                        }
                        
                        // Carbs
                        HStack {
                            TextField("Carbs per 100g", text: $draftFoodItem.carbsAsString)
                                .keyboardType(.decimalPad)
                            Text("g")
                        }
                    }
                    
                    Section(header: Text("Typical amounts:")) {
                        HStack {
                            TextField("Amount", text: $newTypicalAmount).keyboardType(.decimalPad)
                            Text("g")
                            TextField("Comment", text: $newTypicalAmountComment)
                            Button(action: {
                                if self.newTypicalAmountId == nil { // This is a new typical amount
                                    if let newTypicalAmount = TypicalAmountViewModel(amountAsString: self.newTypicalAmount, comment: self.newTypicalAmountComment, errorMessage: &self.errorMessage) {
                                        // Add new typical amount to typical amounts of food item
                                        self.draftFoodItem.typicalAmounts.append(newTypicalAmount)
                                        
                                        // Reset text fields
                                        self.newTypicalAmount = ""
                                        self.newTypicalAmountComment = ""
                                        self.updateButton = false
                                        
                                        // Broadcast changed object
                                        self.draftFoodItem.objectWillChange.send()
                                    } else {
                                        self.showingAlert = true
                                    }
                                } else { // This is an existing typical amount
                                    guard let index = self.draftFoodItem.typicalAmounts.firstIndex(where: { $0.id == self.newTypicalAmountId! }) else {
                                        self.errorMessage = NSLocalizedString("Fatal error: Could not identify typical amount", comment: "")
                                        self.showingAlert = true
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
                            }) {
                                Image(systemName: self.updateButton ? "checkmark.circle" : "plus.circle").foregroundColor(self.updateButton ? .yellow : .green)
                            }
                        }
                    }
                    
                    Section(footer: Text("Tap to edit")) {
                        ForEach(self.typicalAmounts, id: \.self) { typicalAmount in
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
                        }.onDelete(perform: deleteTypicalAmount)
                    }
                    
                    // Delete food item (only when editing an existing food item)
                    if editedFoodItem != nil {
                        Section {
                            Button(action: {
                                // First close the sheet
                                self.isPresented = false
                                
                                // Then delete all related typical amounts
                                for typicalAmount in self.typicalAmounts {
                                    if typicalAmount.cdTypicalAmount != nil {
                                        typicalAmount.cdTypicalAmount!.prepareForDeletion()
                                        if self.draftFoodItem.cdFoodItem != nil {
                                            self.draftFoodItem.cdFoodItem!.removeFromTypicalAmounts(typicalAmount.cdTypicalAmount!)
                                        }
                                        self.managedObjectContext.delete(typicalAmount.cdTypicalAmount!)
                                    }
                                }
                                
                                // Then delete the food item itself
                                if self.draftFoodItem.cdFoodItem != nil {
                                    self.managedObjectContext.delete(self.draftFoodItem.cdFoodItem!)
                                }
                                
                                // And save the context
                                try? AppDelegate.viewContext.save()
                            }) {
                                Text("Delete food item")
                            }
                        }
                    }
                }
            }
            .navigationBarTitle(navigationBarTitle)
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
                    if let updatedFoodItem = FoodItemViewModel(
                        name: self.draftFoodItem.name,
                        favorite: self.draftFoodItem.favorite,
                        caloriesAsString: self.draftFoodItem.caloriesAsString,
                        carbsAsString: self.draftFoodItem.carbsAsString,
                        amountAsString: self.draftFoodItem.amountAsString,
                        errorMessage: &self.errorMessage) { // We have a valid food item
                        if self.editedFoodItem != nil { // We need to update an existing food item
                            self.editedFoodItem!.name = updatedFoodItem.name
                            self.editedFoodItem!.favorite = updatedFoodItem.favorite
                            self.editedFoodItem!.carbsPer100g = updatedFoodItem.carbsPer100g
                            self.editedFoodItem!.caloriesPer100g = updatedFoodItem.caloriesPer100g
                            self.editedFoodItem!.amount = Int64(updatedFoodItem.amount)
                            
                            // Update typical amounts
                            for typicalAmount in self.draftFoodItem.typicalAmounts {
                                // Check if it's an existing core data entry
                                if typicalAmount.cdTypicalAmount == nil { // This is a new typical amount
                                    let newTypicalAmount = TypicalAmount(context: self.managedObjectContext)
                                    typicalAmount.cdTypicalAmount = newTypicalAmount
                                    let _ = typicalAmount.updateCDTypicalAmount(foodItem: self.editedFoodItem!)
                                    self.editedFoodItem!.addToTypicalAmounts(newTypicalAmount)
                                } else { // This is an existing typical amount, so just update values
                                    let _ = typicalAmount.updateCDTypicalAmount(foodItem: self.editedFoodItem!)
                                }
                            }
                            
                            // Remove deleted typical amounts
                            for typicalAmountToBeDeleted in self.typicalAmountsToBeDeleted {
                                if typicalAmountToBeDeleted.cdTypicalAmount != nil {
                                    typicalAmountToBeDeleted.cdTypicalAmount!.foodItem = nil
                                    self.editedFoodItem!.removeFromTypicalAmounts(typicalAmountToBeDeleted.cdTypicalAmount!)
                                    self.managedObjectContext.delete(typicalAmountToBeDeleted.cdTypicalAmount!)
                                }
                            }
                            
                            // Reset typical amounts to be deleted
                            self.typicalAmountsToBeDeleted.removeAll()
                        } else { // We have a new food item
                            let newFoodItem = FoodItem(context: self.managedObjectContext)
                            newFoodItem.id = UUID()
                            newFoodItem.name = updatedFoodItem.name
                            newFoodItem.favorite = updatedFoodItem.favorite
                            newFoodItem.carbsPer100g = updatedFoodItem.carbsPer100g
                            newFoodItem.caloriesPer100g = updatedFoodItem.caloriesPer100g
                            newFoodItem.amount = Int64(updatedFoodItem.amount)
                            
                            for typicalAmount in self.typicalAmounts {
                                let newTypicalAmount = TypicalAmount(context: self.managedObjectContext)
                                typicalAmount.cdTypicalAmount = newTypicalAmount
                                let _ = typicalAmount.updateCDTypicalAmount(foodItem: newFoodItem)
                                newFoodItem.addToTypicalAmounts(newTypicalAmount)
                            }
                        }
                        
                        // Save new food item
                        try? AppDelegate.viewContext.save()
                        
                        // Quit edit mode
                        self.isPresented = false
                    } else { // Invalid data, display alert
                        // Display alert and stay in edit mode
                        self.showingAlert = true
                    }
                }) {
                    Text("Done")
                }
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .alert(isPresented: $showingAlert) {
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
    
    func deleteTypicalAmount(at offsets: IndexSet) {
        offsets.forEach { index in
            let typicalAmountToBeDeleted = self.typicalAmounts[index]
            typicalAmountsToBeDeleted.append(typicalAmountToBeDeleted)
            guard let originalIndex = self.draftFoodItem.typicalAmounts.firstIndex(where: { $0.id == typicalAmountToBeDeleted.id }) else {
                self.errorMessage = NSLocalizedString("Cannot find typical amount ", comment: "") + typicalAmountToBeDeleted.comment
                return
            }
            self.draftFoodItem.typicalAmounts.remove(at: originalIndex)
        }
        self.draftFoodItem.objectWillChange.send()
    }
}
