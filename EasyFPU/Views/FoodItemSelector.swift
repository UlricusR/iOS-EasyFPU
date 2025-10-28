//
//  FoodItemSelector.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 14.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI
import CoreData

struct FoodItemSelector: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Binding var navigationPath: NavigationPath
    @ObservedObject var ingredient: Ingredient
    @ObservedObject var composedFoodItem: ComposedFoodItem
    var category: FoodItemCategory
    @State private var newTypicalAmountComment = ""
    @State private var addToTypicalAmounts = false
    @State private var showingSheet = false
    @State private var showingAlert = false
    @State private var activeAlert: SimpleAlertType?
    private let helpScreen = HelpScreen.foodItemSelector
    
    var relatedFoodItem: FoodItem? {
        if let relatedFoodItemObjectID = ingredient.relatedFoodItemObjectID, let moID = CoreDataStack.viewContext.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: relatedFoodItemObjectID) {
            return CoreDataStack.viewContext.object(with: moID) as? FoodItem
        } else {
            activeAlert = .fatalError(message: NSLocalizedString("No food item associated to typical amount!", comment: ""))
            showingAlert = true
        }
        
        return nil
    }
    
    var typicalAmounts: [TypicalAmount]? {
        if let relatedFoodItem {
            return relatedFoodItem.typicalAmounts?.allObjects as? [TypicalAmount] ?? nil
        }
        
        return nil
    }
    
    var body: some View {
        ZStack {
            // The form with the food item details
            GeometryReader { geometry in
                Form {
                    Section(header: typicalAmounts != nil && typicalAmounts!.count > 0 ? Text(category == .product ? "Enter amount consumed" : "Enter amount used") : Text(category == .product ? "Enter amount consumed or select typical amount" : "Enter amount used or select typical amount")) {
                        HStack {
                            Text(category == .product ? "Amount consumed": "Amount used")
                            TextField(category == .product ? "Amount consumed" : "Amount used", value: self.$ingredient.amount, formatter: DataHelper.intFormatter(hideZero: true))
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .accessibilityIdentifierLeaf("AmountConsumed")
                            Text("g")
                                .accessibilityIdentifierLeaf("UnitConsumed")
                        }
                        
                        // Buttons to ease input
                        AmountEntryButtons(variableAmountItem: ingredient, geometry: geometry)
                        
                        // Add to typical amounts (only if not connected to a ComposedFoodItem)
                        if ingredient.foodItem?.composedFoodItem == nil {
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
                    
                    if typicalAmounts != nil && typicalAmounts!.count > 0 {
                        Section(header: Text("Typical amounts:"), footer: Text("Tap to select")) {
                            ForEach(typicalAmounts!.sorted { $0.amount < $1.amount }, id: \.self) { typicalAmount in
                                HStack {
                                    Text(String(typicalAmount.amount))
                                        .accessibilityIdentifierLeaf("TypicalAmountValue")
                                    Text("g")
                                        .accessibilityIdentifierLeaf("TypicalAmountUnit")
                                    Text(typicalAmount.comment ?? "")
                                        .accessibilityIdentifierLeaf("TypicalAmountComment")
                                }
                                .onTapGesture {
                                    self.ingredient.amount = typicalAmount.amount
                                }
                                .accessibilityIdentifierBranch("TAmount" + String(typicalAmount.amount))
                            }
                        }
                    }
                }
            }
            .safeAreaPadding(EdgeInsets(top: 0, leading: 0, bottom: ActionButton.safeButtonSpace, trailing: 0)) // Required to avoid the content to be hidden by the Add button
            
            // The overlaying add button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        // First check for unsaved typical amount
                        if self.addToTypicalAmounts {
                            self.addTypicalAmount()
                        }
                        
                        if self.ingredient.amount > 0 {
                            composedFoodItem.add(ingredient: ingredient)
                            
                            // Quit edit mode
                            navigationPath.removeLast()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill").imageScale(.large).foregroundStyle(.green)
                            Text("Add")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(ActionButton())
                    .disabled(ingredient.amount <= 0)
                    .accessibilityIdentifierLeaf("AddButton")
                    
                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle(self.ingredient.name)
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
        // Relate typical amount to food item
        if let relatedFoodItem, let moc = relatedFoodItem.managedObjectContext {
            let newTypicalAmount = TypicalAmount.create(amount: self.ingredient.amount, comment: self.newTypicalAmountComment, context: moc)
            newTypicalAmount.foodItem = relatedFoodItem
            
            // Reset text fields
            self.newTypicalAmountComment = ""
            self.addToTypicalAmounts = false
        }
    }
}
