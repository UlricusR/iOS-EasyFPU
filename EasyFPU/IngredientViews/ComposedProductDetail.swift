//
//  ComposedProductDetail.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 29.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct ComposedProductDetail: View {
    @ObservedObject var product: ComposedProductViewModel
    @State var message: String = ""
    @State var showingActionSheet: Bool = false
    @Environment(\.presentationMode) var presentation
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                Form {
                    Section(header: Text("Final product")) {
                        HStack {
                            Text("Name")
                            TextField("Name", text: self.$product.name)
                        }
                        
                        HStack {
                            Text("Weight")
                            CustomTextField(titleKey: "Weight", text: self.$product.amountAsString, keyboardType: .numberPad)
                                .multilineTextAlignment(.trailing)
                            Text("g")
                        }
                        
                        // Buttons to ease input
                        HStack {
                            Spacer()
                            NumberButton(number: 100, variableAmountItem: self.product, width: geometry.size.width / 7)
                            NumberButton(number: 50, variableAmountItem: self.product, width: geometry.size.width / 7)
                            NumberButton(number: 10, variableAmountItem: self.product, width: geometry.size.width / 7)
                            NumberButton(number: 5, variableAmountItem: self.product, width: geometry.size.width / 7)
                            NumberButton(number: 1, variableAmountItem: self.product, width: geometry.size.width / 7)
                            Spacer()
                        }
                    }
                    
                    Section(header: Text("Ingredients")) {
                        List {
                            ForEach(product.foodItems) { foodItem in
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
            .navigationBarTitle(Text("Composed product"))
            .navigationBarItems(leading: Button(action: {
                presentation.wrappedValue.dismiss()
            }) {
                Text("Cancel")
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
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
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
        for ingredient in product.foodItems {
            ingredientsWeight += ingredient.amount
        }
        
        return ingredientsWeight <= product.amount ? true : false
    }
    
    private func saveProduct() {
        let newProduct = FoodItemViewModel(name: product.name, category: .product, favorite: false, caloriesPer100g: product.calories, carbsPer100g: product.getCarbsInclSugars(), sugarsPer100g: product.getSugarsOnly(), amount: product.amount)
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
}
