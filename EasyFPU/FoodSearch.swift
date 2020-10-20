//
//  SearchResultView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 19.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct FoodSearch: View {
    @ObservedObject var foodDatabase: OpenFoodFacts
    @ObservedObject var draftFoodItem: FoodItemViewModel
    @Environment(\.presentationMode) var presentation
    @State var selectedResult: OpenFoodFactsProduct?
    @State var errorMessage = ""
    @State var showingAlert = false
    
    var body: some View {
        NavigationView {
            List {
                if foodDatabase.searchResults.isEmpty {
                    Text("No search results (yet)")
                } else {
                    ForEach(foodDatabase.searchResults, id: \.self) { searchResult in
                        FoodSearchResultPreview(product: searchResult, isSelected: self.selectedResult == searchResult)
                            .onTapGesture {
                                self.selectedResult = searchResult
                            }
                    }
                }
            }
            .navigationBarTitle("Food Database Search")
            .navigationBarItems(leading: Button(action: {
                presentation.wrappedValue.dismiss()
            }) {
                Text("Cancel")
            }, trailing: Button(action: {
                if selectedResult == nil {
                    errorMessage = NSLocalizedString("Nothing selected", comment: "")
                    showingAlert = true
                } else {
                    do {
                        let foodItem = try selectedResult!.fill(foodDatabase: foodDatabase)
                        foodDatabase.foodDatabaseEntry = foodItem
                        draftFoodItem.name = foodItem.productName
                        if foodItem.brand != nil {
                            draftFoodItem.name += " (\(foodItem.brand!))"
                        }
                        
                        guard
                            let caloriesAsString = DataHelper.doubleFormatter(numberOfDigits: 5).string(from: NSNumber(value: foodItem.caloriesPer100g)),
                            let carbsAsString = DataHelper.doubleFormatter(numberOfDigits: 5).string(from: NSNumber(value: foodItem.carbsPer100g)),
                            let sugarsAsString = DataHelper.doubleFormatter(numberOfDigits: 5).string(from: NSNumber(value: foodItem.sugarsPer100g ?? 0))
                        else {
                            throw InvalidNumberError.inputError(NSLocalizedString("Fatal error: Cannot convert numbers into string, please contact app developer", comment: ""))
                        }
                        draftFoodItem.caloriesPer100gAsString = caloriesAsString
                        draftFoodItem.carbsPer100gAsString = carbsAsString
                        draftFoodItem.sugarsPer100gAsString = sugarsAsString
                        draftFoodItem.objectWillChange.send()
                        foodDatabase.objectWillChange.send()
                        presentation.wrappedValue.dismiss()
                    } catch FoodDatabaseError.incompleteData(let errorMessage) {
                        self.errorMessage = errorMessage
                        showingAlert = true
                    } catch FoodDatabaseError.typeError(let errorMessage) {
                        self.errorMessage = errorMessage
                        showingAlert = true
                    } catch {
                        self.errorMessage = error.localizedDescription
                        showingAlert = true
                    }
                }
            }) {
                Text("Select")
            })
        }
        .alert(isPresented: self.$showingAlert) {
            Alert(
                title: Text("Data alert"),
                message: Text(self.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear(perform: search)
    }
    
    private func search() {
        foodDatabase.search(for: draftFoodItem.name)
    }
}
