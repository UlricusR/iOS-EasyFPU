//
//  ComposedProductDetail.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 29.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct FoodItemComposerView: View {
    @ObservedObject var composedFoodItem: ComposedFoodItemViewModel
    @State var message: String = ""
    @State var showingActionSheet: Bool = false
    @Environment(\.presentationMode) var presentation
    @Environment(\.managedObjectContext) var managedObjectContext
    @State var activeSheet: FoodItemComposerViewSheets.State?
    private let helpScreen = HelpScreen.foodItemComposer
    @State var errorMessage: String = ""
    @State var showingAlert: Bool = false
    
    @State var generateTypicalAmounts: Bool = true
    @State var numberOfPortions: Int = 1
    @State var typicalAmounts = [TypicalAmountViewModel]()
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack {
                    Form {
                        Section(header: Text("Final product")) {
                            HStack {
                                Text("Name")
                                TextField("Name", text: self.$composedFoodItem.name)
                            }
                            
                            HStack {
                                Text("Weight")
                                CustomTextField(titleKey: "Weight", text: self.$composedFoodItem.amountAsString, keyboardType: .numberPad)
                                    .multilineTextAlignment(.trailing)
                                    .onChange(of: self.composedFoodItem.amount) { _ in
                                        generateAmounts()
                                    }
                                Text("g")
                            }
                            
                            // Buttons to ease input
                            HStack {
                                Spacer()
                                NumberButton(number: 100, variableAmountItem: self.composedFoodItem, width: geometry.size.width / 7)
                                NumberButton(number: 50, variableAmountItem: self.composedFoodItem, width: geometry.size.width / 7)
                                NumberButton(number: 10, variableAmountItem: self.composedFoodItem, width: geometry.size.width / 7)
                                NumberButton(number: 5, variableAmountItem: self.composedFoodItem, width: geometry.size.width / 7)
                                NumberButton(number: 1, variableAmountItem: self.composedFoodItem, width: geometry.size.width / 7)
                                Spacer()
                            }
                        }
                        
                        
                        Section(header: Text("Typical Amounts")) {
                            // Generate typical amounts
                            Toggle("Generate typical amounts", isOn: self.$generateTypicalAmounts)
                            
                            if generateTypicalAmounts {
                                // Number of portions
                                HStack {
                                    Stepper("Number of portions", value: $numberOfPortions, in: 1...100)
                                    Text("\(numberOfPortions)")
                                }
                                .onChange(of: numberOfPortions) { _ in
                                    generateAmounts()
                                }
                                
                                if !typicalAmounts.isEmpty {
                                    List {
                                        ForEach(typicalAmounts) { typicalAmount in
                                            HStack {
                                                Text(typicalAmount.amountAsString)
                                                Text("g")
                                                Text(typicalAmount.comment)
                                            }
                                        }.onDelete(perform: deleteTypicalAmount)
                                    }
                                }
                            }
                        }
                        
                        
                        Section(header: Text("Ingredients")) {
                            List {
                                ForEach(composedFoodItem.foodItems) { foodItem in
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
                .navigationBarTitle(Text("Composed product"), displayMode: .inline)
                .navigationBarItems(
                    leading: HStack {
                        Button(action: {
                            activeSheet = .help
                        }) {
                            Image(systemName: "questionmark.circle").imageScale(.large)
                        }
                        
                        Button(action: {
                            composedFoodItem.clear()
                        }) {
                            Image(systemName: "xmark.circle").foregroundColor(.red).imageScale(.large).padding([.leading, .trailing])
                        }
                    }, trailing: Button(action: {
                        if !weightCheck() {
                            message = NSLocalizedString("The weight of the composed product is less than the sum of its ingredients", comment: "")
                            showingActionSheet = true
                        } else {
                            saveProduct()
                            presentation.wrappedValue.dismiss()
                        }
                    }) {
                        Text("Save")
                    }
                )
            }
            .navigationViewStyle(StackNavigationViewStyle())
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
                message: Text(self.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear() {
            generateAmounts()
        }
    }
    
    private func generateAmounts() {
        typicalAmounts.removeAll()
        if generateTypicalAmounts && composedFoodItem.amount > 0 {
            let portionWeight = composedFoodItem.amount / numberOfPortions
            for multiplier in 1...numberOfPortions {
                let amount = portionWeight * multiplier
                let amountAsString = DataHelper.doubleFormatter(numberOfDigits: 5).string(from: NSNumber(value: amount))!
                let comment = "- \(multiplier) \(NSLocalizedString("portion(s)", comment: "")) (\(multiplier)/\(numberOfPortions))"
                if let typicalAmount = TypicalAmountViewModel(amountAsString: amountAsString, comment: comment, errorMessage: &errorMessage) {
                    typicalAmounts.append(typicalAmount)
                } else {
                    errorMessage = NSLocalizedString("Cannot create typical amount: ", comment: "") + errorMessage
                    showingAlert = true
                }
            }
        }
    }
    
    private func deleteTypicalAmount(at offsets: IndexSet) {
        offsets.forEach { index in
            typicalAmounts.remove(at: index)
        }
    }
    
    private func weightCheck() -> Bool {
        var ingredientsWeight = 0
        for ingredient in composedFoodItem.foodItems {
            ingredientsWeight += ingredient.amount
        }
        
        return ingredientsWeight <= composedFoodItem.amount ? true : false
    }
    
    private func saveProduct() {
        let newProduct = FoodItemViewModel(name: composedFoodItem.name, category: .product, favorite: false, caloriesPer100g: composedFoodItem.calories, carbsPer100g: composedFoodItem.getCarbsInclSugars(), sugarsPer100g: composedFoodItem.getSugarsOnly(), amount: composedFoodItem.amount)
        let newFoodItem = FoodItem(context: self.managedObjectContext)
        newFoodItem.id = UUID()
        newFoodItem.name = newProduct.name
        newFoodItem.category = newProduct.category.rawValue
        newFoodItem.favorite = newProduct.favorite
        newFoodItem.carbsPer100g = newProduct.carbsPer100g
        newFoodItem.caloriesPer100g = newProduct.caloriesPer100g
        newFoodItem.sugarsPer100g = newProduct.sugarsPer100g
        newFoodItem.amount = Int64(newProduct.amount)
        
        for typicalAmount in self.typicalAmounts {
            let newTypicalAmount = TypicalAmount(context: self.managedObjectContext)
            typicalAmount.cdTypicalAmount = newTypicalAmount
            let _ = typicalAmount.updateCDTypicalAmount(foodItem: newFoodItem)
            newFoodItem.addToTypicalAmounts(newTypicalAmount)
        }
        
        // Save new food item
        try? AppDelegate.viewContext.save()
    }
    
    @ViewBuilder
    private func sheetContent(_ state: FoodItemComposerViewSheets.State) -> some View {
        switch state {
        case .help:
            HelpView(helpScreen: self.helpScreen)
        }
    }
}
