//
//  ComposedProductDetail.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 29.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct FoodItemComposerView: View {
    enum NotificationState {
        case void, successfullySavedFoodItem
    }
    
    @ObservedObject var composedFoodItem: ComposedFoodItemViewModel
    @State var message: String = ""
    @State var showingActionSheet: Bool = false
    @Environment(\.presentationMode) var presentation
    @Environment(\.managedObjectContext) var managedObjectContext
    @State private var activeSheet: FoodItemComposerViewSheets.State?
    @State private var notificationState = NotificationState.void
    private let helpScreen = HelpScreen.foodItemComposer
    
    @State var generateTypicalAmounts: Bool = true
    
    var body: some View {
        ZStack(alignment: .top) {
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
                                        Stepper("Number of portions", value: $composedFoodItem.numberOfPortions, in: 1...100)
                                        Text("\(composedFoodItem.numberOfPortions)")
                                    }
                                    
                                    if !composedFoodItem.typicalAmounts.isEmpty {
                                        List {
                                            ForEach(composedFoodItem.typicalAmounts) { typicalAmount in
                                                HStack {
                                                    Text(typicalAmount.amountAsString)
                                                    Text("g")
                                                    Text(typicalAmount.comment)
                                                }
                                            }
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
                    .navigationBarTitle(Text("Final product"), displayMode: .inline)
                    .navigationBarItems(
                        leading: Button(action: {
                            activeSheet = .help
                        }) {
                            Image(systemName: "questionmark.circle").imageScale(.large)
                        }, trailing: HStack {
                            Button(action: {
                                composedFoodItem.clear()
                            }) {
                                Image(systemName: "xmark.circle").foregroundColor(.red).imageScale(.large).padding(.trailing)
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
                                Text("Save")
                            }
                        }
                    )
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
            .sheet(item: $activeSheet) {
                sheetContent($0)
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
            
            // Notification
            if notificationState != .void {
                NotificationView {
                    notificationViewContent()
                }
            }
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
        // First store new ComposedFoodItem in CoreData and add it to the view model
        let cdComposedFoodItem = ComposedFoodItem.create(from: composedFoodItem, idToBeReplaced: UserSettings.shared.composedFoodItemID)
        composedFoodItem.cdComposedFoodItem = cdComposedFoodItem
        
        // Then save ComposedFoodItem as new FoodItem, but set amount to zero, so that it won't appear selected in Products list
        let cdFoodItem = FoodItem.create(from: composedFoodItem, idToBeReplaced: UserSettings.shared.composedFoodItemFoodItemID)
        cdFoodItem.amount = 0
        
        // Clear the ComposedFoodItem, and notify user of successful storage
        composedFoodItem.clear()
        notificationState = .successfullySavedFoodItem
    }
    
    @ViewBuilder
    private func notificationViewContent() -> some View {
        switch notificationState {
        case .successfullySavedFoodItem:
            HStack {
                Text(self.composedFoodItem.name)
                Text("successfully saved in Products")
            }
            .onAppear() {
                Timer.scheduledTimer(withTimeInterval: 3.5, repeats: false) { timer in
                    self.notificationState = .void
                }
            }
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func sheetContent(_ state: FoodItemComposerViewSheets.State) -> some View {
        switch state {
        case .help:
            HelpView(helpScreen: self.helpScreen)
        }
    }
}
