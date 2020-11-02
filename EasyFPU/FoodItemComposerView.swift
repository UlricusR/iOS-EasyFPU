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
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Button(action: {
                        activeSheet = .help
                    }) {
                        Image(systemName: "questionmark.circle").imageScale(.large)
                    }.padding([.leading, .trailing])
                    
                    Button(action: {
                        composedFoodItem.clear()
                    }) {
                        Image(systemName: "xmark.circle").foregroundColor(.red).imageScale(.large).padding([.leading, .trailing])
                    }
                    
                    Text(NSLocalizedString("Composed product", comment: "")).font(.headline).multilineTextAlignment(.center)
                    
                    Spacer()
                }
                
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
                        
                        Button(action: {
                            if !weightCheck() {
                                message = NSLocalizedString("The weight of the composed product is less than the sum of its ingredients", comment: "")
                                showingActionSheet = true
                            } else {
                                saveProduct()
                                presentation.wrappedValue.dismiss()
                            }
                        }) {
                            Text("Save as new product")
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
        
        /*for typicalAmount in self.typicalAmounts {
            let newTypicalAmount = TypicalAmount(context: self.managedObjectContext)
            typicalAmount.cdTypicalAmount = newTypicalAmount
            let _ = typicalAmount.updateCDTypicalAmount(foodItem: newFoodItem)
            newFoodItem.addToTypicalAmounts(newTypicalAmount)
        }*/
        
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
