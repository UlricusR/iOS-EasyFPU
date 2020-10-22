//
//  SearchResultView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 19.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct FoodSearch: View {
    @ObservedObject var foodDatabaseResults: FoodDatabaseResults
    @ObservedObject var draftFoodItem: FoodItemViewModel
    @Environment(\.presentationMode) var presentation
    @State var selectedResult: FoodDatabaseEntry?
    @State var errorMessage = ""
    @State var showingAlert = false
    
    var body: some View {
        NavigationView {
            List {
                if foodDatabaseResults.searchResults == nil || foodDatabaseResults.searchResults!.isEmpty {
                    Text("No search results (yet)")
                } else {
                    ForEach(foodDatabaseResults.searchResults!) { searchResult in
                        FoodSearchResultPreview(product: searchResult, isSelected: self.selectedResult == searchResult)
                            .onTapGesture {
                                self.selectedResult = searchResult
                            }
                    }
                }
            }
            .navigationBarTitle("Food Database Search")
            .navigationBarItems(leading: Button(action: {
                // Empty search result and close sheet
                foodDatabaseResults.searchResults = nil
                presentation.wrappedValue.dismiss()
            }) {
                Text("Cancel")
            }, trailing: Button(action: {
                if selectedResult == nil {
                    errorMessage = NSLocalizedString("Nothing selected", comment: "")
                    showingAlert = true
                } else {
                    foodDatabaseResults.selectedEntry = selectedResult!
                    draftFoodItem.fill(with: selectedResult!)
                    
                    // Empty search results and close sheet
                    foodDatabaseResults.searchResults = nil
                    presentation.wrappedValue.dismiss()
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
        UserSettings.shared.foodDatabase.search(for: draftFoodItem.name, foodDatabaseResults: foodDatabaseResults)
    }
}
