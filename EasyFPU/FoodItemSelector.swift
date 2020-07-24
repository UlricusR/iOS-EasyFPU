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
                }
                
                if !draftFoodItem.typicalAmounts.isEmpty {
                    Section(header: Text("Typical amounts:")) {
                        ForEach(draftFoodItem.typicalAmounts, id: \.self) { typicalAmount in
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
                    var amount: Int = 0
                    if FoodItemViewModel.checkForPositiveInt(valueAsString: self.draftFoodItem.amountAsString, valueAsInt: &amount) { // We have a valid amount
                        self.editedFoodItem.amount = Int64(amount)
                        
                        // Save new food item
                        self.saveContext()
                        
                        // Quit edit mode
                        self.isPresented = false
                    } else { // Invalid data, display alert
                        // Display alert and stay in edit mode
                        self.errorMessage = NSLocalizedString("Amount not a valid number or negative", comment: "")
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
